class_name LevelManager
extends Node
## Manages level loading, unloading, and transitions.
##
## Autoloaded Singleton to handle level loading
## and cross-scene player persistence.

# === Public Variables ===
static var current_level: Node3D
static var current_level_name: String = ""

# === Public Methods ===

static func load_level(level_name: String) -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return

	GameManager.change_state(Constants.GameState.LOADING)
	EventBus.level_load_started.emit(level_name)

	if current_level:
		EventBus.level_unloaded.emit(current_level_name)
		current_level.queue_free()
		current_level = null

	current_level_name = level_name
	var path: String = "res://scenes/levels/%s.tscn" % level_name

	GameLogger.info("LevelManager", "Loading level: %s" % level_name)

	var packed_scene: PackedScene = load(path) as PackedScene
	if not packed_scene:
		GameLogger.error("LevelManager", "Failed to load level at %s" % path)
		EventBus.level_load_finished.emit("")
		GameManager.change_state(Constants.GameState.MAIN_MENU)
		return

	current_level = packed_scene.instantiate() as Node3D
	tree.root.add_child(current_level)

	_spawn_player()

	GameLogger.info("LevelManager", "Level %s loaded successfully." % current_level_name)
	EventBus.level_load_finished.emit(current_level_name)
	GameManager.change_state(Constants.GameState.IN_GAME)

# === Private Methods ===

static func _spawn_player() -> void:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not tree:
		return

	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	var player: Node3D = player_scene.instantiate()

	var spawn_marker: Marker3D = null
	if current_level:
		spawn_marker = current_level.find_child("SpawnPoint", true, false) as Marker3D

	if spawn_marker:
		player.global_position = spawn_marker.global_position
	else:
		player.global_position = Vector3(0, 2, 0)

	tree.root.add_child(player)

	if player.has_method("is_local_authority") and player.is_local_authority():
		GameManager.register_player(1, player)
