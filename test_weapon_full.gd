extends SceneTree

func _init() -> void:
	# Test 1: Load the Sword FBX
	var weapon_path = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Sword.fbx"
	if not ResourceLoader.exists(weapon_path):
		print("FAIL: Sword asset not found at: ", weapon_path)
		quit()
		return
	
	var scene = load(weapon_path) as PackedScene
	if not scene:
		print("FAIL: Could not load Sword as PackedScene")
		quit()
		return
	
	var weapon = scene.instantiate()
	print("=== SWORD NODE TREE ===")
	_print_tree(weapon, 0)
	
	# Test 2: Load the player GLTF model directly (bypassing player.gd script)
	var model_path = "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf"
	if not ResourceLoader.exists(model_path):
		print("FAIL: Player model not found")
		quit()
		return
	
	var model_scene = load(model_path) as PackedScene
	var model = model_scene.instantiate()
	root.add_child(model)
	
	# Find skeleton
	var skeleton = _find_skeleton(model)
	if not skeleton:
		print("FAIL: No skeleton found in model")
		quit()
		return
	
	print("\n=== SKELETON: ", skeleton.name, " ===")
	print("Bone count: ", skeleton.get_bone_count())
	
	# Find hand_r bone
	var bone_idx = skeleton.find_bone("hand_r")
	print("hand_r bone index: ", bone_idx)
	
	if bone_idx == -1:
		print("FAIL: hand_r bone not found")
		quit()
		return
	
	# Attach weapon via BoneAttachment3D
	var attachment = BoneAttachment3D.new()
	attachment.bone_name = "hand_r"
	attachment.bone_idx = bone_idx
	skeleton.add_child(attachment)
	
	var weapon_instance = scene.instantiate()
	attachment.add_child(weapon_instance)
	
	# Test different scales
	print("\n=== WEAPON SCALE TEST ===")
	for test_scale in [0.005, 0.01, 0.02, 0.05, 0.1, 0.5, 1.0]:
		weapon_instance.scale = Vector3(test_scale, test_scale, test_scale)
		# Process one frame to update transforms
		print("Scale %.3f -> global_scale: %s" % [test_scale, str(weapon_instance.global_transform.basis.get_scale())])
	
	# Set reasonable scale and print final state
	weapon_instance.scale = Vector3(0.01, 0.01, 0.01)
	weapon_instance.position = Vector3(0.0, 0.05, 0.05)
	weapon_instance.rotation_degrees = Vector3(-90, 0, 0)
	
	print("\n=== FINAL WEAPON STATE ===")
	print("Local position: ", weapon_instance.position)
	print("Local rotation: ", weapon_instance.rotation_degrees)
	print("Local scale: ", weapon_instance.scale)
	print("Global position: ", weapon_instance.global_position)
	print("Global scale: ", weapon_instance.global_transform.basis.get_scale())
	
	# Print full node tree to verify attachment
	print("\n=== FULL ATTACHMENT TREE ===")
	_print_tree(skeleton, 0)
	
	print("\nDONE - Weapon attachment test complete")
	quit()

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var result = _find_skeleton(child)
		if result:
			return result
	return null

func _print_tree(node: Node, depth: int) -> void:
	var indent = "  ".repeat(depth)
	var info = "%s%s [%s]" % [indent, node.name, node.get_class()]
	if node is Node3D:
		info += " pos:%s rot:%s scl:%s" % [str(node.position), str(node.rotation_degrees), str(node.scale)]
	if node is MeshInstance3D:
		var mi = node as MeshInstance3D
		if mi.mesh:
			info += " mesh_aabb:%s" % str(mi.mesh.get_aabb())
	print(info)
	# Only go 3 levels deep for skeleton to avoid too much output
	if depth < 4:
		for child in node.get_children():
			_print_tree(child, depth + 1)
