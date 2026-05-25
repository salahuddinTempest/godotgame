class_name LobbyManager
extends Node
## Manages game sessions, lobby UI states, and drop-in/drop-out logic.

# === Public Variables ===
var lobby_players: Dictionary = {} # peer_id -> {name, class, level, ready}

# === Lifecycle Methods ===

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

# === Public Methods ===

func register_in_lobby(player_info: Dictionary) -> void:
	var id: int = multiplayer.get_unique_id()
	lobby_players[id] = player_info
	
	if multiplayer.has_multiplayer_peer() and not multiplayer.is_server():
		_rpc_register_player.rpc_id(1, player_info)

func start_game_from_lobby() -> void:
	if not multiplayer.is_server():
		return
		
	# Check if all ready, etc.
	_rpc_start_game.rpc()

# === RPC Methods ===

@rpc("any_peer", "call_remote", "reliable")
func _rpc_register_player(info: Dictionary) -> void:
	if not multiplayer.is_server():
		return
		
	var sender_id: int = multiplayer.get_remote_sender_id()
	lobby_players[sender_id] = info
	
	# Broadcast updated lobby to all clients
	_rpc_update_lobby.rpc(lobby_players)

@rpc("authority", "call_remote", "reliable")
func _rpc_update_lobby(full_lobby: Dictionary) -> void:
	lobby_players = full_lobby
	EventBus.lobby_updated.emit(lobby_players.size())

@rpc("authority", "call_local", "reliable")
func _rpc_start_game() -> void:
	# Load the first level
	var level_manager = get_node_or_null("/root/LevelManager")
	if level_manager:
		level_manager.load_level("kingdom_hub")
	else:
		GameLogger.error("LobbyManager", "LevelManager not found, cannot start game.")

# === Private Methods ===

func _on_peer_connected(id: int) -> void:
	# Server sends current lobby state to new peer
	if multiplayer.is_server():
		_rpc_update_lobby.rpc_id(id, lobby_players)

func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		lobby_players.erase(id)
		_rpc_update_lobby.rpc(lobby_players)
