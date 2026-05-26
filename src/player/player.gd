class_name Player
extends CharacterBody3D

signal interacted(target: Node3D)

@export var stats: CharacterStats
@export var inventory: Inventory
@export var equipment: Equipment

# Using constants from constants.gd
const PLAYER_GRAVITY: float = Constants.PLAYER_GRAVITY
const PLAYER_ACCELERATION: float = Constants.PLAYER_ACCELERATION
const PLAYER_FRICTION: float = Constants.PLAYER_FRICTION

const TPP_CAMERA_OFFSET: Vector3 = Constants.THIRD_PERSON_OFFSET
const FPP_CAMERA_OFFSET: Vector3 = Constants.FIRST_PERSON_OFFSET
const CAMERA_YAW_LIMIT: float = Constants.CAMERA_YAW_LIMIT
const CAMERA_PITCH_LIMIT: float = Constants.CAMERA_PITCH_LIMIT

var peer_id: int = 1
var is_sprinting: bool = false
var input_direction: Vector2 = Vector2.ZERO
var is_third_person: bool = false

@onready var camera_pivot: Node3D = get_node_or_null("CameraPivot")
@onready var camera: Camera3D = get_node_or_null("CameraPivot/Camera3D")
@onready var model: Node3D = get_node_or_null("Model")
@onready var interact_raycast: RayCast3D = get_node_or_null("CameraPivot/Camera3D/InteractRayCast")
@onready var anim_player: AnimationPlayer = get_node_or_null("Model/AnimationPlayer")

func _ready() -> void:
	if not stats:
		stats = CharacterStats.new()
	if not inventory:
		inventory = Inventory.new()
	if not equipment:
		equipment = Equipment.new()

	stats.died.connect(_on_died)
	stats.stats_recalculated.connect(_on_stats_recalculated)
	equipment.equipment_stats_updated.connect(_update_equipment_stats)

	if is_local_authority():
		GameManager.register_player(peer_id, self)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	_update_camera_mode()

func _exit_tree() -> void:
	if is_local_authority():
		GameManager.unregister_player(peer_id)

func _unhandled_input(event: InputEvent) -> void:
	if not is_local_authority() or not stats.is_alive() or GameManager.current_state != Constants.GameState.IN_GAME:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if camera_pivot and camera:
			camera_pivot.rotate_y(-event.relative.x * 0.005)
			camera.rotation.x = clamp(camera.rotation.x - event.relative.y * 0.005, -CAMERA_PITCH_LIMIT, CAMERA_PITCH_LIMIT)

	if event.is_action_pressed("interact"):
		_handle_interaction()

	if event.is_action_pressed("toggle_view"):
		is_third_person = not is_third_person
		_update_camera_mode()

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_local_authority():
		return
	if not stats.is_alive():
		return

	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	if input_direction == Vector2.ZERO:
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
			input_direction.y -= 1
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
			input_direction.y += 1
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
			input_direction.x -= 1
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
			input_direction.x += 1

	is_sprinting = Input.is_action_pressed("sprint")

	if not is_on_floor():
		velocity.y -= PLAYER_GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = stats.base_jump_height

	var dir_vec: Vector3 = Vector3.ZERO
	if camera_pivot:
		dir_vec = (camera_pivot.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()
	else:
		dir_vec = Vector3(input_direction.x, 0, input_direction.y).normalized()

	var speed: float = stats.get_move_speed()
	if is_sprinting and stats.current_stamina > 0:
		speed *= 1.5

	if inventory.is_overweight():
		speed *= 0.7

	if dir_vec:
		velocity.x = lerp(velocity.x, dir_vec.x * speed, PLAYER_ACCELERATION * delta)
		velocity.z = lerp(velocity.z, dir_vec.z * speed, PLAYER_ACCELERATION * delta)
		if model:
			var target_rotation: float = atan2(dir_vec.x, dir_vec.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_rotation, 10.0 * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, PLAYER_FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, PLAYER_FRICTION * delta)

	move_and_slide()

	_update_animations()

func _update_camera_mode() -> void:
	if not camera_pivot or not camera:
		return
	if not model:
		return

	if is_third_person:
		camera.position = TPP_CAMERA_OFFSET
		camera.rotation.x = deg_to_rad(-15)
		model.visible = true
		if interact_raycast:
			interact_raycast.target_position = Vector3(0, 0, -8)
	else:
		camera.position = FPP_CAMERA_OFFSET
		camera.rotation.x = 0
		model.visible = false
		if interact_raycast:
			interact_raycast.target_position = Vector3(0, 0, -5)

func is_local_authority() -> bool:
	return multiplayer.get_unique_id() == peer_id or multiplayer.get_unique_id() == 1

func is_alive() -> bool:
	return stats.is_alive()

func _handle_interaction() -> void:
	if interact_raycast and interact_raycast.is_colliding():
		var target: Node3D = interact_raycast.get_collider() as Node3D
		if target and target.has_method("interact"):
			target.interact(self)
			interacted.emit(target)

func _on_died() -> void:
	velocity = Vector3.ZERO
	GameLogger.info("Player", "Player %d has died" % peer_id)
	EventBus.player_died.emit(peer_id)

func _on_stats_recalculated() -> void:
	pass

func _update_equipment_stats() -> void:
	stats.equipment_health_bonus = equipment.total_health_bonus
	stats.equipment_attack_bonus = equipment.total_attack_bonus
	stats.equipment_defense_bonus = equipment.total_defense_bonus
	stats.equipment_speed_bonus = equipment.total_speed_bonus
	stats.stats_recalculated.emit()


func _update_animations() -> void:
	if not anim_player:
		return

	var on_ground: bool = is_on_floor() if is_local_authority() else abs(velocity.y) < 0.1

	if not on_ground:
		if velocity.y > 0.1:
			_play_anim("Jump_Start")
		else:
			_play_anim("Jump")
	else:
		var horiz_vel := Vector3(velocity.x, 0.0, velocity.z)
		var horiz_speed := horiz_vel.length()
		if horiz_speed < 0.1:
			_play_anim("Idle")
		elif horiz_speed > 6.0 or (is_local_authority() and is_sprinting):
			_play_anim("Sprint")
		else:
			_play_anim("Walk")


func _play_anim(anim_name: String) -> void:
	if anim_player and anim_player.has_animation(anim_name):
		if anim_player.current_animation != anim_name:
			anim_player.play(anim_name, 0.2)
