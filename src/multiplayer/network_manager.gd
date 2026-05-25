class_name NetworkManager
extends Node
## Core networking manager.
##
## Autoloaded singleton handling ENet setup, peer connections,
## and Server/Client configurations.

# === Signals ===
signal connection_failed()
signal connection_succeeded()
signal server_disconnected()

# === Public Variables ===
var peer: ENetMultiplayerPeer
var role: Constants.NetworkRole = Constants.NetworkRole.NONE
var server_ip: String = "127.0.0.1"

# === Lifecycle Methods ===

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# === Public Methods ===

func host_game(port: int = Constants.DEFAULT_SERVER_PORT) -> bool:
	peer = ENetMultiplayerPeer.new()
	var err: int = peer.create_server(port, Constants.MAX_PARTY_SIZE)
	if err != OK:
		GameLogger.error("NetworkManager", "Failed to start server on port %d" % port)
		return false
		
	multiplayer.multiplayer_peer = peer
	role = Constants.NetworkRole.HOST
	GameLogger.info("NetworkManager", "Server started on port %d" % port)
	EventBus.server_created.emit(port)
	return true

func join_game(ip: String, port: int = Constants.DEFAULT_SERVER_PORT) -> bool:
	server_ip = ip
	peer = ENetMultiplayerPeer.new()
	var err: int = peer.create_client(ip, port)
	if err != OK:
		GameLogger.error("NetworkManager", "Failed to connect to %s:%d" % [ip, port])
		return false
		
	multiplayer.multiplayer_peer = peer
	role = Constants.NetworkRole.CLIENT
	GameLogger.info("NetworkManager", "Connecting to server %s:%d..." % [ip, port])
	return true

func disconnect_from_network() -> void:
	if peer:
		peer.close()
	multiplayer.multiplayer_peer = null
	role = Constants.NetworkRole.NONE
	GameLogger.info("NetworkManager", "Disconnected from network.")

# === Private Methods ===

func _on_peer_connected(id: int) -> void:
	GameLogger.info("NetworkManager", "Peer connected: %d" % id)
	EventBus.client_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	GameLogger.info("NetworkManager", "Peer disconnected: %d" % id)
	EventBus.client_disconnected.emit(id, "Disconnected")

func _on_connected_to_server() -> void:
	GameLogger.info("NetworkManager", "Successfully connected to server.")
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	GameLogger.error("NetworkManager", "Connection to server failed.")
	role = Constants.NetworkRole.NONE
	multiplayer.multiplayer_peer = null
	connection_failed.emit()

func _on_server_disconnected() -> void:
	GameLogger.warn("NetworkManager", "Server disconnected.")
	role = Constants.NetworkRole.NONE
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
