class_name SkillManager
extends Node
## Manages Player Skills (Active & Passive).
##
## Controls hotkey assignments (slots 1-6), cooldowns, mana costs,
## and toggling passive skills.

# === Exports ===
@export var player_stats: CharacterStats
@export var active_skills: ActiveSkills
@export var passive_skills: PassiveSkills

# === Public Variables ===
var hotkey_bindings: Dictionary = {} # slot_index (1-6) -> String (skill_id)
var active_cooldowns: Dictionary = {} # skill_id -> float (time_left)

# === Lifecycle Methods ===

func _ready() -> void:
	if not active_skills:
		active_skills = get_node_or_null("ActiveSkills") as ActiveSkills
	if not passive_skills:
		passive_skills = get_node_or_null("PassiveSkills") as PassiveSkills
		
	# Initialize default empty bindings
	for i in range(1, Constants.MAX_SKILL_HOTKEYS + 1):
		hotkey_bindings[i] = ""

func _process(delta: float) -> void:
	# Process cooldowns
	var finished_skills: Array = []
	for skill_id: String in active_cooldowns:
		active_cooldowns[skill_id] -= delta
		if active_cooldowns[skill_id] <= 0.0:
			finished_skills.append(skill_id)
			
	for skill_id: String in finished_skills:
		active_cooldowns.erase(skill_id)
		# Find slot for UI event
		for slot: int in hotkey_bindings:
			if hotkey_bindings[slot] == skill_id:
				var pid: int = _get_player_id()
				EventBus.skill_cooldown_finished.emit(pid, slot)
				break

# === Public Methods ===

func bind_skill(slot: int, skill_id: String) -> bool:
	if slot < 1 or slot > Constants.MAX_SKILL_HOTKEYS:
		return false
		
	# Verify skill is known
	if not active_skills or not active_skills.knows_skill(skill_id):
		return false
		
	# Unbind from other slots if it's already bound
	for s: int in hotkey_bindings:
		if hotkey_bindings[s] == skill_id:
			hotkey_bindings[s] = ""
			
	hotkey_bindings[slot] = skill_id
	return true

func activate_slot(slot: int) -> bool:
	if slot < 1 or slot > Constants.MAX_SKILL_HOTKEYS:
		return false
		
	var skill_id: String = hotkey_bindings[slot]
	if skill_id == "":
		return false
		
	return activate_skill(skill_id, slot)

func activate_skill(skill_id: String, slot_for_ui: int = -1) -> bool:
	if not player_stats or not player_stats.is_alive():
		return false
		
	if not active_skills or not active_skills.knows_skill(skill_id):
		return false
		
	if is_on_cooldown(skill_id):
		return false
		
	var mana_cost: float = active_skills.get_mana_cost(skill_id)
	if player_stats.current_mana < mana_cost:
		return false # Not enough mana
		
	# Cast successful
	player_stats.use_mana(mana_cost)
	
	var cooldown: float = active_skills.get_cooldown(skill_id)
	if cooldown > 0.0:
		active_cooldowns[skill_id] = cooldown
		if slot_for_ui > 0:
			var pid: int = _get_player_id()
			EventBus.skill_cooldown_started.emit(pid, slot_for_ui, cooldown)
			
	# Execute skill logic
	active_skills.execute_skill(skill_id, get_parent() as Node3D)
	
	if slot_for_ui > 0:
		var pid: int = _get_player_id()
		EventBus.skill_activated.emit(pid, slot_for_ui, skill_id)
		
	return true

func is_on_cooldown(skill_id: String) -> bool:
	return active_cooldowns.has(skill_id) and active_cooldowns[skill_id] > 0.0

func get_cooldown_left(skill_id: String) -> float:
	return active_cooldowns.get(skill_id, 0.0)

# === Private Methods ===

func _get_player_id() -> int:
	var parent: Node = get_parent()
	if parent and parent is Player:
		return parent.peer_id
	return 1
