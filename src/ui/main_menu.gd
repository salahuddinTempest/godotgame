class_name MainMenu
extends Control
## Main Menu UI script.
##
## Handles New Game, Load Game, Settings, and Quit.

# === Onready ===
@onready var new_game_btn: Button = $VBoxContainer/NewGameBtn if has_node("VBoxContainer/NewGameBtn") else null
@onready var load_game_btn: Button = $VBoxContainer/LoadGameBtn if has_node("VBoxContainer/LoadGameBtn") else null
@onready var quit_btn: Button = $VBoxContainer/QuitBtn if has_node("VBoxContainer/QuitBtn") else null

# === Lifecycle Methods ===

func _ready() -> void:
	
	# Warn if buttons not found
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

# === Private Methods ===

func _on_new_game_pressed() -> void:
	GameLogger.info("MainMenu", "Starting new game...")
	GameManager.start_new_game()
	var err := get_tree().change_scene_to_file("res://scenes/levels/kingdom_hub.tscn")
	if err != OK:
		GameLogger.error("MainMenu", "Failed to change scene: " + str(err))

func _on_load_game_pressed() -> void:
	# Show save slot UI, then call SaveManager
	pass

func _on_quit_pressed() -> void:
	GameLogger.info("MainMenu", "Quitting game...")
	get_tree().quit()
