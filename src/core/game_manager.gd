extends Node
## Main game orchestrator — Autoloaded singleton.
##
## Mengelola game state, sesi pemain, dan koordinasi antar sistem.
## Tidak menyimpan logika gameplay — delegasikan ke sistem masing-masing.

# === Signals ===
signal state_changed(old_state: Constants.GameState, new_state: Constants.GameState)

# === Constants ===
const GAME_VERSION: String = "0.1.0"

# === Public Variables ===
var current_state: Constants.GameState = Constants.GameState.MAIN_MENU
var active_players: Dictionary = {}  # peer_id -> player_node
var party_leader_id: int = 1
var session_start_time: float = 0.0
var total_play_time: float = 0.0
var current_difficulty: float = 1.0  # 0.8 easy, 1.0 normal, 1.3 hard

# === Save/Load Bridge ===
## Holds save data during scene transition so kingdom_hub can restore state.
var pending_save_data: Dictionary = {}
var pending_save_slot: int = 0

# === Private Variables ===
var _paused_by: String = ""

# === Lifecycle Methods ===

func _ready() -> void:
	_connect_signals()
	GameLogger.info("GameManager", "Royal Era v%s initialized." % GAME_VERSION)

func _process(delta: float) -> void:
	if current_state == Constants.GameState.IN_GAME:
		total_play_time += delta

# === Public Methods ===

func change_state(new_state: Constants.GameState) -> void:
	if current_state == new_state:
		return
	var old_state: Constants.GameState = current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	EventBus.game_state_changed.emit(old_state, new_state)
	GameLogger.info("GameManager", "State: %s → %s" % [
		Constants.GameState.keys()[old_state],
		Constants.GameState.keys()[new_state]
	])

func start_new_game(difficulty: float = 1.0) -> void:
	current_difficulty = difficulty
	session_start_time = Time.get_unix_time_from_system()
	change_state(Constants.GameState.LOADING)
	GameLogger.info("GameManager", "New game started. Difficulty: %.1f" % difficulty)

func pause_game(requester: String = "player") -> void:
	if current_state != Constants.GameState.IN_GAME:
		return
	_paused_by = requester
	get_tree().paused = true
	change_state(Constants.GameState.PAUSED)
	EventBus.game_paused.emit()

func resume_game() -> void:
	if current_state != Constants.GameState.PAUSED:
		return
	get_tree().paused = false
	change_state(Constants.GameState.IN_GAME)
	EventBus.game_resumed.emit()
	_paused_by = ""

func register_player(peer_id: int, player_node: Node) -> void:
	if active_players.has(peer_id):
		GameLogger.warn("GameManager", "Player %d already registered." % peer_id)
		return
	active_players[peer_id] = player_node
	EventBus.player_joined_party.emit(peer_id)
	GameLogger.info("GameManager", "Player %d joined. Party size: %d" % [peer_id, active_players.size()])

func unregister_player(peer_id: int) -> void:
	if not active_players.has(peer_id):
		return
	active_players.erase(peer_id)
	EventBus.player_left_party.emit(peer_id)
	GameLogger.info("GameManager", "Player %d left. Party size: %d" % [peer_id, active_players.size()])

func get_player(peer_id: int) -> Node:
	return active_players.get(peer_id, null)

func get_party_size() -> int:
	return active_players.size()

func is_host() -> bool:
	return multiplayer.is_server()

func get_session_duration() -> float:
	if session_start_time <= 0.0:
		return 0.0
	return Time.get_unix_time_from_system() - session_start_time

# === Private Methods ===

func _connect_signals() -> void:
	EventBus.player_died.connect(_on_player_died)
	EventBus.game_state_changed.connect(_on_game_state_changed)

func _on_player_died(player_id: int) -> void:
	GameLogger.info("GameManager", "Player %d died." % player_id)
	var all_dead: bool = true
	for pid: int in active_players:
		var p: Node = active_players[pid]
		if is_instance_valid(p) and p.has_method("is_alive") and p.is_alive():
			all_dead = false
			break
	if all_dead and get_party_size() > 0:
		GameLogger.info("GameManager", "All players dead — Game Over.")
		change_state(Constants.GameState.GAME_OVER)

func _on_game_state_changed(old: Constants.GameState, new: Constants.GameState) -> void:
	pass
