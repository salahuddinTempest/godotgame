extends Node
## Active skill definitions and execution.
##
## Separates skill logic from the manager. Each skill has mana cost,
## cooldown, damage type, and effect logic.

# === Public Variables ===
var known_skills: Array[String] = []

# Mock database of skills for v0.1
var _skill_database: Dictionary = {
	"power_strike": {
		"name": "Power Strike",
		"mana_cost": 10.0,
		"cooldown": 3.0,
		"damage_multiplier": 1.5,
		"damage_type": Constants.DamageType.PHYSICAL
	},
	"fireball": {
		"name": "Fireball",
		"mana_cost": 25.0,
		"cooldown": 5.0,
		"damage_multiplier": 2.0,
		"damage_type": Constants.DamageType.FIRE
	},
	"heal": {
		"name": "Quick Heal",
		"mana_cost": 30.0,
		"cooldown": 15.0,
		"heal_amount": 50.0,
		"damage_type": Constants.DamageType.HOLY
	}
}

# === Public Methods ===

func knows_skill(skill_id: String) -> bool:
	return _skill_database.has(skill_id) # For prototyping, assume all in DB are known if checked

func get_mana_cost(skill_id: String) -> float:
	if _skill_database.has(skill_id):
		return _skill_database[skill_id].get("mana_cost", 0.0)
	return 0.0

func get_cooldown(skill_id: String) -> float:
	if _skill_database.has(skill_id):
		return _skill_database[skill_id].get("cooldown", 1.0)
	return 1.0

func execute_skill(skill_id: String, caster: Node3D) -> void:
	if not _skill_database.has(skill_id):
		return
		
	var skill_data: Dictionary = _skill_database[skill_id]
	GameLogger.info("ActiveSkills", "Executing %s" % skill_data["name"])
	
	match skill_id:
		"power_strike":
			_execute_melee_attack(caster, skill_data)
		"fireball":
			_execute_projectile(caster, skill_data)
		"heal":
			_execute_self_heal(caster, skill_data)
		_:
			GameLogger.warn("ActiveSkills", "Unimplemented skill execution: %s" % skill_id)

# === Private Methods ===

func _execute_melee_attack(_caster: Node3D, _data: Dictionary) -> void:
	# Raycast forward from caster to find target
	# Calculate damage via CombatEngine
	pass

func _execute_projectile(_caster: Node3D, _data: Dictionary) -> void:
	# Instantiate fireball projectile
	pass

func _execute_self_heal(caster: Node3D, data: Dictionary) -> void:
	# Assumes caster is the Player which has `stats` CharacterStats
	if caster and "stats" in caster:
		var heal_amount: float = data.get("heal_amount", 10.0)
		caster.stats.heal(heal_amount)
