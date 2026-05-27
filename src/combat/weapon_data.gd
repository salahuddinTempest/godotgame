class_name WeaponData
extends Resource
## Defines a weapon's visual configuration and combat properties.
##
## Used by both Player and EnemyBase to attach and configure
## weapons from the Medieval Weapons Pack by Quaternius (FBX assets).

# === Exports ===
@export_group("Identity")
@export var weapon_id: String = "sword"
@export var display_name: String = "Sword"

@export_group("Asset")
## Path to the FBX weapon scene inside res://
@export var fbx_path: String = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Sword.fbx"
## Name of the skeleton bone to attach to (hand_r for player right hand)
@export var bone_name: String = "hand_r"

@export_group("Transform")
## Local position offset after attaching to bone
@export var position_offset: Vector3 = Vector3(0.0, 0.05, 0.05)
## Rotation in degrees after attaching to bone
@export var rotation_offset: Vector3 = Vector3(-90.0, 0.0, 0.0)
## Uniform scale — Quaternius FBX models need 0.01 to match Godot units
@export var scale_factor: float = 0.01

@export_group("Combat")
@export var damage_multiplier: float = 1.0
@export var attack_range: float = 2.5
@export var damage_type: Constants.DamageType = Constants.DamageType.PHYSICAL

# === Preset Factory Methods ===

static func make_sword() -> WeaponData:
	var d := WeaponData.new()
	d.weapon_id      = "sword"
	d.display_name   = "Sword"
	d.fbx_path       = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Sword.fbx"
	d.bone_name      = "hand_r"
	d.position_offset = Vector3(0.0, 0.05, 0.05)
	d.rotation_offset = Vector3(-90.0, 0.0, 0.0)
	d.scale_factor    = 0.01
	d.damage_multiplier = 1.0
	d.attack_range    = 2.5
	d.damage_type     = Constants.DamageType.PHYSICAL
	return d

static func make_axe() -> WeaponData:
	var d := WeaponData.new()
	d.weapon_id      = "axe"
	d.display_name   = "Axe"
	d.fbx_path       = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Axe.fbx"
	d.bone_name      = "hand_r"
	d.position_offset = Vector3(0.0, 0.05, 0.0)
	d.rotation_offset = Vector3(-90.0, 0.0, 0.0)
	d.scale_factor    = 0.01
	d.damage_multiplier = 1.2
	d.attack_range    = 2.2
	d.damage_type     = Constants.DamageType.PHYSICAL
	return d

static func make_dagger() -> WeaponData:
	var d := WeaponData.new()
	d.weapon_id      = "dagger"
	d.display_name   = "Dagger"
	d.fbx_path       = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Dagger.fbx"
	d.bone_name      = "hand_r"
	d.position_offset = Vector3(0.0, 0.03, 0.03)
	d.rotation_offset = Vector3(-90.0, 0.0, 0.0)
	d.scale_factor    = 0.01
	d.damage_multiplier = 0.8
	d.attack_range    = 1.8
	d.damage_type     = Constants.DamageType.PHYSICAL
	return d

static func make_claymore() -> WeaponData:
	var d := WeaponData.new()
	d.weapon_id      = "claymore"
	d.display_name   = "Claymore"
	d.fbx_path       = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Claymore.fbx"
	d.bone_name      = "hand_r"
	d.position_offset = Vector3(0.0, 0.08, 0.08)
	d.rotation_offset = Vector3(-90.0, 0.0, 0.0)
	d.scale_factor    = 0.01
	d.damage_multiplier = 1.6
	d.attack_range    = 3.0
	d.damage_type     = Constants.DamageType.PHYSICAL
	return d

static func make_spear() -> WeaponData:
	var d := WeaponData.new()
	d.weapon_id      = "spear"
	d.display_name   = "Spear"
	d.fbx_path       = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Spear.fbx"
	d.bone_name      = "hand_r"
	d.position_offset = Vector3(0.0, 0.06, 0.06)
	d.rotation_offset = Vector3(-90.0, 0.0, 0.0)
	d.scale_factor    = 0.01
	d.damage_multiplier = 1.1
	d.attack_range    = 3.5
	d.damage_type     = Constants.DamageType.PHYSICAL
	return d
