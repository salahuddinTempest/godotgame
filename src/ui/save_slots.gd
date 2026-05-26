class_name SaveSlotsUI
extends Control
## Save slot selection popup.
## Displays 3 save slots with info, handles save/load/delete.

signal back_pressed
signal save_completed(slot: int)

## If true, clicking a slot saves the game there instead of loading.
var save_mode: bool = false

var _save_mgr

@onready var title_label: Label = $VBoxContainer/Title
@onready var slot_btns: Array[Button] = [
	$VBoxContainer/Slot1,
	$VBoxContainer/Slot2,
	$VBoxContainer/Slot3,
]
@onready var back_btn: Button = $VBoxContainer/BackBtn


func _ready() -> void:
	_save_mgr = SaveManager
	back_btn.pressed.connect(_on_back)
	for i in 3:
		slot_btns[i].pressed.connect(_on_slot_pressed.bind(i + 1))

	_refresh_slots()


func _refresh_slots() -> void:
	title_label.text = "Save Game" if save_mode else "Load Game"
	for i in 3:
		var slot: int = i + 1
		var info: Dictionary = _save_mgr.get_save_info(slot)
		var btn: Button = slot_btns[i]
		if info.is_empty():
			btn.text = "Slot %d — Empty" % slot
			btn.disabled = false
		else:
			var lv: int = info.get("level", 0)
			var pt: String = _fmt_time(info.get("play_time", 0.0))
			var ts: String = _fmt_timestamp(info.get("timestamp", 0.0))
			btn.text = "Slot %d  |  Level %d  |  Play %s  |  %s" % [slot, lv, pt, ts]
			btn.disabled = false


func _on_slot_pressed(slot: int) -> void:
	if save_mode:
		_save_mgr.save_game(slot)
		GameLogger.info("SaveSlots", "Game saved to slot %d" % slot)
		save_completed.emit(slot)
		_refresh_slots()
		return

	if not _save_mgr.has_save(slot):
		GameLogger.warn("SaveSlots", "Slot %d has no save" % slot)
		return

	var save_data: Dictionary = _save_mgr.read_save_raw(slot)
	if save_data.is_empty():
		return

	GameManager.pending_save_data = save_data
	GameManager.pending_save_slot = slot

	GameLogger.info("SaveSlots", "Loading save slot %d" % slot)

	var level: String = save_data.get("level", "kingdom_hub")
	var err := get_tree().change_scene_to_file("res://scenes/levels/%s.tscn" % level)
	if err != OK:
		GameLogger.error("SaveSlots", "Failed to load level: %s" % level)
		GameManager.pending_save_data = {}


func _on_back() -> void:
	back_pressed.emit()
	queue_free()


static func _fmt_time(t: float) -> String:
	var h: int = int(t) / 3600
	var m: int = (int(t) % 3600) / 60
	var s: int = int(t) % 60
	return "%02d:%02d:%02d" % [h, m, s]


static func _fmt_timestamp(t: float) -> String:
	if t <= 0.0:
		return "--"
	var dt: Dictionary = Time.get_datetime_dict_from_unix_time(int(t))
	return "%04d-%02d-%02d %02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute]
