extends Node3D

enum HouseType { PLASTER, BRICK, PLASTER_WINDOW }

func _ready() -> void:
	spawn_player()
	build_village()


func spawn_player() -> void:
	var player_scene: PackedScene = load("res://scenes/entities/player.tscn")
	if not player_scene:
		return
	var player: Node3D = player_scene.instantiate()
	add_child(player)
	var spawn: Marker3D = get_node_or_null("SpawnPoint") as Marker3D
	if spawn:
		player.global_position = spawn.global_position
	else:
		player.global_position = Vector3(0, 2, 0)
	GameManager.change_state(Constants.GameState.IN_GAME)


func _load_scene(path: String) -> Node3D:
	var doc: GLTFDocument = GLTFDocument.new()
	var state: GLTFState = GLTFState.new()
	var err: Error = doc.append_from_file(path, state)
	if err != OK:
		push_error("Failed to load %s: %s" % [path, err])
		return Node3D.new()
	var root: Node = doc.generate_scene(state)
	if not root:
		return Node3D.new()
	return root


func _make_static_wall(path: String, pos: Vector3, rot_y: float, size: Vector3) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.position = pos
	if rot_y != 0:
		body.rotation_degrees.y = rot_y

	var visual: Node3D = _load_scene(path)
	body.add_child(visual)

	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = size
	col_shape.shape = box
	col_shape.position = Vector3(0, size.y * 0.5, 0)
	body.add_child(col_shape)

	return body


func _add_collision(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var col_shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = size
	col_shape.shape = box
	col_shape.position = pos + Vector3(0, size.y * 0.5, 0)
	parent.add_child(col_shape)


func build_village() -> void:
	var village: Node3D = Node3D.new()
	village.name = "Village"
	add_child(village)

	var positions: Array[Vector3] = [
		Vector3(-10, 0, -4),
		Vector3(-5, 0, -4),
		Vector3(0, 0, -4),
		Vector3(5, 0, -4),
		Vector3(10, 0, -4),
		Vector3(-10, 0, 4),
		Vector3(-5, 0, 4),
		Vector3(0, 0, 4),
		Vector3(5, 0, 4),
		Vector3(10, 0, 4),
	]

	var types: Array[HouseType] = [
		HouseType.PLASTER,     # -10, -4 : south row
		HouseType.BRICK,       # -5, -4
		HouseType.PLASTER_WINDOW, # 0, -4
		HouseType.BRICK,       # 5, -4
		HouseType.PLASTER,     # 10, -4
		HouseType.BRICK,       # -10, 4 : north row
		HouseType.PLASTER_WINDOW, # -5, 4
		HouseType.PLASTER,     # 0, 4
		HouseType.BRICK,       # 5, 4
		HouseType.PLASTER_WINDOW, # 10, 4
	]

	var facings: Array[int] = [1, 1, 1, 1, 1, -1, -1, -1, -1, -1]

	for i in 10:
		build_house(village, positions[i], facings[i], types[i])

	build_roads(village)
	build_decoration(village)


func build_house(parent: Node, pos: Vector3, facing: int, house_type: HouseType) -> void:
	var house: Node3D = Node3D.new()
	house.position = pos
	if facing < 0:
		house.rotation_degrees.y = 180

	var wall_mat: String
	match house_type:
		HouseType.BRICK:
			wall_mat = "res://assets/models/village/Wall_UnevenBrick_Straight.gltf"
		_:
			wall_mat = "res://assets/models/village/Wall_Plaster_Straight.gltf"

	var door_path: String = "res://assets/models/village/Wall_Plaster_Door_Round.gltf"
	var window_path: String = "res://assets/models/village/Wall_Plaster_Window_Wide_Round.gltf"

	var wall_size: Vector3 = Vector3(2.3, 3.0, 0.4)

	var front: StaticBody3D = _make_static_wall(door_path, Vector3(0, 0, 1.15), 0, wall_size)
	house.add_child(front)

	var back: StaticBody3D = _make_static_wall(wall_mat, Vector3(0, 0, -1.15), 0, wall_size)
	house.add_child(back)

	if house_type == HouseType.PLASTER_WINDOW:
		var left: StaticBody3D = _make_static_wall(window_path, Vector3(-1.15, 0, 0), -90, wall_size)
		house.add_child(left)
		var right: StaticBody3D = _make_static_wall(window_path, Vector3(1.15, 0, 0), 90, wall_size)
		house.add_child(right)
	else:
		var left: StaticBody3D = _make_static_wall(wall_mat, Vector3(-1.15, 0, 0), -90, wall_size)
		house.add_child(left)
		var right: StaticBody3D = _make_static_wall(wall_mat, Vector3(1.15, 0, 0), 90, wall_size)
		house.add_child(right)

	var floor: Node3D = _load_scene("res://assets/models/village/Floor_RedBrick.gltf")
	floor.position = Vector3(0, 0, 0)
	_add_collision(floor, Vector3(0, 0, 0), Vector3(2.8, 0.1, 2.8))
	house.add_child(floor)

	var roof_path: String
	if house_type == HouseType.PLASTER_WINDOW or house_type == HouseType.BRICK:
		roof_path = "res://assets/models/village/Roof_RoundTiles_4x6.gltf"
	else:
		roof_path = "res://assets/models/village/Roof_RoundTiles_6x8.gltf"
	var roof: Node3D = _load_scene(roof_path)
	roof.position = Vector3(0, 3.6, 0)
	house.add_child(roof)

	build_yard(house, house_type)

	parent.add_child(house)


func build_yard(house: Node3D, house_type: HouseType) -> void:
	var yard: Node3D = Node3D.new()
	yard.name = "Yard"
	house.add_child(yard)

	var yd: float = 2.0
	var fence_path: String = "res://assets/models/village/fence.glb"
	var fence_count: int = 4

	for i in range(fence_count):
		var fx: float = lerpf(-1.5, 1.5, float(i) / float(fence_count - 1))
		var abs_fx: float = abs(fx)
		if abs_fx < 0.4:
			continue
		var fence: Node3D = _load_scene(fence_path)
		fence.position = Vector3(fx, 0, yd)
		_add_collision(fence, Vector3(0, 0, 0), Vector3(0.8, 1.2, 0.15))
		yard.add_child(fence)

	var fence_back: Node3D = _load_scene(fence_path)
	fence_back.position = Vector3(0, 0, -yd)
	fence_back.scale = Vector3(2.0, 1.0, 1.0)
	_add_collision(fence_back, Vector3(0, 0, 0), Vector3(3.0, 1.2, 0.15))
	yard.add_child(fence_back)

	var fence_left: Node3D = _load_scene(fence_path)
	fence_left.position = Vector3(-yd, 0, 0)
	fence_left.rotation_degrees.y = 90
	fence_left.scale = Vector3(1.5, 1.0, 1.0)
	_add_collision(fence_left, Vector3(0, 0, 0), Vector3(0.15, 1.2, 3.0))
	yard.add_child(fence_left)

	var fence_right: Node3D = _load_scene(fence_path)
	fence_right.position = Vector3(yd, 0, 0)
	fence_right.rotation_degrees.y = 90
	fence_right.scale = Vector3(1.5, 1.0, 1.0)
	_add_collision(fence_right, Vector3(0, 0, 0), Vector3(0.15, 1.2, 3.0))
	yard.add_child(fence_right)


func build_roads(parent: Node) -> void:
	var roads: Node3D = Node3D.new()
	roads.name = "Roads"
	parent.add_child(roads)

	var road_path: String = "res://assets/models/village/road.glb"
	var road_positions: Array[Vector3] = [
		Vector3(-17.5, 0, 0),
		Vector3(-12.5, 0, 0),
		Vector3(-7.5, 0, 0),
		Vector3(-2.5, 0, 0),
		Vector3(2.5, 0, 0),
		Vector3(7.5, 0, 0),
		Vector3(12.5, 0, 0),
		Vector3(17.5, 0, 0),
	]

	for rp in road_positions:
		var road: Node3D = _load_scene(road_path)
		road.position = rp
		_add_collision(road, Vector3(0, 0, 0), Vector3(5.5, 0.05, 5.5))
		roads.add_child(road)

	var connector_positions: Array[Vector3] = [
		Vector3(-17.5, 0, -3.0),
		Vector3(-17.5, 0, 3.0),
		Vector3(17.5, 0, -3.0),
		Vector3(17.5, 0, 3.0),
	]

	for cp in connector_positions:
		var road: Node3D = _load_scene(road_path)
		road.position = cp
		road.rotation_degrees.y = 90
		_add_collision(road, Vector3(0, 0, 0), Vector3(5.5, 0.05, 5.5))
		roads.add_child(road)


func build_decoration(parent: Node) -> void:
	var decor: Node3D = Node3D.new()
	decor.name = "Decorations"
	parent.add_child(decor)

	var tree_path: String = "res://assets/models/village/tree.glb"
	var tree_positions: Array[Vector3] = [
		Vector3(-10.5, 0, -1.5),
		Vector3(-3.5, 0, -1.5),
		Vector3(3.5, 0, -1.5),
		Vector3(10.5, 0, -1.5),
		Vector3(-10.5, 0, 1.5),
		Vector3(-3.5, 0, 1.5),
		Vector3(3.5, 0, 1.5),
		Vector3(10.5, 0, 1.5),
	]
	for tp in tree_positions:
		var tree: Node3D = _load_scene(tree_path)
		tree.position = tp
		var s: float = 1.0 + randf() * 0.3
		tree.scale = Vector3(s, s, s)
		tree.rotation_degrees.y = randf() * 360.0
		_add_collision(tree, Vector3(0, 1, 0), Vector3(0.8, 2.0, 0.8))
		decor.add_child(tree)

	var fountain: Node3D = _load_scene("res://assets/models/village/fountain-round.glb")
	fountain.position = Vector3(12, 0, 0)
	_add_collision(fountain, Vector3(0, 0.5, 0), Vector3(2.0, 1.0, 2.0))
	decor.add_child(fountain)

	var stall: Node3D = _load_scene("res://assets/models/village/stall.glb")
	stall.position = Vector3(-7, 0, 0)
	stall.rotation_degrees.y = 180
	_add_collision(stall, Vector3(0, 0.5, 0), Vector3(1.5, 1.5, 1.0))
	decor.add_child(stall)

	var cart: Node3D = _load_scene("res://assets/models/village/cart.glb")
	cart.position = Vector3(7, 0, -6)
	_add_collision(cart, Vector3(0, 0.5, 0), Vector3(1.5, 1.0, 1.0))
	decor.add_child(cart)

	var lantern_path: String = "res://assets/models/village/lantern.glb"
	var lantern_positions: Array[Vector3] = [
		Vector3(-10, 0, -2),
		Vector3(-5, 0, -2),
		Vector3(0, 0, -2),
		Vector3(5, 0, -2),
		Vector3(10, 0, -2),
		Vector3(-10, 0, 2),
		Vector3(-5, 0, 2),
		Vector3(0, 0, 2),
		Vector3(5, 0, 2),
		Vector3(10, 0, 2),
	]
	for lp in lantern_positions:
		var lantern: Node3D = _load_scene(lantern_path)
		lantern.position = lp
		_add_collision(lantern, Vector3(0, 0.5, 0), Vector3(0.3, 1.0, 0.3))
		decor.add_child(lantern)
