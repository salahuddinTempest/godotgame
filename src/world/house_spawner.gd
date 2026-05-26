class_name HouseSpawner
extends Node3D
## Spawns house instances randomly within a defined area
## while enforcing a minimum distance between each house.
##
## Uses rejection sampling: keeps trying random positions until
## a valid spot is found.  Gives up after [max_attempts] tries
## and logs a warning if some houses could not be placed.

# === Exports ===

@export_group("House Scene")
@export var house_scene: PackedScene

@export_group("Spawn Area")
@export var area_size: Vector2 = Vector2(50.0, 50.0)
@export var area_center: Vector3 = Vector3.ZERO

@export_group("Placement Settings")
@export_range(1, 100) var house_count: int = 10
@export var min_distance: float = 5.0
@export var max_attempts: int = 100

# === Constants ===

const PLACEMENT_Y: float = 0.0

# === Private Variables ===

var _placed_positions: Array[Vector3] = []

# === Lifecycle Methods ===

func _ready() -> void:
	if not house_scene:
		push_error("HouseSpawner: house_scene is not assigned")
		return

	_spawn_houses()

# === Private Methods ===

func _spawn_houses() -> void:
	_placed_positions.clear()
	var spawned: int = 0

	for i in house_count:
		var position: Vector3 = _try_find_position()
		if position != Vector3.INF:
			var house: Node3D = house_scene.instantiate()
			house.position = position
			add_child(house)
			_placed_positions.append(position)
			spawned += 1
		else:
			push_warning("HouseSpawner: could not place house %d/%d after %d attempts" % [i + 1, house_count, max_attempts])
			break

	if spawned < house_count:
		push_warning("HouseSpawner: placed %d/%d houses — area may be too small or min_distance too large" % [spawned, house_count])
	else:
		print("HouseSpawner: placed %d houses successfully" % spawned)

func _try_find_position() -> Vector3:
	for attempt in max_attempts:
		var candidate: Vector3 = _random_position()
		if _is_position_valid(candidate):
			return candidate
	return Vector3.INF

func _random_position() -> Vector3:
	var x: float = randf_range(-area_size.x * 0.5, area_size.x * 0.5)
	var z: float = randf_range(-area_size.y * 0.5, area_size.y * 0.5)
	return Vector3(area_center.x + x, PLACEMENT_Y, area_center.z + z)

func _is_position_valid(candidate: Vector3) -> bool:
	for existing in _placed_positions:
		if candidate.distance_to(existing) < min_distance:
			return false
	return true
