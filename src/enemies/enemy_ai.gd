class_name EnemyAI
extends Node
## Base AI Controller for Enemies.
##
## Implements a simple state machine: Patrol, Pursuit, Combat, Retreat.

# === Exports ===
@export var detection_radius: float = 15.0
@export var attack_range: float = 2.0
@export var retreat_health_threshold: float = 0.2 # 20%

# === Public Variables ===
var current_state: Constants.EnemyState = Constants.EnemyState.IDLE
var target: Node3D = null

# === Private Variables ===
var _body: EnemyBase
var _spawn_point: Vector3

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
	if not _body or not _body.is_alive() or not multiplayer.is_server():
		return
		
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
	_check_for_target()

func _process_patrol(delta: float) -> void:
	# Simple wander logic
	_check_for_target()

func _process_pursuit(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	var dist: float = _body.global_position.distance_to(target.global_position)
	if dist <= attack_range:
		change_state(Constants.EnemyState.COMBAT)
	else:
		# Move towards target
		var dir: Vector3 = (target.global_position - _body.global_position).normalized()
		var speed: float = _body.stats.get_move_speed()
		_body.velocity.x = dir.x * speed
		_body.velocity.z = dir.z * speed
		_body.move_and_slide()

func _process_combat(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	# Check retreat threshold
	if _body.stats.get_health_percent() <= retreat_health_threshold:
		change_state(Constants.EnemyState.RETREAT)
		return
		
	var dist: float = _body.global_position.distance_to(target.global_position)
	if dist > attack_range:
		change_state(Constants.EnemyState.PURSUIT)
		return
		
	# Execute attack
	# (Typically handled by timers or animation events, simplified here)
	pass

func _process_retreat(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	# Move away from target
	var dir: Vector3 = (_body.global_position - target.global_position).normalized()
	var speed: float = _body.stats.get_move_speed() * 1.2 # Run away faster
	_body.velocity.x = dir.x * speed
	_body.velocity.z = dir.z * speed
	_body.move_and_slide()

func _check_for_target() -> void:
	# Find nearest player in GameManager active_players
	var nearest: Node3D = null
	var min_dist: float = detection_radius
	
	for pid in GameManager.active_players:
		var player = GameManager.active_players[pid]
		if not is_instance_valid(player) or not player.is_alive():
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
