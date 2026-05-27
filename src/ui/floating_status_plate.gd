class_name FloatingStatusPlate
extends Node3D
## Controls the floating status plate displaying Health, Hunger, Thirst, and Fatigue.

# Node references
@onready var sprite_3d: Sprite3D = $Sprite3D if has_node("Sprite3D") else null
@onready var health_bar: ProgressBar = $SubViewport/Container/HealthBar if has_node("SubViewport/Container/HealthBar") else null
@onready var hunger_bar: ProgressBar = $SubViewport/Container/HungerBar if has_node("SubViewport/Container/HungerBar") else null
@onready var thirst_bar: ProgressBar = $SubViewport/Container/ThirstBar if has_node("SubViewport/Container/ThirstBar") else null
@onready var fatigue_bar: ProgressBar = $SubViewport/Container/FatigueBar if has_node("SubViewport/Container/FatigueBar") else null

var parent_character: Node3D = null

func _ready() -> void:
	parent_character = get_parent() as Node3D
	
	# Set Sprite3D texture to Viewport texture dynamically
	if sprite_3d and has_node("SubViewport"):
		var viewport: SubViewport = get_node("SubViewport") as SubViewport
		if viewport:
			sprite_3d.texture = viewport.get_texture()

func _process(_delta: float) -> void:
	if not is_instance_valid(parent_character):
		return
		
	# Update Health
	if "stats" in parent_character and parent_character.stats and health_bar:
		var stats: CharacterStats = parent_character.stats
		health_bar.max_value = stats.get_max_health()
		health_bar.value = stats.current_health
		
	# Update Survival Needs
	if "needs_manager" in parent_character and parent_character.needs_manager:
		var manager = parent_character.needs_manager
		if manager.hunger and hunger_bar:
			hunger_bar.value = manager.hunger.current_hunger
		if manager.thirst and thirst_bar:
			thirst_bar.value = manager.thirst.current_thirst
		if manager.fatigue and fatigue_bar:
			fatigue_bar.value = manager.fatigue.current_fatigue
