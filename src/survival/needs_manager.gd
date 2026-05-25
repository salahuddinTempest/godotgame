class_name NeedsManager
extends Node
## Unified survival needs manager.
##
## Integrates Hunger, Thirst, and Fatigue. Applies state penalties
## to CharacterStats when critical.

# === Exports ===
@export var character_stats: CharacterStats
@export var equipment: Equipment

# === Onready ===
@onready var hunger: HungerSystem = $HungerSystem if has_node("HungerSystem") else null
@onready var thirst: ThirstSystem = $ThirstSystem if has_node("ThirstSystem") else null
@onready var fatigue: FatigueSystem = $FatigueSystem if has_node("FatigueSystem") else null

# === Lifecycle Methods ===

func _ready() -> void:
	if not character_stats:
		var parent: Node = get_parent()
		if parent and "stats" in parent:
			character_stats = parent.stats
	if not equipment:
		var parent: Node = get_parent()
		if parent and "equipment" in parent:
			equipment = parent.equipment
			
	if not hunger:
		hunger = HungerSystem.new()
		add_child(hunger)
	if not thirst:
		thirst = ThirstSystem.new()
		add_child(thirst)
	if not fatigue:
		fatigue = FatigueSystem.new()
		add_child(fatigue)
		
	hunger.setup(self)
	thirst.setup(self)
	fatigue.setup(self)

func _process(delta: float) -> void:
	if not _is_active():
		return
		
	var is_combat: bool = equipment.is_in_combat if equipment else false
	# Determine if sprinting from parent player
	var is_sprinting: bool = false
	var parent: Node = get_parent()
	if parent and "is_sprinting" in parent:
		is_sprinting = parent.is_sprinting
		
	var active_state: bool = is_combat or is_sprinting
	
	hunger.process_tick(delta, active_state)
	thirst.process_tick(delta, active_state)
	fatigue.process_tick(delta, active_state)

# === Private Methods ===

func _is_active() -> bool:
	if not character_stats:
		return false
	if not character_stats.is_alive():
		return false
	if GameManager.current_state != Constants.GameState.IN_GAME:
		return false
	return true
