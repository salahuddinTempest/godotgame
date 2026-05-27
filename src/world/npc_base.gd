class_name NPCBase
extends CharacterBody3D
## Base class for interactive and friendly/allied NPCs.
##
## Manages stats, survival needs (hunger, thirst, fatigue),
## dynamic weapon attachment, waypoint patrol, and combat skill execution.

# === Exports ===
@export var npc_id: String = "base_npc"
@export var display_name: String = "Allied Knight"
@export var level: int = 1
@export var active_skill_id: String = "power_strike"
@export var weapon_asset_path: String = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Sword.fbx"
@export var patrol_waypoints: Array[Vector3] = []
@export var waypoint_wait_time: float = 2.0
@export var show_status_plate: bool = true

# === Public Variables ===
var stats: CharacterStats
var active_skills: ActiveSkills
var needs_manager: NeedsManager

# === Private Variables ===
var _current_waypoint_index: int = 0
var _waypoint_wait_timer: float = 0.0

# === Onready ===
@onready var model: Node3D = $Model if has_node("Model") else null

# === Lifecycle Methods ===

func _ready() -> void:
	add_to_group("npcs")
	add_to_group("allies")
	_initialize_stats()
	_initialize_needs()
	_initialize_skills()
	_initialize_status_plate()
	# Attach weapon after active_skills and stats are set up
	call_deferred("_attach_weapon")

func _physics_process(_delta: float) -> void:
	# Basic gravity support if not on floor
	if not is_on_floor():
		velocity.y -= Constants.PLAYER_GRAVITY * _delta
		move_and_slide()
		
	if is_alive() and not patrol_waypoints.is_empty():
		_process_patrol(_delta)

# === Public Methods ===

func is_alive() -> bool:
	return stats and stats.is_alive()

func cast_active_skill(_target: Node3D = null) -> void:
	if not is_alive():
		return
		
	if not active_skills or not active_skills.knows_skill(active_skill_id):
		GameLogger.warn("NPCBase", "%s doesn't know skill %s" % [display_name, active_skill_id])
		return
		
	var mana_cost: float = active_skills.get_mana_cost(active_skill_id)
	if stats.current_mana < mana_cost:
		GameLogger.info("NPCBase", "%s lacks mana to cast %s" % [display_name, active_skill_id])
		return
		
	stats.use_mana(mana_cost)
	active_skills.execute_skill(active_skill_id, self)

# === Private Methods ===

func _initialize_stats() -> void:
	stats = CharacterStats.new()
	stats.level = level
	stats.character_name = display_name
	stats.base_max_health = 120.0 + (level - 1) * 15.0
	stats.base_max_mana = 60.0 + (level - 1) * 5.0
	stats.base_attack_power = 12.0 + (level - 1) * 2.5
	stats.current_health = stats.get_max_health()
	stats.current_mana = stats.get_max_mana()
	stats.died.connect(_on_died)

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
			GameLogger.info("NPCBase", "Status plate attached to %s" % display_name)

func _process_patrol(delta: float) -> void:
	# Process wait timer
	if _waypoint_wait_timer > 0.0:
		_waypoint_wait_timer -= delta
		velocity.x = 0.0
		velocity.z = 0.0
		return
		
	var wp: Vector3 = patrol_waypoints[_current_waypoint_index]
	var dist: float = global_position.distance_to(wp)
	
	if dist <= 0.8:
		# Waypoint reached!
		_waypoint_wait_timer = waypoint_wait_time
		_current_waypoint_index = (_current_waypoint_index + 1) % patrol_waypoints.size()
		velocity.x = 0.0
		velocity.z = 0.0
	else:
		# Move towards current waypoint
		var dir: Vector3 = (wp - global_position).normalized()
		var speed: float = stats.get_move_speed() * 0.5 # Walk speed
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		rotation.y = lerp_angle(rotation.y, atan2(dir.x, dir.z), 8.0 * delta)
		move_and_slide()

func _attach_weapon() -> void:
	if weapon_asset_path.is_empty():
		return
		
	if not ResourceLoader.exists(weapon_asset_path):
		GameLogger.warn("NPCBase", "Weapon asset not found: %s" % weapon_asset_path)
		return
		
	var scene = load(weapon_asset_path)
	if not scene:
		return
		
	var weapon_instance: Node3D = scene.instantiate() as Node3D
	if not weapon_instance:
		return
		
	# Apply 0.01 scale for Quaternius pack FBX models
	weapon_instance.scale = Vector3(0.01, 0.01, 0.01)
		
	# Find where to attach the weapon
	var attach_point: Node3D = null
	if model:
		# Attempt to find common hand bones or socket markers
		attach_point = model.find_child("RightHand", true, false)
		if not attach_point:
			attach_point = model.find_child("Hand_R", true, false)
		if not attach_point:
			attach_point = model.find_child("WeaponSocket", true, false)
		if not attach_point:
			# Fallback: attach directly to model with custom offset
			attach_point = model
			weapon_instance.position = Vector3(0.3, 1.0, -0.5) # Approximate hand position
			weapon_instance.rotation_degrees = Vector3(90, 0, 0)
			
	if not attach_point:
		attach_point = self
		weapon_instance.position = Vector3(0.3, 1.0, -0.5)
		
	attach_point.add_child(weapon_instance)
	GameLogger.info("NPCBase", "Weapon attached to %s: %s with 0.01 scale" % [display_name, weapon_asset_path.get_file()])

func _on_died() -> void:
	GameLogger.info("NPCBase", "%s has fallen in combat." % display_name)
	# Play death animation, disable collision
	collision_layer = 0
	collision_mask = 0
	
	var timer = get_tree().create_timer(3.0)
	timer.timeout.connect(queue_free)

