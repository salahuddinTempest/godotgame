extends Node
## Manages game serialization and deserialization.
##
## Saves player stats, inventory, equipment, quests, and world state
## into a compressed JSON or binary format. Handles max 3 slots.

# === Constants ===
const SAVE_DIR: String = "user://saves/"
const SLOT_COUNT: int = 3

# === Lifecycle Methods ===

func _ready() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

# === Public Methods ===

func save_game(slot: int) -> bool:
	if slot < 1 or slot > SLOT_COUNT:
		GameLogger.error("SaveManager", "Invalid save slot: %d" % slot)
		return false

	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

	var save_path: String = SAVE_DIR + "save_slot_%d.json" % slot
	var save_data: Dictionary = _gather_save_data()

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if not file:
		GameLogger.error("SaveManager", "Failed to open save file for writing.")
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	GameLogger.info("SaveManager", "Game saved to slot %d" % slot)
	EventBus.save_completed.emit(slot)
	return true


func load_game(slot: int) -> bool:
	var save_path: String = SAVE_DIR + "save_slot_%d.json" % slot
	if not FileAccess.file_exists(save_path):
		GameLogger.error("SaveManager", "Save file does not exist: %d" % slot)
		return false

	var data: Dictionary = read_save_raw(slot)
	if data.is_empty():
		return false

	_apply_save_data(data)

	GameLogger.info("SaveManager", "Game loaded from slot %d" % slot)
	EventBus.load_completed.emit(slot)
	return true


func has_save(slot: int) -> bool:
	var path: String = SAVE_DIR + "save_slot_%d.json" % slot
	return FileAccess.file_exists(path)


func get_save_info(slot: int) -> Dictionary:
	if not has_save(slot):
		return {}

	var data: Dictionary = read_save_raw(slot)
	if data.is_empty():
		return {}

	return {
		"timestamp": data.get("timestamp", 0.0),
		"play_time": data.get("play_time", 0.0),
		"level": _get_player_level(data),
		"level_name": data.get("level", ""),
	}


func read_save_raw(slot: int) -> Dictionary:
	var save_path: String = SAVE_DIR + "save_slot_%d.json" % slot
	if not FileAccess.file_exists(save_path):
		return {}

	var file := FileAccess.open(save_path, FileAccess.READ)
	if not file:
		return {}
	var content: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(content) != OK:
		return {}
	return json.data as Dictionary


func delete_save(slot: int) -> void:
	var save_path: String = SAVE_DIR + "save_slot_%d.json" % slot
	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path)
		GameLogger.info("SaveManager", "Deleted save slot %d" % slot)

# === Private Methods ===

func _gather_save_data() -> Dictionary:
	var data: Dictionary = {
		"version": GameManager.GAME_VERSION,
		"timestamp": Time.get_unix_time_from_system(),
		"play_time": GameManager.total_play_time,
		"difficulty": GameManager.current_difficulty,
		"level": LevelManager.current_level_name,
		"players": {}
	}

	for pid in GameManager.active_players:
		var p = GameManager.active_players[pid]
		if not is_instance_valid(p):
			continue

		var p_data: Dictionary = {
			"position": {"x": p.global_position.x, "y": p.global_position.y, "z": p.global_position.z}
		}

		if "stats" in p and p.stats:
			var s: CharacterStats = p.stats
			p_data["stats"] = {
				"level": s.level,
				"xp": s.xp,
				"hp": s.current_health,
				"mana": s.current_mana,
				"max_hp": s.get_max_health(),
				"max_mana": s.get_max_mana(),
			}

		data["players"][str(pid)] = p_data

	return data


func _apply_save_data(data: Dictionary) -> void:
	GameManager.total_play_time = data.get("play_time", 0.0)
	GameManager.current_difficulty = data.get("difficulty", 1.0)

	var level: String = data.get("level", "")
	if level != "":
		LevelManager.load_level(level)


func _get_player_level(data: Dictionary) -> int:
	var players: Dictionary = data.get("players", {})
	for pid in players:
		var pdata: Dictionary = players[pid] as Dictionary
		var stats: Dictionary = pdata.get("stats", {})
		return stats.get("level", 0)
	return 0
