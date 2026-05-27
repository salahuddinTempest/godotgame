## Settings Menu — Options, Audio, Controls (keybinding remapper)
## Path: res://scenes/ui/settings_menu.tscn
class_name SettingsMenu
extends Control

signal closed()

# All remappable actions with their display names (in Indonesian)
const REMAPPABLE_ACTIONS: Array[Dictionary] = [
	{action = "move_forward",     label = "Gerak Maju"},
	{action = "move_backward",    label = "Gerak Mundur"},
	{action = "move_left",        label = "Gerak Kiri"},
	{action = "move_right",       label = "Gerak Kanan"},
	{action = "jump",             label = "Lompat"},
	{action = "sprint",           label = "Lari Cepat"},
	{action = "interact",         label = "Interaksi"},
	{action = "attack_basic",     label = "Serang Dasar"},
	{action = "skill_slot_1",     label = "Skill 1"},
	{action = "skill_slot_2",     label = "Skill 2"},
	{action = "skill_slot_3",     label = "Skill 3"},
	{action = "skill_slot_4",     label = "Skill 4"},
	{action = "skill_slot_5",     label = "Skill 5"},
	{action = "skill_slot_6",     label = "Skill 6"},
	{action = "toggle_view",      label = "Ganti Kamera FPP/TPP"},
	{action = "pause_menu",       label = "Pause / Menu"},
	{action = "toggle_inventory", label = "Buka Inventori"},
	{action = "toggle_character", label = "Buka Karakter"},
	{action = "toggle_quest_log", label = "Buka Quest Log"},
	{action = "toggle_map",       label = "Buka Peta"},
]

# The action currently waiting for a new key
var _rebinding_action: String = ""
var _rebinding_btn: Button = null

# Reference to player if in game (for camera mode toggle)
var _player: Player = null

@onready var tab_container: TabContainer = $Panel/VBox/TabContainer
@onready var controls_scroll: ScrollContainer = $Panel/VBox/TabContainer/Controls/ScrollContainer
@onready var controls_vbox: VBoxContainer = $Panel/VBox/TabContainer/Controls/ScrollContainer/VBox
@onready var close_btn: Button = $Panel/VBox/CloseBtn
@onready var camera_mode_option: OptionButton = $Panel/VBox/TabContainer/Video/CameraModeRow/ModeOption


func _ready() -> void:
	close_btn.pressed.connect(_on_close_pressed)
	_populate_controls()
	_setup_camera_tab()

	# Find player in scene (if in game)
	var players := get_tree().get_nodes_in_group("players")
	if players.size() > 0 and players[0] is Player:
		_player = players[0]


func _setup_camera_tab() -> void:
	camera_mode_option.clear()
	camera_mode_option.add_item("Third Person (TPP)", 0)
	camera_mode_option.add_item("First Person (FPP)", 1)

	if _player:
		camera_mode_option.selected = 0 if _player.is_third_person else 1
	else:
		camera_mode_option.selected = 0

	camera_mode_option.item_selected.connect(_on_camera_mode_selected)


func _on_camera_mode_selected(index: int) -> void:
	var tpp: bool = (index == 0)
	if _player:
		_player.set_camera_mode(tpp)
		GameLogger.info("SettingsMenu", "Camera mode switched to %s" % ["TPP", "FPP"][index])
	else:
		GameLogger.warn("SettingsMenu", "No player found to switch camera mode")


func _populate_controls() -> void:
	# Clear existing rows
	for child in controls_vbox.get_children():
		child.queue_free()

	for entry in REMAPPABLE_ACTIONS:
		var action: String = entry["action"]
		var label_text: String = entry["label"]
		_add_control_row(action, label_text)


func _add_control_row(action: String, label_text: String) -> void:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 12)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 16)
	row.add_child(lbl)

	var key_btn := Button.new()
	key_btn.text = _get_key_label(action)
	key_btn.custom_minimum_size = Vector2(160, 36)
	key_btn.name = "KeyBtn_" + action
	key_btn.pressed.connect(_on_rebind_pressed.bind(action, key_btn))
	row.add_child(key_btn)

	var clear_btn := Button.new()
	clear_btn.text = "✕"
	clear_btn.tooltip_text = "Hapus binding"
	clear_btn.custom_minimum_size = Vector2(36, 36)
	clear_btn.pressed.connect(_on_clear_binding.bind(action, key_btn))
	row.add_child(clear_btn)

	controls_vbox.add_child(row)


func _get_key_label(action: String) -> String:
	if not InputMap.has_action(action):
		return "(tidak tersedia)"
	var events := InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			return event.as_text_physical_keycode()
		if event is InputEventMouseButton:
			return "Klik %s" % _mouse_btn_name(event.button_index)
	return "(tidak ada)"


func _mouse_btn_name(idx: int) -> String:
	match idx:
		MOUSE_BUTTON_LEFT:   return "Kiri"
		MOUSE_BUTTON_RIGHT:  return "Kanan"
		MOUSE_BUTTON_MIDDLE: return "Tengah"
		_:                   return "Mouse %d" % idx


func _on_rebind_pressed(action: String, btn: Button) -> void:
	_rebinding_action = action
	_rebinding_btn    = btn
	btn.text          = "[ Tekan tombol… ]"
	btn.focus_mode    = Control.FOCUS_ALL
	btn.grab_focus()


func _on_clear_binding(action: String, btn: Button) -> void:
	if not InputMap.has_action(action):
		return
	# Clear only keyboard events, keep gamepad bindings intact
	var events := InputMap.action_get_events(action)
	for ev in events:
		if ev is InputEventKey or ev is InputEventMouseButton:
			InputMap.action_erase_event(action, ev)
	btn.text = "(tidak ada)"
	_rebinding_action = ""
	_rebinding_btn = null


func _input(event: InputEvent) -> void:
	if _rebinding_action.is_empty():
		return

	# Only process key-down or mouse-button press
	var is_key_down   := event is InputEventKey and (event as InputEventKey).pressed
	var is_mouse_down := event is InputEventMouseButton and (event as InputEventMouseButton).pressed

	if not (is_key_down or is_mouse_down):
		return

	# Ignore Escape — cancel rebind
	if event is InputEventKey and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
		if _rebinding_btn:
			_rebinding_btn.text = _get_key_label(_rebinding_action)
		_rebinding_action = ""
		_rebinding_btn = null
		get_viewport().set_input_as_handled()
		return

	# Replace keyboard/mouse bindings for this action (keep gamepad intact)
	var old_events := InputMap.action_get_events(_rebinding_action)
	for ev in old_events:
		if ev is InputEventKey or ev is InputEventMouseButton:
			InputMap.action_erase_event(_rebinding_action, ev)

	# Add the new event (with pressed=false so it fires on release in-game)
	var new_event := event.duplicate()
	if new_event is InputEventKey:
		(new_event as InputEventKey).pressed = false
	InputMap.action_add_event(_rebinding_action, new_event)

	if _rebinding_btn:
		_rebinding_btn.text = _get_key_label(_rebinding_action)

	# If rebinding toggle_view, also update player camera mode listener
	if _rebinding_action == "toggle_view" and _player:
		GameLogger.info("SettingsMenu", "toggle_view rebound — use key in game to switch FPP/TPP")

	_rebinding_action = ""
	_rebinding_btn = null
	get_viewport().set_input_as_handled()


func _on_close_pressed() -> void:
	closed.emit()
	queue_free()
