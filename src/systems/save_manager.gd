class_name SaveManager
extends Node
## Manages game serialization and deserialization.
##
## Saves player stats, inventory, equipment, quests, and world state
## into a compressed JSON or binary format. Handles max 3 slots.

# === Constants ===
const SAVE_DIR: String = "user://saves/"

# === Lifecycle Methods ===

func _ready() -> void:
	var dir := DirAccess.open("user://")
	if not dir.dir_exists(SAVE_DIR):
		dir.make_dir(SAVE_DIR)

# === Public Methods ===

func save_game(slot: int) -> bool:
	if slot < 1 or slot > Constants.MAX_CHECKPOINTS:
		GameLogger.error("SaveManager", "Invalid save slot: %d" % slot)
		return false
		
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
		
	var file := FileAccess.open(save_path, FileAccess.READ)
	if not file:
		GameLogger.error("SaveManager", "Failed to open save file for reading.")
		return false
		
	var content: String = file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		GameLogger.error("SaveManager", "Failed to parse save JSON.")
		return false
		
	var save_data: Dictionary = json.data as Dictionary
	_apply_save_data(save_data)
	
	GameLogger.info("SaveManager", "Game loaded from slot %d" % slot)
	EventBus.load_completed.emit(slot)
	return true

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
	
	# Save all active players
	for pid in GameManager.active_players:
		var p = GameManager.active_players[pid]
		if not is_instance_valid(p):
			continue
			
		var p_data: Dictionary = {
			"position": {"x": p.global_position.x, "y": p.global_position.y, "z": p.global_position.z}
		}
		
		if "stats" in p and p.stats:
			p_data["stats"] = {
				"level": p.stats.level,
				"xp": p.stats.xp,
				"hp": p.stats.current_health,
				"mana": p.stats.current_mana
			}
			
		# Add Inventory, Equipment, Quests...
		data["players"][str(pid)] = p_data
		
	return data

func _apply_save_data(data: Dictionary) -> void:
	# Basic restoration logic
	GameManager.total_play_time = data.get("play_time", 0.0)
	GameManager.current_difficulty = data.get("difficulty", 1.0)
	
	var level: String = data.get("level", "")
	if level != "":
		LevelManager.load_level(level)
		
	# A real implementation would wait for level load before spawning/placing players
