class_name StateMachine
extends Node
## Reusable state machine base class untuk Godot 4.x.
##
## Extend class ini untuk membuat state machine spesifik.
## Contoh: EnemyAI, PlayerController, QuestSystem.

# === Signals ===
signal state_entered(state_name: String)
signal state_exited(state_name: String)
signal transitioned(from_state: String, to_state: String)

# === Public Variables ===
var current_state: String = ""
var previous_state: String = ""
var states: Dictionary = {}  # state_name -> Callable or Object

# === Private Variables ===
var _state_time: float = 0.0   # how long in current state
var _is_transitioning: bool = false

# === Lifecycle Methods ===

func _ready() -> void:
	_register_states()

func _process(delta: float) -> void:
	_state_time += delta
	if current_state.is_empty():
		return
	_process_state(current_state, delta)

func _physics_process(delta: float) -> void:
	if current_state.is_empty():
		return
	_physics_process_state(current_state, delta)

# === Public Methods ===

func transition_to(new_state: String) -> void:
	if _is_transitioning:
		return
	if not states.has(new_state):
		push_error("StateMachine: State '%s' not registered." % new_state)
		return
	if new_state == current_state:
		return

	_is_transitioning = true
	var from: String = current_state

	# Exit old state
	if not from.is_empty():
		_exit_state(from)
		state_exited.emit(from)

	previous_state = from
	current_state = new_state
	_state_time = 0.0

	# Enter new state
	_enter_state(new_state)
	state_entered.emit(new_state)
	transitioned.emit(from, new_state)

	_is_transitioning = false

func get_state_time() -> float:
	return _state_time

func is_in_state(state_name: String) -> bool:
	return current_state == state_name

func register_state(state_name: String) -> void:
	if states.has(state_name):
		push_error("StateMachine: State '%s' already registered." % state_name)
		return
	states[state_name] = true

# === Methods to Override ===

## Override to register all states at startup.
func _register_states() -> void:
	pass

## Called when entering a state.
func _enter_state(_state_name: String) -> void:
	pass

## Called when exiting a state.
func _exit_state(_state_name: String) -> void:
	pass

## Called every _process frame while in a state.
func _process_state(_state_name: String, _delta: float) -> void:
	pass

## Called every _physics_process frame while in a state.
func _physics_process_state(_state_name: String, _delta: float) -> void:
	pass
