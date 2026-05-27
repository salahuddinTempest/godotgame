class_name WeaponAttachment
extends Node
## Reusable component that attaches a weapon FBX to a skeleton bone.
##
## Add as child of any CharacterBody3D. Call attach(weapon_data, model_root)
## to attach a weapon to the skeleton's hand bone via BoneAttachment3D.
## Works for both Player and EnemyBase.

# === Signals ===
signal weapon_attached(weapon_id: String)
signal weapon_detached(weapon_id: String)

# === Public Variables ===
var current_weapon_data: WeaponData = null
var weapon_node: Node3D = null

# === Private Variables ===
var _attachment_node: BoneAttachment3D = null
var _skeleton: Skeleton3D = null

# === Public Methods ===

## Attach a weapon to the given model's skeleton.
## model_root: The Node3D root of the character model (contains Skeleton3D)
func attach(weapon_data: WeaponData, model_root: Node3D) -> bool:
	if not weapon_data:
		GameLogger.warn("WeaponAttachment", "attach() called with null WeaponData")
		return false

	# Detach existing weapon first
	if current_weapon_data:
		detach()

	if not ResourceLoader.exists(weapon_data.fbx_path):
		GameLogger.warn("WeaponAttachment",
			"Weapon FBX not found: %s" % weapon_data.fbx_path)
		return false

	var scene: PackedScene = load(weapon_data.fbx_path)
	if not scene:
		GameLogger.error("WeaponAttachment",
			"Failed to load weapon scene: %s" % weapon_data.fbx_path)
		return false

	var weapon_instance: Node3D = scene.instantiate() as Node3D
	if not weapon_instance:
		return false

	# Apply transform from WeaponData
	weapon_instance.position       = weapon_data.position_offset
	weapon_instance.rotation_degrees = weapon_data.rotation_offset
	weapon_instance.scale          = Vector3.ONE * weapon_data.scale_factor

	# Try to find Skeleton3D inside model_root
	_skeleton = _find_skeleton(model_root)

	if _skeleton:
		var bone_idx: int = _find_bone(_skeleton, weapon_data.bone_name)
		if bone_idx != -1:
			_attachment_node = BoneAttachment3D.new()
			_attachment_node.bone_name = _skeleton.get_bone_name(bone_idx)
			_attachment_node.bone_idx  = bone_idx
			_skeleton.add_child(_attachment_node)
			_attachment_node.add_child(weapon_instance)
			GameLogger.info("WeaponAttachment",
				"'%s' attached to bone '%s' (idx %d) with scale %.3f" % [
				weapon_data.display_name, _attachment_node.bone_name,
				bone_idx, weapon_data.scale_factor])
		else:
			# Bone not found — fallback to model root
			model_root.add_child(weapon_instance)
			weapon_instance.position = Vector3(0.3, 1.0, -0.3)
			GameLogger.warn("WeaponAttachment",
				"Bone '%s' not found. Fallback to model root." % weapon_data.bone_name)
	else:
		# No skeleton — fallback to model_root with offset
		model_root.add_child(weapon_instance)
		weapon_instance.position = Vector3(0.3, 1.0, -0.3)
		GameLogger.warn("WeaponAttachment",
			"No Skeleton3D found in '%s'. Weapon placed at model root." % model_root.name)

	weapon_node          = weapon_instance
	current_weapon_data  = weapon_data
	weapon_attached.emit(weapon_data.weapon_id)
	return true

## Remove the currently equipped weapon.
func detach() -> void:
	if not current_weapon_data:
		return

	var old_id: String = current_weapon_data.weapon_id

	if is_instance_valid(weapon_node):
		weapon_node.queue_free()
	weapon_node = null

	if is_instance_valid(_attachment_node):
		_attachment_node.queue_free()
	_attachment_node = null

	current_weapon_data = null
	weapon_detached.emit(old_id)
	GameLogger.info("WeaponAttachment", "Weapon '%s' detached." % old_id)

## Swap to a different weapon at runtime.
func swap_weapon(new_weapon_data: WeaponData, model_root: Node3D) -> bool:
	detach()
	return attach(new_weapon_data, model_root)

## Return whether a weapon is currently equipped.
func has_weapon() -> bool:
	return current_weapon_data != null and is_instance_valid(weapon_node)

## Return damage multiplier of the equipped weapon (1.0 if none).
func get_damage_multiplier() -> float:
	return current_weapon_data.damage_multiplier if current_weapon_data else 1.0

## Return attack range of the equipped weapon.
func get_attack_range() -> float:
	return current_weapon_data.attack_range if current_weapon_data else 2.0

# === Private Methods ===

func _find_skeleton(root: Node) -> Skeleton3D:
	if root is Skeleton3D:
		return root as Skeleton3D
	for child in root.get_children():
		var result: Skeleton3D = _find_skeleton(child)
		if result:
			return result
	return null

## Try multiple bone name variations (Mixamo, UE4, hand_r, etc.)
func _find_bone(skeleton: Skeleton3D, preferred: String) -> int:
	# Exact match first
	var idx: int = skeleton.find_bone(preferred)
	if idx != -1:
		return idx

	# Try common variants
	var variants: Array[String] = [
		"hand_r", "Hand_R", "RightHand", "mixamorig:RightHand",
		"Bip01_R_Hand", "RightHandIndex1"
	]
	for v in variants:
		idx = skeleton.find_bone(v)
		if idx != -1:
			return idx

	return -1
