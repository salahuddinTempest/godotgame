extends SceneTree

const BASE_DIR = "res://assets/kenney_fantasy-town-kit_2.0/Models/GLB format/"

func _init():
	print("Starting village build...")
	var dir = DirAccess.open("res://scenes")
	if dir == null:
		print("Error opening res://scenes")
		quit()
		return
		
	if not dir.dir_exists("village_props"):
		dir.make_dir("village_props")

	# Build House A
	var house_a = build_house_a()
	var packed_a = PackedScene.new()
	packed_a.pack(house_a)
	var err = ResourceSaver.save(packed_a, "res://scenes/village_props/HouseA.tscn")
	if err != OK:
		print("Error saving HouseA: ", err)
	house_a.queue_free()

	# Build Village
	var village = build_village()
	var packed_village = PackedScene.new()
	packed_village.pack(village)
	err = ResourceSaver.save(packed_village, "res://scenes/Village.tscn")
	if err != OK:
		print("Error saving Village: ", err)
	village.queue_free()
	
	print("Village build completed!")
	quit()

func load_model(name: String) -> Node3D:
	var path = BASE_DIR + name + ".glb"
	var pack = load(path) as PackedScene
	if pack:
		return pack.instantiate() as Node3D
	print("Failed to load: ", path)
	return Node3D.new() # fallback

func set_owner_recursive(node: Node, owner_node: Node):
	if node != owner_node:
		node.owner = owner_node
	for child in node.get_children():
		set_owner_recursive(child, owner_node)

func build_house_a() -> Node3D:
	var root = Node3D.new()
	root.name = "HouseA"
	
	# Kenney modular buildings
	# Walls
	var w1 = load_model("wall-door")
	w1.position = Vector3(0, 0, 0)
	root.add_child(w1)
	
	var w2 = load_model("wall-window-glass")
	w2.position = Vector3(1, 0, 0)
	root.add_child(w2)
	
	var w3 = load_model("wall")
	w3.position = Vector3(1, 0, -1)
	w3.rotation_degrees = Vector3(0, -90, 0)
	root.add_child(w3)
	
	var w4 = load_model("wall")
	w4.position = Vector3(0, 0, -1)
	w4.rotation_degrees = Vector3(0, 90, 0)
	root.add_child(w4)
	
	var r1 = load_model("roof")
	r1.position = Vector3(0, 1, 0)
	root.add_child(r1)
	
	var r2 = load_model("roof")
	r2.position = Vector3(1, 1, 0)
	root.add_child(r2)
	
	var r3 = load_model("roof")
	r3.position = Vector3(0, 1, -1)
	root.add_child(r3)
	
	var r4 = load_model("roof")
	r4.position = Vector3(1, 1, -1)
	root.add_child(r4)
	
	set_owner_recursive(root, root)
	return root

func build_village() -> Node3D:
	var root = Node3D.new()
	root.name = "Village"
	
	# Center road
	for i in range(-5, 6):
		var road = load_model("road")
		road.position = Vector3(0, 0, i * 2) # Kenney roads might be 2 units? Will see.
		root.add_child(road)
		
		# Adding fences
		var fence_left = load_model("fence")
		fence_left.position = Vector3(-3, 0, i * 2)
		root.add_child(fence_left)
		
		var fence_right = load_model("fence")
		fence_right.position = Vector3(3, 0, i * 2)
		root.add_child(fence_right)
	
	# Add some houses and trees
	for z in [-4, 0, 4]:
		var h_left = load("res://scenes/village_props/HouseA.tscn").instantiate()
		h_left.position = Vector3(-6, 0, z)
		h_left.rotation_degrees = Vector3(0, 90, 0)
		root.add_child(h_left)
		
		# Add a tree in the left yard
		var tree_left = load_model("tree-high")
		tree_left.position = Vector3(-8, 0, z - 1)
		root.add_child(tree_left)
		
		var h_right = load("res://scenes/village_props/HouseA.tscn").instantiate()
		h_right.position = Vector3(6, 0, z)
		h_right.rotation_degrees = Vector3(0, -90, 0)
		root.add_child(h_right)
		
		# Add a tree in the right yard
		var tree_right = load_model("tree-high")
		tree_right.position = Vector3(8, 0, z + 1)
		root.add_child(tree_right)
		
	# Add Central Props (Fountain, Market Stalls)
	var fountain = load_model("fountain-round")
	fountain.position = Vector3(0, 0, 0)
	root.add_child(fountain)
	
	var stall1 = load_model("stall-red")
	stall1.position = Vector3(-2.5, 0, 0)
	stall1.rotation_degrees = Vector3(0, 90, 0)
	root.add_child(stall1)
	
	var stall2 = load_model("stall-green")
	stall2.position = Vector3(2.5, 0, 0)
	stall2.rotation_degrees = Vector3(0, -90, 0)
	root.add_child(stall2)
	
	var cart = load_model("cart")
	cart.position = Vector3(0, 0, 2.5)
	cart.rotation_degrees = Vector3(0, 45, 0)
	root.add_child(cart)
	
	# Lanterns along the road
	for i in [-3, 3]:
		var lantern1 = load_model("lantern")
		lantern1.position = Vector3(-2, 0, i * 2)
		root.add_child(lantern1)
		
		var lantern2 = load_model("lantern")
		lantern2.position = Vector3(2, 0, i * 2)
		root.add_child(lantern2)
		
	set_owner_recursive(root, root)
	return root
