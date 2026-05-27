class_name ActiveSkills
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

func _execute_melee_attack(caster: Node3D, data: Dictionary) -> void:
	# Find targets based on opposing groups
	var targets: Array = []
	if caster.is_in_group("enemies"):
		targets = caster.get_tree().get_nodes_in_group("players") + caster.get_tree().get_nodes_in_group("npcs")
	else:
		targets = caster.get_tree().get_nodes_in_group("enemies")
		
	var hit_target: Node3D = null
	var min_dist: float = 3.0 # Attack range
	
	for target in targets:
		if not is_instance_valid(target) or not target.has_method("is_alive") or not target.is_alive():
			continue
		var dist: float = caster.global_position.distance_to(target.global_position)
		if dist < min_dist:
			# Check if target is in front of caster (within ~60 degrees arc)
			var to_target: Vector3 = (target.global_position - caster.global_position).normalized()
			var forward: Vector3 = -caster.global_transform.basis.z.normalized() # Godot -Z is forward
			var dot: float = forward.dot(to_target)
			if dot > 0.5:
				min_dist = dist
				hit_target = target
				
	if hit_target:
		CombatEngine.apply_combat_hit(caster, hit_target, data)
		GameLogger.info("ActiveSkills", "%s hit %s with Power Strike!" % [caster.name, hit_target.name])
	else:
		GameLogger.info("ActiveSkills", "%s executed Power Strike but missed." % caster.name)

func _execute_projectile(caster: Node3D, data: Dictionary) -> void:
	# Find nearest opposing target in front within 15 meters
	var targets: Array = []
	if caster.is_in_group("enemies"):
		targets = caster.get_tree().get_nodes_in_group("players") + caster.get_tree().get_nodes_in_group("npcs")
	else:
		targets = caster.get_tree().get_nodes_in_group("enemies")
		
	var hit_target: Node3D = null
	var min_dist: float = 15.0 # Ranged range
	
	for target in targets:
		if not is_instance_valid(target) or not target.has_method("is_alive") or not target.is_alive():
			continue
		var dist: float = caster.global_position.distance_to(target.global_position)
		if dist < min_dist:
			min_dist = dist
			hit_target = target
			
	if hit_target:
		CombatEngine.apply_combat_hit(caster, hit_target, data)
		GameLogger.info("ActiveSkills", "%s launched a Fireball at %s!" % [caster.name, hit_target.name])
	else:
		GameLogger.info("ActiveSkills", "%s launched a Fireball but found no target." % caster.name)

func _execute_self_heal(caster: Node3D, data: Dictionary) -> void:
	# Assumes caster has `stats` CharacterStats
	if caster and "stats" in caster:
		var heal_amount: float = data.get("heal_amount", 50.0)
		caster.stats.heal(heal_amount)
