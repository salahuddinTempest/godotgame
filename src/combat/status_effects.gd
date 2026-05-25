class_name StatusEffects
extends Node
## Manages active status effects on a character.
##
## Tracks duration, ticks for DoT (0.5s), stacking (max 20),
## and diminishing returns for Crowd Control.

# === Exports ===
@export var character_stats: CharacterStats

# === Classes ===
class ActiveEffect:
	var id: String
	var type: Constants.StatusEffectType
	var time_left: float
	var tick_timer: float = 0.0
	var tick_interval: float = 0.5 # CLAUDE.md rule
	var stacks: int = 1
	var applier: Node
	var data: Dictionary

# === Public Variables ===
var active_effects: Array[ActiveEffect] = []
var cc_diminishing_returns: Dictionary = {} # effect_id -> count

# === Private Variables ===
var _effect_db: Dictionary = {
	"poison": {
		"name": "Poison",
		"type": Constants.StatusEffectType.DOT,
		"duration": 5.0,
		"tick_damage": 5.0,
		"damage_type": Constants.DamageType.POISON
	},
	"stun": {
		"name": "Stun",
		"type": Constants.StatusEffectType.CROWD_CONTROL,
		"duration": 2.0
	},
	"attack_buff": {
		"name": "Attack Up",
		"type": Constants.StatusEffectType.BUFF,
		"duration": 10.0,
		"stat": "attack_power",
		"multiplier": 1.2
	}
}

# === Lifecycle Methods ===

func _process(delta: float) -> void:
	var to_remove: Array[ActiveEffect] = []
	
	for effect in active_effects:
		effect.time_left -= delta
		
		# Process Ticks
		if effect.type == Constants.StatusEffectType.DOT or effect.type == Constants.StatusEffectType.HOT:
			effect.tick_timer += delta
			if effect.tick_timer >= effect.tick_interval:
				effect.tick_timer -= effect.tick_interval
				_apply_tick(effect)
				
		if effect.time_left <= 0.0:
			to_remove.append(effect)
			
	for effect in to_remove:
		remove_effect(effect.id)

# === Public Methods ===

func add_effect(effect_id: String, applier: Node) -> void:
	if not _effect_db.has(effect_id):
		return
		
	if active_effects.size() >= Constants.MAX_ACTIVE_STATUS_EFFECTS:
		return # Cannot apply more effects
		
	var data: Dictionary = _effect_db[effect_id]
	var type: Constants.StatusEffectType = data["type"]
	var base_duration: float = data["duration"]
	
	# Check diminishing returns for CC
	var final_duration: float = base_duration
	if type == Constants.StatusEffectType.CROWD_CONTROL:
		var cc_count: int = cc_diminishing_returns.get(effect_id, 0)
		final_duration = base_duration / float(1 + cc_count) # Halves each time
		cc_diminishing_returns[effect_id] = cc_count + 1
		if final_duration < 0.5:
			return # Immune if duration gets too short
			
	# Check if already active
	for effect in active_effects:
		if effect.id == effect_id:
			# Refresh duration or add stack
			effect.time_left = final_duration
			# Optional: handle stacking limits here
			return
			
	# Apply new effect
	var new_effect: ActiveEffect = ActiveEffect.new()
	new_effect.id = effect_id
	new_effect.type = type
	new_effect.time_left = final_duration
	new_effect.applier = applier
	new_effect.data = data
	active_effects.append(new_effect)
	
	if type == Constants.StatusEffectType.BUFF or type == Constants.StatusEffectType.DEBUFF:
		_apply_stat_modifier(new_effect, true)
		
	if character_stats:
		var pid: int = _get_parent_id()
		EventBus.status_effect_applied.emit(pid, data["name"], type)

func remove_effect(effect_id: String) -> void:
	for i in range(active_effects.size() - 1, -1, -1):
		var effect: ActiveEffect = active_effects[i]
		if effect.id == effect_id:
			if effect.type == Constants.StatusEffectType.BUFF or effect.type == Constants.StatusEffectType.DEBUFF:
				_apply_stat_modifier(effect, false)
				
			active_effects.remove_at(i)
			if character_stats:
				var pid: int = _get_parent_id()
				EventBus.status_effect_removed.emit(pid, effect.data["name"])
			break

# === Private Methods ===

func _apply_tick(effect: ActiveEffect) -> void:
	if not character_stats or not character_stats.is_alive():
		return
		
	if effect.type == Constants.StatusEffectType.DOT:
		var dmg: float = effect.data.get("tick_damage", 0.0)
		# Skip full damage calculation for ticks, just apply true damage or flat mitigation
		character_stats.take_damage(dmg)
	elif effect.type == Constants.StatusEffectType.HOT:
		var heal: float = effect.data.get("tick_heal", 0.0)
		character_stats.heal(heal)

func _apply_stat_modifier(effect: ActiveEffect, is_applying: bool) -> void:
	if not character_stats or not effect.data.has("stat"):
		return
		
	var stat_name: String = effect.data["stat"]
	var is_debuff: bool = effect.type == Constants.StatusEffectType.DEBUFF
	
	if is_applying:
		character_stats.apply_multiplier(stat_name, effect.data["multiplier"], is_debuff)
	else:
		character_stats.remove_multiplier(stat_name, is_debuff)

func _get_parent_id() -> int:
	var p: Node = get_parent()
	return p.peer_id if p and "peer_id" in p else 0
