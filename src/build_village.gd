## Village Builder — Generates res://scenes/Village.tscn
## Uses Kenney Fantasy Town Kit 2.0 assets
## Run: godot --headless -s src/build_village.gd
extends SceneTree

const KIT := "res://assets/kenney_fantasy-town-kit_2.0/Models/GLB format/"

# Grid settings
const PLOT_W   := 14.0   # width of each house plot (X)
const PLOT_D   := 14.0   # depth of each house plot (Z)
const ROAD_W   := 6.0    # width of main road between rows
const ROWS     := 2      # rows on each side of road (left + right)
const COLS     := 4      # houses per row
const FENCE_H  := 1.0

func _init() -> void:
	print("[VillageBuilder] Starting…")

	var dir := DirAccess.open("res://scenes")
	if dir and not dir.dir_exists("village_props"):
		dir.make_dir("village_props")

	# ── build each house variant ──────────────────────────
	_save_scene(_build_house_wood(),  "res://scenes/village_props/HouseWood.tscn")
	_save_scene(_build_house_stone(), "res://scenes/village_props/HouseStone.tscn")

	# ── build full village ────────────────────────────────
	_save_scene(_build_village(), "res://scenes/Village.tscn")

	print("[VillageBuilder] Done.")
	quit()

# ─────────────────────────────────────────────────
#  HELPERS
# ─────────────────────────────────────────────────

func _glb(name: String) -> Node3D:
	var p := load(KIT + name + ".glb") as PackedScene
	if p:
		return p.instantiate() as Node3D
	push_warning("Missing asset: " + name)
	return Node3D.new()

func _own(node: Node, root: Node) -> void:
	if node != root:
		node.owner = root
	for c in node.get_children():
		_own(c, root)

func _save_scene(root: Node, path: String) -> void:
	_own(root, root)
	var ps := PackedScene.new()
	var err := ps.pack(root)
	if err != OK:
		push_error("Pack failed for " + path + " err=" + str(err))
		root.queue_free()
		return
	err = ResourceSaver.save(ps, path)
	if err != OK:
		push_error("Save failed for " + path + " err=" + str(err))
	else:
		print("  Saved: " + path)
	root.queue_free()

func _place(parent: Node3D, node: Node3D, pos: Vector3, rot_y: float = 0.0) -> void:
	node.position = pos
	if rot_y != 0.0:
		node.rotation_degrees.y = rot_y
	parent.add_child(node)

# ─────────────────────────────────────────────────
#  HOUSE VARIANTS
#  Kenney walls are 1×1×1 units (w×h×d approx)
#  We build a 3×3 footprint = 3 wide, 3 deep
# ─────────────────────────────────────────────────

func _build_house_wood() -> Node3D:
	var root := Node3D.new()
	root.name = "HouseWood"
	# Front wall (z=0): door centre, windows left/right
	_place(root, _glb("wall-wood-door"),            Vector3(-1, 0, 0), 0)
	_place(root, _glb("wall-wood-window-shutters"), Vector3( 0, 0, 0), 0)
	_place(root, _glb("wall-wood"),                 Vector3( 1, 0, 0), 0)
	# Back wall (z=-2)
	_place(root, _glb("wall-wood"),                 Vector3(-1, 0,-2), 180)
	_place(root, _glb("wall-wood-window-shutters"), Vector3( 0, 0,-2), 180)
	_place(root, _glb("wall-wood"),                 Vector3( 1, 0,-2), 180)
	# Left side (x=-1, along Z)
	_place(root, _glb("wall-wood"),                 Vector3(-1, 0,-1),  90)
	# Right side (x=1, along Z)
	_place(root, _glb("wall-wood"),                 Vector3( 1, 0,-1), -90)
	# Roof
	_place(root, _glb("roof-gable-end"),   Vector3(-1, 1, 0),   0)
	_place(root, _glb("roof-gable"),       Vector3( 0, 1, 0),   0)
	_place(root, _glb("roof-gable-end"),   Vector3( 1, 1, 0), 180)
	_place(root, _glb("roof-gable-end"),   Vector3(-1, 1,-2), 180)
	_place(root, _glb("roof-gable"),       Vector3( 0, 1,-2), 180)
	_place(root, _glb("roof-gable-end"),   Vector3( 1, 1,-2),   0)
	# Chimney
	_place(root, _glb("chimney"),          Vector3( 0.5, 1, -0.5), 0)
	return root

func _build_house_stone() -> Node3D:
	var root := Node3D.new()
	root.name = "HouseStone"
	# Front (z=0)
	_place(root, _glb("wall-door"),         Vector3(-1, 0, 0), 0)
	_place(root, _glb("wall-window-stone"), Vector3( 0, 0, 0), 0)
	_place(root, _glb("wall"),              Vector3( 1, 0, 0), 0)
	# Back (z=-2)
	_place(root, _glb("wall"),              Vector3(-1, 0,-2), 180)
	_place(root, _glb("wall-window-stone"), Vector3( 0, 0,-2), 180)
	_place(root, _glb("wall"),              Vector3( 1, 0,-2), 180)
	# Sides
	_place(root, _glb("wall"),              Vector3(-1, 0,-1),  90)
	_place(root, _glb("wall"),              Vector3( 1, 0,-1), -90)
	# Roof high style
	_place(root, _glb("roof-high-gable-end"), Vector3(-1, 1, 0),   0)
	_place(root, _glb("roof-high-gable"),     Vector3( 0, 1, 0),   0)
	_place(root, _glb("roof-high-gable-end"), Vector3( 1, 1, 0), 180)
	_place(root, _glb("roof-high-gable-end"), Vector3(-1, 1,-2), 180)
	_place(root, _glb("roof-high-gable"),     Vector3( 0, 1,-2), 180)
	_place(root, _glb("roof-high-gable-end"), Vector3( 1, 1,-2),   0)
	_place(root, _glb("chimney-base"),        Vector3(-0.5, 1,-0.5), 0)
	_place(root, _glb("chimney-top"),         Vector3(-0.5, 2,-0.5), 0)
	return root

# ─────────────────────────────────────────────────
#  VILLAGE LAYOUT
#
#  Visual layout (top-down):
#
#   [Row 0 Left]  [Row 0 Right]
#   ============ ROAD ============
#   [Row 1 Left]  [Row 1 Right]
#
#  COLS houses per row.
#  Each plot = PLOT_W × PLOT_D, fenced on all sides.
#  Central fountain at road midpoint.
# ─────────────────────────────────────────────────

func _build_village() -> Node3D:
	var root := Node3D.new()
	root.name = "Village"

	_build_roads(root)
	_build_plots(root)
	_build_center(root)
	_build_lighting(root)
	_build_nature(root)

	return root

# ── Roads ──────────────────────────────────────────
func _build_roads(root: Node3D) -> void:
	var total_length := float(COLS) * PLOT_W
	var start_x := -total_length * 0.5

	# Main horizontal road (Z axis = 0)
	var steps_z := int(ROAD_W)
	var steps_x := int(total_length) + 2
	for xi in range(-1, steps_x + 1):
		for zi in range(-steps_z / 2, steps_z / 2 + 1):
			var r := _glb("road")
			r.position = Vector3(start_x + xi * 1.0, 0.0, float(zi))
			root.add_child(r)

	# Side roads (connecting perimeter)
	for side: int in [-1, 1]:
		var z_road: float = float(side) * (ROAD_W * 0.5 + PLOT_D + PLOT_D * 0.5)
		for xi in range(-1, steps_x + 1):
			var r := _glb("road")
			r.position = Vector3(start_x + xi * 1.0, 0.0, z_road)
			root.add_child(r)

	# Road curbs on both sides of main road
	for xi in range(0, steps_x):
		var rx := start_x + xi
		for side: int in [-1, 1]:
			var curb := _glb("road-curb")
			curb.position = Vector3(rx, 0.0, float(side) * (ROAD_W * 0.5))
			curb.rotation_degrees.y = 90 if side == 1 else -90
			root.add_child(curb)

# ── Plots (houses + fences) ────────────────────────
func _build_plots(root: Node3D) -> void:
	var total_length := float(COLS) * PLOT_W
	var start_x := -total_length * 0.5

	# 2 sides: north (+Z) and south (-Z) of road
	for side: int in [1, -1]:
		var row_z_center: float = float(side) * (ROAD_W * 0.5 + PLOT_D * 0.5)

		for col in range(COLS):
			var px := start_x + col * PLOT_W + PLOT_W * 0.5
			var pz: float = row_z_center
			_build_one_plot(root, Vector3(px, 0, pz), side, col)

# ── Single Plot ─────────────────────────────────────
func _build_one_plot(root: Node3D, center: Vector3, side: int, col: int) -> void:
	var hw := PLOT_W * 0.5
	var hd := PLOT_D * 0.5
	var fence_count_x := int(PLOT_W)     # number of fence segments along X
	var fence_count_z := int(PLOT_D)     # number of fence segments along Z

	# ── Fence perimeter ──
	# Front fence (road-side)
	var front_z := center.z - side * hd
	for i in range(fence_count_x):
		var fx := center.x - hw + 0.5 + float(i)
		# Leave gate gap at center (col index 1 or 2 = near middle)
		var is_gate_pos := (i == fence_count_x / 2)
		if is_gate_pos:
			var gate := _glb("fence-gate")
			gate.position = Vector3(fx, 0, front_z)
			gate.rotation_degrees.y = 0
			root.add_child(gate)
		else:
			var f := _glb("fence")
			f.position = Vector3(fx, 0, front_z)
			f.rotation_degrees.y = 0
			root.add_child(f)

	# Back fence
	var back_z := center.z + side * hd
	for i in range(fence_count_x):
		var fx := center.x - hw + 0.5 + float(i)
		var f := _glb("fence")
		f.position = Vector3(fx, 0, back_z)
		f.rotation_degrees.y = 0
		root.add_child(f)

	# Left fence
	for i in range(fence_count_z):
		var fz := center.z - hd + 0.5 + float(i)
		var f := _glb("fence")
		f.position = Vector3(center.x - hw, 0, fz)
		f.rotation_degrees.y = 90
		root.add_child(f)

	# Right fence
	for i in range(fence_count_z):
		var fz := center.z - hd + 0.5 + float(i)
		var f := _glb("fence")
		f.position = Vector3(center.x + hw, 0, fz)
		f.rotation_degrees.y = 90
		root.add_child(f)

	# ── House ──
	# Alternate between wood and stone based on column
	var house_scene_path: String
	if col % 2 == 0:
		house_scene_path = "res://scenes/village_props/HouseWood.tscn"
	else:
		house_scene_path = "res://scenes/village_props/HouseStone.tscn"

	var hps := load(house_scene_path) as PackedScene
	if hps:
		var house := hps.instantiate() as Node3D
		# Center house in plot, rotate to face road
		house.position = Vector3(center.x - 1.0, 0.0, center.z)
		house.rotation_degrees.y = 0 if side > 0 else 180
		root.add_child(house)

	# ── Lantern by gate ──
	var gate_x := center.x
	var lantern := _glb("lantern")
	lantern.position = Vector3(gate_x + 0.8, 0, front_z)
	root.add_child(lantern)

	# ── Tree in back yard ──
	var tree := _glb("tree-high") if col % 2 == 0 else _glb("tree-crooked")
	tree.position = Vector3(center.x - 3.0, 0, center.z + side * 2.0)
	root.add_child(tree)

# ── Central Plaza ──────────────────────────────────
func _build_center(root: Node3D) -> void:
	# Fountain at road centre
	var fountain := _glb("fountain-round-detail")
	fountain.position = Vector3(0, 0, 0)
	root.add_child(fountain)

	# Market stalls flanking fountain
	var stall1 := _glb("stall-red")
	stall1.position = Vector3(-5.0, 0, 0)
	stall1.rotation_degrees.y = 90
	root.add_child(stall1)

	var stall2 := _glb("stall-green")
	stall2.position = Vector3(5.0, 0, 0)
	stall2.rotation_degrees.y = -90
	root.add_child(stall2)

	var stall3 := _glb("stall")
	stall3.position = Vector3(0, 0, -2.5)
	stall3.rotation_degrees.y = 180
	root.add_child(stall3)

	# Bench near stalls
	var bench := _glb("stall-bench")
	bench.position = Vector3(0, 0, 2.5)
	root.add_child(bench)

	# Cart with goods
	var cart := _glb("cart")
	cart.position = Vector3(-3.0, 0, -1.5)
	cart.rotation_degrees.y = 30
	root.add_child(cart)

	var cart2 := _glb("cart-high")
	cart2.position = Vector3(3.5, 0, -1.5)
	cart2.rotation_degrees.y = -15
	root.add_child(cart2)

	# Banners on road sides
	var ban1 := _glb("banner-red")
	ban1.position = Vector3(-2.0, 0, 0)
	root.add_child(ban1)

	var ban2 := _glb("banner-green")
	ban2.position = Vector3(2.0, 0, 0)
	root.add_child(ban2)

# ── Street Lighting ─────────────────────────────────
func _build_lighting(root: Node3D) -> void:
	var total_length := float(COLS) * PLOT_W
	var start_x := -total_length * 0.5
	var lamp_spacing := PLOT_W  # one lamp per plot

	for i in range(COLS + 1):
		var lx := start_x + i * lamp_spacing
		for side: int in [-1, 1]:
			var lz: float = float(side) * (ROAD_W * 0.5 + 0.5)
			# Pillar + lantern
			var pillar := _glb("pillar-wood")
			pillar.position = Vector3(lx, 0, lz)
			root.add_child(pillar)
			var lantern := _glb("lantern")
			lantern.position = Vector3(lx, 1.5, lz)
			root.add_child(lantern)

# ── Natural Decorations ─────────────────────────────
func _build_nature(root: Node3D) -> void:
	var total_length := float(COLS) * PLOT_W
	var hlen := total_length * 0.5 + 4.0

	# Trees at village entry points
	for side: int in [-1, 1]:
		var tx: float = float(side) * hlen
		var entry_tree1 := _glb("tree-high-round")
		entry_tree1.position = Vector3(tx, 0, -ROAD_W)
		root.add_child(entry_tree1)

		var entry_tree2 := _glb("tree-high-round")
		entry_tree2.position = Vector3(tx, 0, ROAD_W)
		root.add_child(entry_tree2)

	# Rocks scattered at village edges
	for side: int in [-1, 1]:
		var rs := _glb("rock-small")
		rs.position = Vector3(float(side) * (hlen - 2.0), 0, float(side) * ROAD_W * 2.0)
		root.add_child(rs)
		var rl := _glb("rock-large")
		rl.position = Vector3(float(side) * (hlen - 2.0), 0, -float(side) * ROAD_W * 2.0)
		root.add_child(rl)

	# Windmill at one end
	var windmill := _glb("windmill")
	windmill.position = Vector3(hlen, 0, 0)
	windmill.rotation_degrees.y = 45
	root.add_child(windmill)

	# Watermill at other end (near a "river" edge)
	var watermill := _glb("watermill")
	watermill.position = Vector3(-hlen, 0, 0)
	root.add_child(watermill)
