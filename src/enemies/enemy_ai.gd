class_name EnemyAI
extends Node
## Base AI Controller for Enemies.
##
## Implements a simple state machine: Patrol, Pursuit, Combat, Retreat.

# === Exports ===
@export var detection_radius: float = 20.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 0.8
@export var patrol_waypoints: Array[Vector3] = []
@export var waypoint_wait_time: float = 2.0

# === Public Variables ===
var current_state: Constants.EnemyState = Constants.EnemyState.IDLE
var target: Node3D = null

# === Private Variables ===
var _body: EnemyBase
var _spawn_point: Vector3
var _attack_timer: float = 0.0
var _current_waypoint_index: int = 0
var _waypoint_wait_timer: float = 0.0

# === Public Methods ===

func setup(body: EnemyBase) -> void:
	_body = body
	_spawn_point = _body.global_position
	change_state(Constants.EnemyState.PATROL)

func change_state(new_state: Constants.EnemyState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	# Handle enter state logic if needed

# === Lifecycle Methods ===

func _physics_process(delta: float) -> void:
	if not _body or not _body.is_alive():
		return
	if multiplayer.multiplayer_peer and not multiplayer.is_server():
		return
		
	_attack_timer = maxf(0.0, _attack_timer - delta)
		
	match current_state:
		Constants.EnemyState.IDLE:
			_process_idle(delta)
		Constants.EnemyState.PATROL:
			_process_patrol(delta)
		Constants.EnemyState.PURSUIT:
			_process_pursuit(delta)
		Constants.EnemyState.COMBAT:
			_process_combat(delta)
		Constants.EnemyState.RETREAT:
			_process_retreat(delta)

# === Private Methods ===

func _process_idle(_delta: float) -> void:
	_body.velocity.x = 0.0
	_body.velocity.z = 0.0
	_check_for_target()

func _process_patrol(delta: float) -> void:
	_check_for_target()
	if current_state == Constants.EnemyState.PURSUIT:
		return # Target acquired, abort patrol
		
	if patrol_waypoints.is_empty():
		# Simple stationary idle when no waypoints
		_body.velocity.x = 0.0
		_body.velocity.z = 0.0
		return
		
	# Process wait timer
	if _waypoint_wait_timer > 0.0:
		_waypoint_wait_timer -= delta
		_body.velocity.x = 0.0
		_body.velocity.z = 0.0
		return
		
	var wp: Vector3 = patrol_waypoints[_current_waypoint_index]
	var dist: float = _body.global_position.distance_to(wp)
	
	if dist <= 0.8:
		# Waypoint reached!
		_waypoint_wait_timer = waypoint_wait_time
		_current_waypoint_index = (_current_waypoint_index + 1) % patrol_waypoints.size()
		_body.velocity.x = 0.0
		_body.velocity.z = 0.0
	else:
		# Move towards current waypoint
		var dir: Vector3 = (wp - _body.global_position).normalized()
		var speed: float = _body.stats.get_move_speed() * 0.6 # Walk speed
		_body.velocity.x = dir.x * speed
		_body.velocity.z = dir.z * speed
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(dir.x, dir.z), 8.0 * delta)


func _process_pursuit(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	var dist: float = _body.global_position.distance_to(target.global_position)
	if dist <= _body.get_current_attack_range():
		change_state(Constants.EnemyState.COMBAT)
	else:
		# Move towards target
		var dir: Vector3 = (target.global_position - _body.global_position).normalized()
		var speed: float = _body.stats.get_move_speed() * 1.25
		_body.velocity.x = dir.x * speed
		_body.velocity.z = dir.z * speed
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(dir.x, dir.z), 12.0 * delta)

func _process_combat(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	var dist: float = _body.global_position.distance_to(target.global_position)
	if dist > _body.get_current_attack_range():
		change_state(Constants.EnemyState.PURSUIT)
		return
		
	# Rotate towards target
	var dir: Vector3 = (target.global_position - _body.global_position).normalized()
	_body.rotation.y = lerp_angle(_body.rotation.y, atan2(dir.x, dir.z), 15.0 * delta)
	
	# Keep moving slightly towards player to maintain pressure
	var speed: float = _body.stats.get_move_speed() * 0.3
	_body.velocity.x = dir.x * speed
	_body.velocity.z = dir.z * speed
	
	# Execute attack/skill
	if _attack_timer <= 0.0:
		# Execute skill
		_body.cast_active_skill(target)
		_attack_timer = attack_cooldown


func _process_retreat(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	# Move away from target
	var dir: Vector3 = (_body.global_position - target.global_position).normalized()
	var speed: float = _body.stats.get_move_speed() * 1.2 # Run away faster
	_body.velocity.x = dir.x * speed
	_body.velocity.z = dir.z * speed

func _check_for_target() -> void:
	# Find nearest player in GameManager active_players
	var nearest: Node3D = null
	var min_dist: float = detection_radius
	
	for pid in GameManager.active_players:
		var player = GameManager.active_players[pid]
		if not is_instance_valid(player) or not (player.has_method("is_alive") and player.is_alive()):
			continue
			
		var dist: float = _body.global_position.distance_to(player.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = player
			
	if nearest:
		target = nearest
		change_state(Constants.EnemyState.PURSUIT)

func _is_target_valid() -> bool:
	return is_instance_valid(target) and target.has_method("is_alive") and target.is_alive()
