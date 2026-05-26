class_name MainMenu
extends Control
## Main Menu UI script.
##
## Handles New Game, Load Game, Settings, and Quit.

@onready var new_game_btn: Button  = $VBoxContainer/NewGameBtn  if has_node("VBoxContainer/NewGameBtn")  else null
@onready var load_game_btn: Button = $VBoxContainer/LoadGameBtn if has_node("VBoxContainer/LoadGameBtn") else null
@onready var settings_btn: Button  = $VBoxContainer/SettingsBtn if has_node("VBoxContainer/SettingsBtn") else null
@onready var quit_btn: Button      = $VBoxContainer/QuitBtn     if has_node("VBoxContainer/QuitBtn")     else null


func _ready() -> void:
	if not new_game_btn:
		GameLogger.warn("MainMenu", "new_game_btn not found!")
	if not quit_btn:
		GameLogger.warn("MainMenu", "quit_btn not found!")

	if new_game_btn:
		new_game_btn.pressed.connect(_on_new_game_pressed)
	if load_game_btn:
		load_game_btn.pressed.connect(_on_load_game_pressed)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings_pressed)
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


func _on_settings_pressed() -> void:
	GameLogger.info("MainMenu", "Opening settings...")
	var settings_scene: PackedScene = load("res://scenes/ui/settings_menu.tscn")
	if not settings_scene:
		GameLogger.error("MainMenu", "Failed to load settings_menu.tscn")
		return
	var instance: Node = settings_scene.instantiate()
	add_child(instance)
	if instance.has_signal("closed"):
		instance.closed.connect(_on_settings_closed)
	_set_buttons_enabled(false)


func _on_settings_closed() -> void:
	_set_buttons_enabled(true)


func _set_buttons_enabled(enabled: bool) -> void:
	if new_game_btn:
		new_game_btn.disabled  = not enabled
	if load_game_btn:
		load_game_btn.disabled = not enabled
	if settings_btn:
		settings_btn.disabled  = not enabled
	if quit_btn:
		quit_btn.disabled      = not enabled


func _on_quit_pressed() -> void:
	GameLogger.info("MainMenu", "Quitting game...")
	GameManager.cleanup_all()
	get_tree().quit()
