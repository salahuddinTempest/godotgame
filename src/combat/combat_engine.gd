class_name CombatEngine
extends Node
## Core combat engine for Royal Era: Kingdom Chronicles.
##
## Autoload or Singleton to handle centralized combat logic.
## Delegates damage math to DamageCalculator.

# === Public Methods ===

## Calculates and applies damage from attacker to defender using a specific skill.
static func apply_combat_hit(attacker: Node, defender: Node, skill_data: Dictionary = {}) -> Dictionary:
	# Check if server authority (only server applies damage in co-op, unless singleplayer)
	var attacker_stats: CharacterStats = attacker.stats if "stats" in attacker else null
	var defender_stats: CharacterStats = defender.stats if "stats" in defender else null
	
	if not attacker_stats or not defender_stats:
		return {"success": false, "damage": 0.0, "is_critical": false}
	
	# Check if server authority (only server applies damage in co-op, unless singleplayer)
	var is_server: bool = GameManager.is_host() or GameManager.get_party_size() <= 1
	if not is_server:
		return {"success": true, "damage": 0.0, "is_critical": false} # Wait for server sync
		
	var result: Dictionary = DamageCalculator.calculate_hit(attacker_stats, defender_stats, skill_data)
	var final_damage: float = result["damage"]
	var is_crit: bool = result["is_critical"]
	
	# Apply damage
	var actual_damage: float = defender_stats.take_damage(final_damage)
	
	# Emit global event
	var attacker_id: int = attacker.peer_id if "peer_id" in attacker else 0
	var defender_id: int = defender.peer_id if "peer_id" in defender else 0
	var dmg_type: Constants.DamageType = skill_data.get("damage_type", Constants.DamageType.PHYSICAL)
	
	EventBus.damage_dealt.emit(attacker_id, defender_id, actual_damage, dmg_type, is_crit)
	
	# Handle death
	if not defender_stats.is_alive():
		EventBus.entity_killed.emit(attacker_id, defender_id, defender)
		if "peer_id" in attacker and attacker.peer_id > 0: # If player killed enemy
			var xp_reward: int = defender.get_xp_reward() if defender.has_method("get_xp_reward") else 0
			if xp_reward > 0:
				EventBus.xp_gained.emit(attacker.peer_id, xp_reward)
				
	return {"success": true, "damage": actual_damage, "is_critical": is_crit}
