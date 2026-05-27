class_name EnemyBase
extends CharacterBody3D
## Base class for all enemies.
##
## Manages common enemy logic: stats scaling based on Tier,
## health, death handling, survival needs, active skills, weapons,
## and integration with CombatEngine.

# === Exports ===
@export var enemy_id: String = "base_enemy":
	set(value):
		enemy_id = value
		if is_inside_tree() and model:
			_initialize_visuals()

@export var display_name: String = "Enemy":
	set(value):
		display_name = value
		if stats:
			stats.character_name = display_name
@export var level: int = 1
@export var tier: Constants.MonsterTier = Constants.MonsterTier.TIER_1_MINION
@export var active_skill_id: String = "power_strike"
@export var weapon_asset_path: String = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Axe.fbx"
@export var show_status_plate: bool = true

# Components
@export var ai_controller: EnemyAI

# === Public Variables ===
var stats: CharacterStats
var active_skills: ActiveSkills
var needs_manager: NeedsManager
var weapon_attachment: WeaponAttachment
var anim_player: AnimationPlayer = null
var _is_attacking: bool = false
var _attack_anim_timer: float = 0.0

# === Onready ===
@onready var model: Node3D = $Model if has_node("Model") else null
@onready var hitbox: Area3D = $Hitbox if has_node("Hitbox") else null

# === Lifecycle Methods ===

func _ready() -> void:
	add_to_group("enemies")
	_initialize_stats()
	_initialize_needs()
	_initialize_skills()
	_initialize_status_plate()
	_initialize_visuals()

	# Set up WeaponAttachment component
	weapon_attachment = WeaponAttachment.new()
	add_child(weapon_attachment)
	
	if not ai_controller:
		ai_controller = get_node_or_null("EnemyAI") as EnemyAI
		
	if ai_controller:
		ai_controller.setup(self)
		
	if stats:
		stats.died.connect(_on_died)
		
	call_deferred("_equip_weapon")

# === Public Methods ===

func is_alive() -> bool:
	return stats and stats.is_alive()

func get_xp_reward() -> int:
	if not stats:
		return 0
	var tier_mult: float = 1.0 + (int(tier) * 0.5)
	return int(level * Constants.MONSTER_XP_PER_LEVEL * tier_mult)

func take_damage_from(attacker: Node, skill_data: Dictionary) -> void:
	# Typically called by Area3D overlap or Raycast from CombatEngine
	CombatEngine.apply_combat_hit(attacker, self, skill_data)

func get_current_attack_range() -> float:
	if not active_skills:
		return 2.0
	
	var skill_id: String = active_skill_id
	var mana_cost: float = active_skills.get_mana_cost(skill_id)
	
	# Fallback to basic attack range if skill unavailable or not enough mana
	if not active_skills.knows_skill(skill_id) or (mana_cost > 0.0 and (not stats or stats.current_mana < mana_cost)):
		skill_id = "basic_attack"
	
	return active_skills.get_skill_range(skill_id)

func cast_active_skill(_target: Node3D = null) -> void:
	if not is_alive():
		return
		
	if not active_skills:
		return
		
	var skill_to_cast: String = active_skill_id
	var mana_cost: float = active_skills.get_mana_cost(skill_to_cast)
	
	# Fallback to basic attack if the enemy doesn't know the active skill or doesn't have enough mana
	if not active_skills.knows_skill(skill_to_cast) or stats.current_mana < mana_cost:
		skill_to_cast = "basic_attack"
		mana_cost = 0.0
		
	if mana_cost > 0.0:
		stats.use_mana(mana_cost)
		
	active_skills.execute_skill(skill_to_cast, self)
	
	_is_attacking = true
	_attack_anim_timer = 0.6
	_play_anim("Sword_Attack")

# === Private Methods ===

func _initialize_stats() -> void:
	stats = CharacterStats.new()
	stats.level = level
	stats.character_name = display_name
	
	# Scale based on tier (per CLAUDE.md)
	var tier_health_bonus: float = int(tier) * 100.0
	stats.base_max_health = (level * float(Constants.MONSTER_HEALTH_PER_LEVEL)) + tier_health_bonus
	stats.base_max_mana = 50.0 + level * 5.0
	stats.base_attack_power = float(level * Constants.MONSTER_DAMAGE_PER_LEVEL)
	
	# Apply immediately
	stats.current_health = stats.get_max_health()
	stats.current_mana = stats.get_max_mana()

func _initialize_needs() -> void:
	# Instantiate NeedsManager dynamically as a child
	needs_manager = NeedsManager.new()
	add_child(needs_manager)

func _initialize_skills() -> void:
	# Instantiate ActiveSkills dynamically as a child to execute skill code
	active_skills = ActiveSkills.new()
	add_child(active_skills)

func _initialize_status_plate() -> void:
	if not show_status_plate:
		return
		
	var scene_path: String = "res://scenes/ui/floating_status_plate.tscn"
	if ResourceLoader.exists(scene_path):
		var plate_scene = load(scene_path)
		if plate_scene:
			var plate: Node3D = plate_scene.instantiate() as Node3D
			add_child(plate)
			GameLogger.info("EnemyBase", "Status plate attached to %s" % display_name)


func _equip_weapon() -> void:
	# Build WeaponData from the export path, or use Axe preset for enemies
	var wd: WeaponData
	if not weapon_asset_path.is_empty() and ResourceLoader.exists(weapon_asset_path):
		wd = WeaponData.new()
		wd.weapon_id     = weapon_asset_path.get_file().get_basename().to_lower()
		wd.display_name  = weapon_asset_path.get_file().get_basename()
		wd.fbx_path      = weapon_asset_path
		wd.bone_name     = "hand_r"
		wd.position_offset = Vector3(0.0, 0.05, 0.0)
		wd.rotation_offset = Vector3(-90.0, 0.0, 0.0)
		wd.scale_factor    = 0.01
		wd.damage_multiplier = 1.0
		wd.attack_range    = 2.0  # Weapon base range; skill range handled by ActiveSkills
	else:
		wd = WeaponData.make_axe()  # Default enemy weapon
	
	var model_root: Node3D = model if model else self
	weapon_attachment.attach(wd, model_root)

func _on_died() -> void:
	# Play death animation, drop loot, queue_free
	if ai_controller:
		ai_controller.change_state(Constants.EnemyState.DEAD)
	
	_play_anim("Death01")
	
	# Example loot drop
	EventBus.loot_dropped.emit(global_position, ["gold", 10 * level])
	
	# Wait for animation then free
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)


# === Dynamic Visuals & Animations ===

const ENEMY_VISUALS: Dictionary = {
	"bandit_scout": {
		"model_path": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Female_FullBody.gltf",
		"skin_texture": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/T_Superhero_Female_Dark_BaseColor.png",
		"scale": 1.0
	},
	"bandit_archer": {
		"model_path": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Female_FullBody.gltf",
		"skin_texture": "",
		"scale": 1.0
	},
	"bandit_grunt": {
		"model_path": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf",
		"skin_texture": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/T_Superhero_Male_Dark.png",
		"scale": 1.0
	},
	"bandit_fighter": {
		"model_path": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf",
		"skin_texture": "",
		"scale": 1.0
	},
	"bandit_captain": {
		"model_path": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf",
		"skin_texture": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/T_Superhero_Male_Dark.png",
		"scale": 1.2
	}
}

func _initialize_visuals() -> void:
	if not model:
		return
		
	var cfg: Dictionary = {
		"model_path": "res://assets/Universal Base Characters[Standard]/Base Characters/Godot - UE/Superhero_Male_FullBody.gltf",
		"skin_texture": "",
		"scale": 1.0
	}
	
	if ENEMY_VISUALS.has(enemy_id):
		var custom = ENEMY_VISUALS[enemy_id]
		cfg.model_path = custom.get("model_path", cfg.model_path)
		cfg.skin_texture = custom.get("skin_texture", cfg.skin_texture)
		cfg.scale = custom.get("scale", cfg.scale)
		
	# Clear any existing children of model EXCEPT the AnimationPlayer
	for child in model.get_children():
		if child is AnimationPlayer:
			continue
		model.remove_child(child)
		child.queue_free()

	if ResourceLoader.exists(cfg.model_path):
		var model_scene = load(cfg.model_path) as PackedScene
		if model_scene:
			var instance = model_scene.instantiate()
			
			# Reparent all children of the instantiated scene to 'model' so that
			# the Skeleton3D and meshes sit directly under 'model' (same level as AnimationPlayer),
			# matching the correct paths expected by Universal_Animations.tres.
			for child in instance.get_children():
				instance.remove_child(child)
				model.add_child(child)
			instance.queue_free()
			
			model.scale = Vector3.ONE * cfg.scale
			
			# Search under 'model' (since they are now direct children!) for the mesh node
			var mesh_node: MeshInstance3D = null
			if "female" in cfg.model_path.to_lower():
				mesh_node = model.find_child("SuperHero_Female", true, false) as MeshInstance3D
			else:
				mesh_node = model.find_child("SuperHero_Male", true, false) as MeshInstance3D
			
			if not mesh_node:
				mesh_node = model.find_child("*Mesh*", true, false) as MeshInstance3D
			
			if mesh_node and not cfg.skin_texture.is_empty() and ResourceLoader.exists(cfg.skin_texture):
				var tex = load(cfg.skin_texture) as Texture2D
				if tex:
					var mat = mesh_node.get_active_material(0)
					var dup_mat: StandardMaterial3D
					if mat is StandardMaterial3D:
						dup_mat = mat.duplicate() as StandardMaterial3D
					else:
						dup_mat = StandardMaterial3D.new()
					dup_mat.albedo_texture = tex
					mesh_node.set_surface_override_material(0, dup_mat)
							
			# Use or retrieve the AnimationPlayer node, ensuring the animation library is attached
			anim_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
			if anim_player:
				var anim_lib_path = "res://assets/Universal_Animations.tres"
				if ResourceLoader.exists(anim_lib_path):
					var lib = load(anim_lib_path) as AnimationLibrary
					if lib and not anim_player.has_animation_library(""):
						anim_player.add_animation_library("", lib)
						GameLogger.info("EnemyBase", "UAL animation library loaded for %s" % display_name)

func _physics_process(delta: float) -> void:
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity.y -= Constants.PLAYER_GRAVITY * delta
	else:
		# Reset vertical velocity when on floor
		velocity.y = 0.0
		
	# Move the character using the computed velocity (both horizontal and vertical)
	move_and_slide()
	
	_update_animations(delta)

func _update_animations(delta: float) -> void:
	if not anim_player:
		return
		
	if not is_alive():
		_play_anim("Death01")
		return
		
	if _attack_anim_timer > 0.0:
		_attack_anim_timer -= delta
		if _attack_anim_timer <= 0.0:
			_is_attacking = false
			
	if _is_attacking:
		return
		
	var speed = velocity.length()
	if speed < 0.1:
		_play_anim("Idle")
	elif ai_controller and (ai_controller.current_state == Constants.EnemyState.PURSUIT or ai_controller.current_state == Constants.EnemyState.RETREAT):
		_play_anim("Sprint")
	else:
		_play_anim("Walk")

func _play_anim(anim_name: String) -> void:
	if anim_player and anim_player.has_animation(anim_name):
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name, 0.2)


