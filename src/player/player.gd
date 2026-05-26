class_name Player
extends CharacterBody3D

signal interacted(target: Node3D)

@export var stats: CharacterStats
@export var inventory: Inventory
@export var equipment: Equipment

# ── Constants ──────────────────────────────────────────────────────
const PLAYER_GRAVITY: float     = Constants.PLAYER_GRAVITY
const PLAYER_ACCELERATION: float = Constants.PLAYER_ACCELERATION
const PLAYER_FRICTION: float    = Constants.PLAYER_FRICTION

# Camera pivot heights
const FPP_HEIGHT: float = 1.6
const TPP_DISTANCE: float = 4.0  # spring arm length
const TPP_HEIGHT: float   = 1.2  # height above player root

const CAMERA_PITCH_MIN: float = deg_to_rad(-60.0)
const CAMERA_PITCH_MAX: float = deg_to_rad(25.0)
const MOUSE_SENSITIVITY: float = 0.003

# ── State ───────────────────────────────────────────────────────────
var peer_id: int = 1
var is_sprinting: bool = false
var input_direction: Vector2 = Vector2.ZERO
var is_third_person: bool = true   # TPP by default

# Camera orbit angles (used in TPP mode)
var _cam_yaw: float   = 0.0   # radians
var _cam_pitch: float = deg_to_rad(-20.0)

# ── Node references ─────────────────────────────────────────────────
@onready var camera_pivot: Node3D    = get_node_or_null("CameraPivot")
@onready var camera: Camera3D        = get_node_or_null("CameraPivot/Camera3D")
@onready var model: Node3D           = get_node_or_null("Model")
@onready var interact_raycast: RayCast3D = get_node_or_null("CameraPivot/Camera3D/InteractRayCast")
@onready var anim_player: AnimationPlayer = get_node_or_null("Model/AnimationPlayer")

# ── Lifecycle ───────────────────────────────────────────────────────
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

	add_to_group("players")
	_apply_camera_mode()


func _exit_tree() -> void:
	if is_local_authority():
		GameManager.unregister_player(peer_id)
	if stats:
		stats.died.disconnect(_on_died)
		stats.stats_recalculated.disconnect(_on_stats_recalculated)
	if equipment:
		equipment.equipment_stats_updated.disconnect(_update_equipment_stats)


# ── Input ───────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not is_local_authority():
		return
	if not stats.is_alive():
		return
	if GameManager.current_state != Constants.GameState.IN_GAME:
		return

	# Mouse look — works for both FPP and TPP camera orbit
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_cam_yaw   -= event.relative.x * MOUSE_SENSITIVITY
		_cam_pitch  = clamp(_cam_pitch - event.relative.y * MOUSE_SENSITIVITY,
		                    CAMERA_PITCH_MIN, CAMERA_PITCH_MAX)

	if event.is_action_pressed("interact"):
		_handle_interaction()

	# NOTE: toggle_view is intentionally NOT bound to a key here.
	# It is changed from Options > Settings > Controls tab.

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ── Physics ─────────────────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if not is_local_authority():
		return
	if not stats.is_alive():
		return

	# 1. Apply gravity
	if not is_on_floor():
		velocity.y -= PLAYER_GRAVITY * delta

	# 2. Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = stats.base_jump_height

	# 3. Read movement input (WASD / joystick)
	input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	is_sprinting    = Input.is_action_pressed("sprint")

	# 4. Compute world-space move direction relative to camera yaw
	#    Forward in camera space = -Z rotated by _cam_yaw
	var cam_basis := Basis(Vector3.UP, _cam_yaw)
	# input_direction.y < 0  means "move_forward" (W key) → forward = -Z in cam basis
	var move_input := Vector3(input_direction.x, 0.0, input_direction.y)
	var direction  := (cam_basis * move_input).normalized()

	# 5. Speed
	var speed: float = stats.get_move_speed()
	if is_sprinting and stats.current_stamina > 0:
		speed *= 1.5
	if inventory.is_overweight():
		speed *= 0.7

	# 6. Apply horizontal velocity
	if direction.length() > 0.01:
		velocity.x = lerp(velocity.x, direction.x * speed, PLAYER_ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, PLAYER_ACCELERATION * delta)
		# Rotate model to face movement direction
		if model:
			var target_y := atan2(direction.x, direction.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_y, 12.0 * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, PLAYER_FRICTION * delta)
		velocity.z = lerp(velocity.z, 0.0, PLAYER_FRICTION * delta)

	move_and_slide()

	# 7. Update camera transform every frame
	_update_camera_transform()

	# 8. Animations
	_update_animations()


# ── Camera ──────────────────────────────────────────────────────────

## Apply mode settings (call when switching FPP ↔ TPP)
func _apply_camera_mode() -> void:
	if not camera_pivot or not camera:
		return

	if is_third_person:
		model.visible = true if model else true
		if interact_raycast:
			interact_raycast.target_position = Vector3(0, 0, -8)
	else:
		if model:
			model.visible = false
		if interact_raycast:
			interact_raycast.target_position = Vector3(0, 0, -5)

	# Reset pitch to sensible defaults when switching
	_cam_pitch = deg_to_rad(-20.0) if is_third_person else 0.0
	_update_camera_transform()


## Recompute camera_pivot + camera positions every frame
func _update_camera_transform() -> void:
	if not camera_pivot or not camera:
		return

	if is_third_person:
		# Orbit camera: pivot sits at character shoulder height,
		# camera is pulled back along the orbit sphere
		camera_pivot.position = Vector3(0, TPP_HEIGHT, 0)

		# Apply yaw on the pivot parent (world space)
		camera_pivot.rotation.y = _cam_yaw

		# Apply pitch by tilting the camera downward/upward
		camera.rotation.x = _cam_pitch

		# Place camera behind at distance along local -Z after pitch
		# We use a simple spherical offset: (0, sin(pitch)*dist, cos(pitch)*dist)
		# In local camera_pivot space, "behind" is +Z (camera looks toward -Z)
		var dist: float = TPP_DISTANCE
		camera.position = Vector3(0.0,
		                          sin(-_cam_pitch) * dist,
		                          cos(-_cam_pitch) * dist)
	else:
		# First-person: camera at head height, no offset
		camera_pivot.position = Vector3(0, FPP_HEIGHT, 0)
		camera_pivot.rotation.y = _cam_yaw
		camera.rotation.x = _cam_pitch
		camera.position   = Vector3.ZERO


## Public API for Settings menu to toggle camera mode
func set_camera_mode(tpp: bool) -> void:
	is_third_person = tpp
	_apply_camera_mode()


# ── Helpers ─────────────────────────────────────────────────────────
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
	stats.equipment_health_bonus   = equipment.total_health_bonus
	stats.equipment_attack_bonus   = equipment.total_attack_bonus
	stats.equipment_defense_bonus  = equipment.total_defense_bonus
	stats.equipment_speed_bonus    = equipment.total_speed_bonus
	stats.stats_recalculated.emit()


# ── Animation ───────────────────────────────────────────────────────
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
		var horiz_speed := Vector3(velocity.x, 0.0, velocity.z).length()
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
