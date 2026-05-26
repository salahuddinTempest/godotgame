class_name MainMenu
extends Control
## Main Menu UI script.
##
## Handles New Game, Load Game, Settings, and Quit.

@onready var new_game_btn: Button = $VBoxContainer/NewGameBtn if has_node("VBoxContainer/NewGameBtn") else null
@onready var load_game_btn: Button = $VBoxContainer/LoadGameBtn if has_node("VBoxContainer/LoadGameBtn") else null
@onready var quit_btn: Button = $VBoxContainer/QuitBtn if has_node("VBoxContainer/QuitBtn") else null


func _ready() -> void:
	if not new_game_btn:
		GameLogger.warn("MainMenu", "new_game_btn not found!")
	if not quit_btn:
		GameLogger.warn("MainMenu", "quit_btn not found!")

	if new_game_btn:
		new_game_btn.pressed.connect(_on_new_game_pressed)
	if load_game_btn:
		load_game_btn.pressed.connect(_on_load_game_pressed)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

	GameManager.pending_save_data = {}
	GameManager.pending_save_slot = 0


func _on_new_game_pressed() -> void:
	GameLogger.info("MainMenu", "Starting new game...")
	GameManager.pending_save_data = {}
	GameManager.pending_save_slot = 0
	GameManager.start_new_game()
	var err := get_tree().change_scene_to_file("res://scenes/levels/kingdom_hub.tscn")
	if err != OK:
		GameLogger.error("MainMenu", "Failed to change scene: " + str(err))


func _on_load_game_pressed() -> void:
	GameLogger.info("MainMenu", "Opening save slots...")
	var slots: PackedScene = load("res://scenes/ui/save_slots.tscn")
	if not slots:
		GameLogger.error("MainMenu", "Failed to load save_slots.tscn")
		return
	var instance: SaveSlotsUI = slots.instantiate()
	add_child(instance)


func _on_quit_pressed() -> void:
	GameLogger.info("MainMenu", "Quitting game...")
	get_tree().quit()
