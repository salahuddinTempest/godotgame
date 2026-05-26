class_name PauseMenu
extends Control
## Pause overlay with Resume / Save / Load / Settings / Quit.

signal resume_pressed
signal quit_to_menu_pressed

var _save_slots_scene: PackedScene = preload("res://scenes/ui/save_slots.tscn")


@onready var resume_btn: Button   = $MarginContainer/VBoxContainer/ResumeBtn
@onready var save_btn: Button     = $MarginContainer/VBoxContainer/SaveBtn
@onready var load_btn: Button     = $MarginContainer/VBoxContainer/LoadBtn
@onready var settings_btn: Button = $MarginContainer/VBoxContainer/SettingsBtn
@onready var quit_btn: Button     = $MarginContainer/VBoxContainer/QuitBtn


func _ready() -> void:
	resume_btn.pressed.connect(_on_resume)
	save_btn.pressed.connect(_on_save)
	load_btn.pressed.connect(_on_load)
	if settings_btn:
		settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") or event.is_action_pressed("ui_close"):
		if not _has_sub_popup():
			get_viewport().set_input_as_handled()
			_on_resume()


func _has_sub_popup() -> bool:
	for c in get_children():
		if c is SaveSlotsUI or c.get_script() != null and c.get_script().resource_path.contains("settings_menu"):
			return true
	return false


func _on_resume() -> void:
	resume_pressed.emit()
	queue_free()


func _on_save() -> void:
	var instance: SaveSlotsUI = _save_slots_scene.instantiate()
	instance.save_mode = true
	add_child(instance)
	instance.back_pressed.connect(_on_slots_closed)


func _on_load() -> void:
	var instance: SaveSlotsUI = _save_slots_scene.instantiate()
	instance.save_mode = false
	add_child(instance)
	instance.back_pressed.connect(_on_slots_closed)


func _on_settings() -> void:
	var settings_scene: PackedScene = load("res://scenes/ui/settings_menu.tscn")
	if not settings_scene:
		GameLogger.error("PauseMenu", "Failed to load settings_menu.tscn")
		return
	var instance: Node = settings_scene.instantiate()
	add_child(instance)
	if instance.has_signal("closed"):
		instance.closed.connect(_on_settings_closed)
	_set_buttons_enabled(false)


func _on_settings_closed() -> void:
	_set_buttons_enabled(true)


func _set_buttons_enabled(enabled: bool) -> void:
	resume_btn.disabled   = not enabled
	save_btn.disabled     = not enabled
	load_btn.disabled     = not enabled
	if settings_btn:
		settings_btn.disabled = not enabled
	quit_btn.disabled     = not enabled


func _on_slots_closed() -> void:
	pass


func _on_quit() -> void:
	quit_to_menu_pressed.emit()
	GameManager.pending_save_data = {}
	GameManager.pending_save_slot = 0
	get_tree().paused = false
	GameManager.change_state(Constants.GameState.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
