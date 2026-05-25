class_name CombatSync
extends Node
## Centralized Server Authority for Combat.
##
## Clients request attacks via RPC, server validates and executes,
## then broadcasts results back to clients.

# === RPC Methods ===

@rpc("any_peer", "call_local", "reliable")
func request_attack(target_path: NodePath, skill_id: String) -> void:
	if not multiplayer.is_server():
		return
		
	var sender_id: int = multiplayer.get_remote_sender_id()
	var attacker: Node = GameManager.get_player(sender_id)
	if not attacker:
		return
		
	var target: Node = get_node_or_null(target_path)
	if not target:
		return
		
	# Validate cooldowns/mana/range on server
	# If valid, process combat
	var skill_data: Dictionary = {} # Would normally look up skill_id in a DB
	
	# Pass to CombatEngine
	var result: Dictionary = CombatEngine.apply_combat_hit(attacker, target, skill_data)
	
	if result["success"]:
		_rpc_broadcast_combat_result.rpc(target_path, result["damage"], result["is_critical"])

@rpc("authority", "call_remote", "reliable")
func _rpc_broadcast_combat_result(target_path: NodePath, damage: float, is_critical: bool) -> void:
	# Clients receive this and show damage numbers, play hit animations, etc.
	var target: Node = get_node_or_null(target_path)
	if target and target.has_method("take_damage_client_visuals"):
		target.take_damage_client_visuals(damage, is_critical)
