class_name DamageCalculator
extends RefCounted
## Core damage math functions.
##
## Implements the CLAUDE.md combat formula:
## damage = (base_atk + skill_bonus) * status_mult * (1.0 - def_reduction) * variance

# === Public Methods ===

static func calculate_hit(attacker: CharacterStats, defender: CharacterStats, skill_data: Dictionary = {}) -> Dictionary:
	var dmg_type: Constants.DamageType = skill_data.get("damage_type", Constants.DamageType.PHYSICAL)
	var skill_mult: float = skill_data.get("damage_multiplier", 1.0)
	var skill_flat: float = skill_data.get("flat_damage", 0.0)
	
	# Base Attack
	var base_atk: float = attacker.get_attack_power() if dmg_type == Constants.DamageType.PHYSICAL else attacker.get_magic_power()
	
	# Skill application
	var raw_damage: float = (base_atk * skill_mult) + skill_flat
	
	# Critical Strike
	var is_crit: bool = randf() < attacker.get_crit_rate()
	if is_crit:
		raw_damage *= 1.5 # 150% crit damage (could be a stat)
		
	# Defense Reduction
	var def_reduction: float = 0.0
	if dmg_type != Constants.DamageType.TRUE_DAMAGE:
		if dmg_type == Constants.DamageType.PHYSICAL:
			def_reduction = defender.get_defense_reduction()
		else:
			var m_resist: float = defender.get_magic_resist()
			def_reduction = m_resist / (m_resist + 100.0) # Same diminishing return formula
			
	var damage_after_defense: float = raw_damage * (1.0 - def_reduction)
	
	# Random Variance (0.85 to 1.15)
	var variance: float = randf_range(Constants.DAMAGE_VARIANCE_MIN, Constants.DAMAGE_VARIANCE_MAX)
	var final_damage: float = damage_after_defense * variance
	
	return {
		"damage": maxf(1.0, final_damage), # Minimum 1 damage
		"is_critical": is_crit
	}
