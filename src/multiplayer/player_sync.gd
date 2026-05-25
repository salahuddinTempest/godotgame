class_name PlayerSync
extends Node
## Synchronizes player position and animation state across the network.
##
## Attached to Player node. Uses RPCs to send data to server and peers.
## Position sync is unreliable (faster), state sync is reliable.

# === Exports ===
@export var player: Player
@export var sync_interval: float = 0.1 # 100ms per CLAUDE.md

# === Private Variables ===
var _time_since_sync: float = 0.0
var _last_synced_pos: Vector3

# === Lifecycle Methods ===

func _ready() -> void:
	if not player:
		player = get_parent() as Player

func _physics_process(delta: float) -> void:
	if not player or not player.is_local_authority():
		return
		
	_time_since_sync += delta
	if _time_since_sync >= sync_interval:
		_time_since_sync = 0.0
		var current_pos: Vector3 = player.global_position
		
		# Only sync if we moved
		if current_pos.distance_squared_to(_last_synced_pos) > 0.01:
			_last_synced_pos = current_pos
			_rpc_sync_position.rpc(current_pos, player.rotation.y)

# === RPC Methods ===

@rpc("unreliable", "call_remote", "any_peer")
func _rpc_sync_position(pos: Vector3, rot_y: float) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Basic validation: ensure sender matches the player node's owner
	if player and sender_id == player.peer_id:
		# Smoothing/interpolation would go here in a real implementation
		player.global_position = pos
		player.rotation.y = rot_y
