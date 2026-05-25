class_name PassiveSkills
extends Node
## Passive skills component.
##
## Always active modifiers that apply buffs to CharacterStats.
## Can be toggled on/off, but not mid-combat per CLAUDE.md.

# === Exports ===
@export var player_stats: CharacterStats

# === Public Variables ===
var active_passives: Dictionary = {} # skill_id -> bool (is_active)

var _passive_database: Dictionary = {
	"toughness": {
		"name": "Toughness",
		"stat": "max_health",
		"multiplier": 1.1 # +10% Max HP
	},
	"fleet_footed": {
		"name": "Fleet Footed",
		"stat": "move_speed",
		"multiplier": 1.15 # +15% Move Speed
	},
	"inner_fire": {
		"name": "Inner Fire",
		"stat": "attack_power",
		"multiplier": 1.1 # +10% Attack Power
	}
}

# === Lifecycle Methods ===

func _ready() -> void:
	if not player_stats:
		var parent: Node = get_parent()
		if parent and "stats" in parent:
			player_stats = parent.stats

# === Public Methods ===

func learn_passive(skill_id: String) -> void:
	if _passive_database.has(skill_id) and not active_passives.has(skill_id):
		active_passives[skill_id] = false
		toggle_passive(skill_id, true)
		GameLogger.info("PassiveSkills", "Learned passive: %s" % _passive_database[skill_id]["name"])

func toggle_passive(skill_id: String, state: bool) -> bool:
	if not active_passives.has(skill_id):
		return false
		
	# Check if in combat (assuming parent or GameManger provides this state in a real implementation)
	# For now, allow toggle.
	
	if active_passives[skill_id] == state:
		return true
		
	active_passives[skill_id] = state
	var data: Dictionary = _passive_database[skill_id]
	
	if player_stats:
		if state:
			player_stats.apply_multiplier(data["stat"], data["multiplier"])
		else:
			player_stats.remove_multiplier(data["stat"])
			
	return true
