@tool
extends Node3D

enum HouseType { PLASTER, BRICK, WOOD, STONE }

var _pause_menu_scene: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
var _pause_menu: Control = null
var _pause_layer: CanvasLayer = null

@export_group("House Placement")
@export var house_count: int = 6
@export var min_distance: float = 22.0
@export var area_size: Vector2 = Vector2(80.0, 80.0)
@export var max_placement_attempts: int = 300

# === Dimensions ===
const HW: float = 5.0         # house width & depth
const WH: float = 3.0         # wall height
const WT: float = 0.4         # wall thickness
const WO: float = 5.2         # wall visual width (overlap at corners)
const YD: float = 10.0        # yard perimeter
const FH: float = 1.2         # fence height

const _ORIG: Dictionary = {
	"kaykit_wall": Vector3(2.0, 3.0, 0.4),
	"kaykit_floor": Vector3(2.0, 0.02, 2.0),
	"kaykit_roof_l": Vector3(8.0, 5.3, 11.7),
	"kaykit_roof_m": Vector3(8.0, 5.3, 9.6),
	"kenney_wall": Vector3(1.0, 1.0, 0.2),
	"kenney_roof": Vector3(2.0, 1.0, 2.0),
	"kenney_road": Vector3(1.0, 0.1, 1.0),
}


func _ready() -> void:
	randomize()
	if Engine.is_editor_hint():
		build_village()
		return
	LevelManager.current_level = self
	LevelManager.current_level_name = "kingdom_hub"
	spawn_player()
	build_village()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		if _pause_layer and is_instance_valid(_pause_layer):
			return
		if Engine.is_editor_hint():
			return
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_pause_layer = CanvasLayer.new()
		_pause_layer.layer = 128
		_pause_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		
		_pause_menu = _pause_menu_scene.instantiate()
		_pause_layer.add_child(_pause_menu)
		add_child(_pause_layer)
		
		_pause_menu.resume_pressed.connect(_on_pause_resume)
		_pause_menu.quit_to_menu_pressed.connect(_on_pause_quit)
		GameManager.pause_game()


func _on_pause_resume() -> void:
	if _pause_layer and is_instance_valid(_pause_layer):
		_pause_layer.queue_free()
	_pause_layer = null
	_pause_menu = null
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	GameManager.resume_game()


func _on_pause_quit() -> void:
	if _pause_layer and is_instance_valid(_pause_layer):
		_pause_layer.queue_free()
	_pause_layer = null
	_pause_menu = null



func spawn_player() -> void:
	var ps: PackedScene = load("res://scenes/entities/player.tscn")
	if not ps:
		return
	var p: Node3D = ps.instantiate()
	add_child(p)

	var save_data: Dictionary = GameManager.pending_save_data
	var is_loading: bool = not save_data.is_empty()

	if is_loading:
		_restore_from_save(p, save_data)
	else:
		var sp: Marker3D = get_node_or_null("SpawnPoint") as Marker3D
		p.global_position = sp.global_position if sp else Vector3(0, 2, 0)

	GameManager.pending_save_data = {}
	GameManager.pending_save_slot = 0
	GameManager.register_player(1, p)
	GameManager.change_state(Constants.GameState.IN_GAME)


func _restore_from_save(player: Node3D, data: Dictionary) -> void:
	GameLogger.info("KingdomHub", "Restoring player from save data")

	var players: Dictionary = data.get("players", {})
	if players.is_empty():
		GameLogger.warn("KingdomHub", "No player data in save, using default spawn")
		var sp: Marker3D = get_node_or_null("SpawnPoint") as Marker3D
		player.global_position = sp.global_position if sp else Vector3(0, 2, 0)
		return

	var pdata: Dictionary = players.get("1", {})
	if pdata.is_empty():
		pdata = players[players.keys()[0]]

	var pos_data: Dictionary = pdata.get("position", {})
	var px: float = pos_data.get("x", 0.0)
	var py: float = pos_data.get("y", 2.0)
	var pz: float = pos_data.get("z", 0.0)
	player.global_position = Vector3(px, py, pz)
	GameLogger.info("KingdomHub", "Player placed at (%.1f, %.1f, %.1f)" % [px, py, pz])

	var stats_data: Dictionary = pdata.get("stats", {})
	if not stats_data.is_empty() and "stats" in player and player.stats:
		var s: CharacterStats = player.stats
		s.level = stats_data.get("level", s.level)
		s.xp = stats_data.get("xp", s.xp)
		s.current_health = stats_data.get("hp", s.current_health)
		s.current_mana = stats_data.get("mana", s.current_mana)
		s.health_changed.emit(s.current_health, s.get_max_health())
		s.mana_changed.emit(s.current_mana, s.get_max_mana())
		s.stats_recalculated.emit()
		GameLogger.info("KingdomHub", "Player stats restored: Level %d, HP %.0f/%.0f, Mana %.0f/%.0f" % [
			s.level, s.current_health, s.get_max_health(), s.current_mana, s.get_max_mana()])


func _load_scene(path: String) -> Node3D:
	var doc: GLTFDocument = GLTFDocument.new()
	var state: GLTFState = GLTFState.new()
	if doc.append_from_file(path, state) != OK:
		push_error("Failed to load %s" % path)
		return Node3D.new()
	var root: Node = doc.generate_scene(state)
	return root if root else Node3D.new()


func _add_col(parent: Node3D, pos: Vector3, size: Vector3) -> void:
	var col: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = size
	col.shape = box
	col.position = pos + Vector3(0, size.y * 0.5, 0)
	parent.add_child(col)


func _add_static(parent: Node3D, path: String, orig_key: String, pos: Vector3,
	wsize: Vector3, rot_y: float, csize: Vector3) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.position = pos
	if rot_y != 0:
		body.rotation_degrees.y = rot_y
	var o: Vector3 = _ORIG[orig_key]
	var mesh: Node3D = _load_scene(path)
	mesh.scale = Vector3(wsize.x / o.x, wsize.y / o.y, wsize.z / o.z)
	body.add_child(mesh)
	_add_col(body, Vector3.ZERO, csize)
	parent.add_child(body)


func _add_deco(parent: Node3D, path: String, pos: Vector3, sv: Vector3,
	rot_y: float, csize: Vector3) -> void:
	var body: StaticBody3D = StaticBody3D.new()
	body.position = pos
	if rot_y != 0:
		body.rotation_degrees.y = rot_y
	var mesh: Node3D = _load_scene(path)
	mesh.scale = sv
	body.add_child(mesh)
	_add_col(body, Vector3.ZERO, csize)
	parent.add_child(body)


# ═════════════════════════════════════════════════
#  VILLAGE — Load pre-built structured scene
# ═════════════════════════════════════════════════

func build_village() -> void:
	var village_scene: PackedScene = load("res://scenes/Village.tscn")
	if village_scene:
		var village: Node3D = village_scene.instantiate()
		village.name = "Village"
		add_child(village)
		GameLogger.info("KingdomHub", "Village loaded from Village.tscn")
	else:
		GameLogger.error("KingdomHub", "Failed to load Village.tscn")


func _gen_houses() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var tt: Array[HouseType] = [HouseType.PLASTER, HouseType.BRICK, HouseType.WOOD, HouseType.STONE]
	for i in house_count:
		var p: Vector3 = _try_place(out)
		if p == Vector3.INF:
			push_warning("Could not place house %d/%d" % [i + 1, house_count])
			break
		out.append({p = p, f = 0, t = tt[i % tt.size()]})

	# calculate center after generation
	if out.is_empty():
		return out
	var cx: float = 0.0
	var cz: float = 0.0
	for h in out:
		cx += h.p.x
		cz += h.p.z
	cx /= float(out.size())
	cz /= float(out.size())

	# every house faces the village center
	for h in out:
		var dx: float = cx - h.p.x
		var dz: float = cz - h.p.z
		var angle: float = atan2(dx, dz)
		h.f = rad_to_deg(angle)

	return out


func _try_place(existing: Array[Dictionary]) -> Vector3:
	for _i in max_placement_attempts:
		var c: Vector3 = Vector3(
			randf_range(-area_size.x * 0.5, area_size.x * 0.5), 0,
			randf_range(-area_size.y * 0.5, area_size.y * 0.5))
		var ok: bool = true
		for d in existing:
			if c.distance_to(d.p) < min_distance:
				ok = false
				break
		if ok:
			return c
	return Vector3.INF


# ═════════════════════════════════════════════════
#  HOUSE — fully enclosed solid box
# ═════════════════════════════════════════════════

func _build_one(parent: Node3D, data: Dictionary) -> void:
	var root: Node3D = Node3D.new()
	root.position = data.p
	root.rotation_degrees.y = data.f  # faces village center
	parent.add_child(root)

	var hw2: float = HW * 0.5
	var wo2: float = WO * 0.5
	var ws: Vector3 = Vector3(WO, WH, WT)    # visual width with overlap
	var cs: Vector3 = Vector3(HW, WH, WT)    # collision = exact size

	var wp: String
	var sp: String
	var bp: String
	var rp: String
	var rk: String
	var wk: String

	match data.t:
		HouseType.PLASTER:
			wp = "res://assets/models/village/Wall_Plaster_Door_Round.gltf"
			sp = "res://assets/models/village/Wall_Plaster_Window_Wide_Round.gltf"
			bp = "res://assets/models/village/Wall_Plaster_Straight.gltf"
			rp = "res://assets/models/village/Roof_RoundTiles_6x10.gltf"
			rk = "kaykit_roof_l"; wk = "kaykit_wall"
		HouseType.BRICK:
			wp = "res://assets/models/village/Wall_Plaster_Door_Round.gltf"
			sp = "res://assets/models/village/Wall_Plaster_Window_Wide_Round.gltf"
			bp = "res://assets/models/village/Wall_UnevenBrick_Straight.gltf"
			rp = "res://assets/models/village/Roof_RoundTiles_6x8.gltf"
			rk = "kaykit_roof_m"; wk = "kaykit_wall"
		HouseType.WOOD:
			wp = "res://assets/models/village/wall-wood-door.glb"
			sp = "res://assets/models/village/wall-wood-window-shutters.glb"
			bp = "res://assets/models/village/wall-wood.glb"
			rp = "res://assets/models/village/roof-gable.glb"
			rk = "kenney_roof"; wk = "kenney_wall"
		HouseType.STONE:
			wp = "res://assets/models/village/wall-door.glb"
			sp = "res://assets/models/village/wall-window-stone.glb"
			bp = "res://assets/models/village/wall-block.glb"
			rp = "res://assets/models/village/roof-high.glb"
			rk = "kenney_roof"; wk = "kenney_wall"

	# walls — visual width > collision width → overlap at corners
	_add_static(root, wp, wk, Vector3(0, 0, hw2), ws, 0, cs)
	_add_static(root, bp, wk, Vector3(0, 0, -hw2), ws, 0, cs)
	_add_static(root, sp, wk, Vector3(-wo2, 0, 0), ws, 90, cs)
	_add_static(root, sp, wk, Vector3(wo2, 0, 0), ws, -90, cs)

	# floor (solid, can't fall through)
	var fo: Vector3 = _ORIG["kaykit_floor"]
	var fb: StaticBody3D = StaticBody3D.new()
	var fm: Node3D = _load_scene("res://assets/models/village/Floor_RedBrick.gltf")
	fm.scale = Vector3(HW / fo.x, 1.0, HW / fo.z)
	fb.add_child(fm)
	_add_col(fb, Vector3.ZERO, Vector3(HW, 0.1, HW))
	root.add_child(fb)

	# roof (on top of walls, no vertical stretch)
	var ro: Vector3 = _ORIG[rk]
	var rm: Node3D = _load_scene(rp)
	rm.scale = Vector3(HW / ro.x, 1.0, HW / ro.z)
	rm.position = Vector3(0, WH, 0)
	root.add_child(rm)


# ═════════════════════════════════════════════════
#  YARD — fence perimeter, fully closed
# ═════════════════════════════════════════════════

func _build_yard(parent: Node3D, pos: Vector3, _f: int) -> void:
	var yd: Node3D = Node3D.new()
	yd.name = "Yard"
	yd.position = pos
	parent.add_child(yd)

	var yw2: float = YD * 0.5
	var ft: float = 0.15
	var fp: String = "res://assets/models/village/fence.glb"

	# 3 overlapping segments per side → no gaps at corners
	var segs: Array[float] = [-yw2, 0, yw2]
	var seg_w: float = YD * 0.5 + 0.3  # overlap 0.3 per side

	for sx in segs:
		_add_deco(yd, fp, Vector3(sx, 0, yw2), Vector3(seg_w, 1.0, 1.0), 0, Vector3(seg_w, FH, ft))
		_add_deco(yd, fp, Vector3(sx, 0, -yw2), Vector3(seg_w, 1.0, 1.0), 0, Vector3(seg_w, FH, ft))

	for sz in segs:
		_add_deco(yd, fp, Vector3(-yw2, 0, sz), Vector3(seg_w, 1.0, 1.0), 90, Vector3(ft, FH, seg_w))
		_add_deco(yd, fp, Vector3(yw2, 0, sz), Vector3(seg_w, 1.0, 1.0), 90, Vector3(ft, FH, seg_w))


# ═════════════════════════════════════════════════
#  PATHS — from each house front → connected to center
# ═════════════════════════════════════════════════

func _build_paths(parent: Node3D, houses: Array[Dictionary]) -> void:
	if houses.is_empty():
		return

	var rp: String = "res://assets/models/village/road.glb"
	var ro: Vector3 = _ORIG["kenney_road"]

	# village center
	var cx: float = 0.0
	var cz: float = 0.0
	for h in houses:
		cx += h.p.x; cz += h.p.z
	cx /= float(houses.size()); cz /= float(houses.size())

	for h in houses:
		var hx: float = h.p.x
		var hz: float = h.p.z

		# direction from house to center
		var dx: float = cx - hx
		var dz: float = cz - hz
		var dist: float = sqrt(dx * dx + dz * dz)
		if dist < 0.01:
			continue
		var nx: float = dx / dist   # unit vector toward center
		var nz: float = dz / dist

		# path starts just outside yard edge, in front of house
		var offset: float = YD * 0.5 + 1.5
		var sx: float = hx + nx * offset
		var sz: float = hz + nz * offset
		var travel: float = dist - offset
		if travel < 2.0:
			travel = 2.0

		var steps: int = int(clamp(travel / 2.5, 2.0, 8.0))

		for i in steps:
			var t: float = float(i + 1) / float(steps)
			var rx: float = lerpf(sx, cx, t)
			var rz: float = lerpf(sz, cz, t)
			var a: float = atan2(dx, dz)
			var body: StaticBody3D = StaticBody3D.new()
			body.position = Vector3(rx, 0.01, rz)
			body.rotation_degrees.y = rad_to_deg(a)
			var mesh: Node3D = _load_scene(rp)
			mesh.scale = Vector3(2.0 / ro.x, 1.0, 2.5 / ro.z)
			body.add_child(mesh)
			_add_col(body, Vector3.ZERO, Vector3(2.0, 0.1, 2.5))
			parent.add_child(body)


# ═════════════════════════════════════════════════
#  MAIN ROAD & DECORATION
# ═════════════════════════════════════════════════

func _build_roads(parent: Node3D, pos: Array[Vector3]) -> void:
	if pos.is_empty():
		return
	var rds: Node3D = Node3D.new()
	rds.name = "MainRoad"
	parent.add_child(rds)

	var rp: String = "res://assets/models/village/road.glb"
	var ro: Vector3 = _ORIG["kenney_road"]
	var bb: Dictionary = _bb2(pos)

	for i in 9:
		var t: float = float(i) / 8.0
		var rx: float = lerpf(bb.mx - 8.0, bb.Mx + 8.0, t)
		_add_deco(rds, rp, Vector3(rx, 0.01, bb.cz), Vector3(3.0 / ro.x, 1.0, 4.0 / ro.z), 0, Vector3(3.0, 0.1, 4.0))


func _build_decor(parent: Node3D, pos: Array[Vector3]) -> void:
	if pos.is_empty():
		return

	var d: Node3D = Node3D.new()
	d.name = "Decorations"
	parent.add_child(d)

	var bb: Dictionary = _bb2(pos)

	# trees (away from houses)
	var tp: String = "res://assets/models/village/tree.glb"
	for _i in randi_range(10, 16):
		var tx: float = randf_range(bb.mx - 6.0, bb.Mx + 6.0)
		var tz: float = randf_range(bb.mz - 6.0, bb.Mz + 6.0)
		if _near(tx, tz, pos, YD * 0.5 + 1.0):
			continue
		var s: float = 1.0 + randf() * 0.5
		_add_deco(d, tp, Vector3(tx, 0, tz), Vector3(s, s, s), randf() * 360.0, Vector3(1.0, 2.5, 1.0))

	_add_deco(d, "res://assets/models/village/fountain-round.glb", Vector3(bb.cx, 0, bb.cz),
		Vector3(1, 1, 1), 0, Vector3(2.5, 1.5, 2.5))

	for _i in randi_range(10, 14):
		var lx: float = randf_range(bb.mx - 4.0, bb.Mx + 4.0)
		var lz: float = randf_range(bb.mz - 4.0, bb.Mz + 4.0)
		if _near(lx, lz, pos, YD * 0.5 + 1.0):
			continue
		_add_deco(d, "res://assets/models/village/lantern.glb", Vector3(lx, 0, lz),
			Vector3(1, 1, 1), 0, Vector3(0.3, 0.8, 0.3))

	var stall: Node3D = _load_scene("res://assets/models/village/stall.glb")
	var stall_body: StaticBody3D = StaticBody3D.new()
	stall_body.position = Vector3(randf_range(bb.cx - 5, bb.cx + 5), 0, randf_range(bb.mz - 4, bb.mz - 1))
	stall_body.rotation_degrees.y = 180
	stall_body.add_child(stall)
	_add_col(stall_body, Vector3.ZERO, Vector3(1.5, 1.5, 1.0))
	d.add_child(stall_body)


func _near(x: float, z: float, pos: Array[Vector3], th: float) -> bool:
	for p in pos:
		if Vector3(x, 0, z).distance_to(p) < th:
			return true
	return false


func _bb2(pos: Array[Vector3]) -> Dictionary:
	var mx: float = pos[0].x
	var Mx: float = pos[0].x
	var mz: float = pos[0].z
	var Mz: float = pos[0].z
	for p in pos:
		mx = min(mx, p.x); Mx = max(Mx, p.x)
		mz = min(mz, p.z); Mz = max(Mz, p.z)
	return {mx = mx, Mx = Mx, mz = mz, Mz = Mz, cx = (mx + Mx) * 0.5, cz = (mz + Mz) * 0.5}
