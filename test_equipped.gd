extends SceneTree

func _init() -> void:
	# Instantiate EventBus, Constants, GameManager manually since they are autoloads
	var eb = Node.new()
	eb.name = "EventBus"
	eb.set_script(load("res://src/core/event_bus.gd"))
	root.add_child(eb)
	
	var c = Node.new()
	c.name = "Constants"
	c.set_script(load("res://src/core/constants.gd"))
	root.add_child(c)
	
	var gm = Node.new()
	gm.name = "GameManager"
	gm.set_script(load("res://src/core/game_manager.gd"))
	root.add_child(gm)

	var ps = load("res://scenes/entities/player.tscn")
	if ps:
		var player = ps.instantiate()
		root.add_child(player)
		
		# Wait one frame for deferred call
		await process_frame
		
		print("\n=== PLAYER NODE TREE AFTER READY ===")
		_print_tree(player, "")
	else:
		print("Failed to load player.tscn")
	quit()

func _print_tree(node: Node, indent: String) -> void:
	var scale_str = ""
	if node is Node3D:
		scale_str = " | scale: " + str(node.scale) + " | pos: " + str(node.position)
	print(indent, "- ", node.name, " (", node.get_class(), ")", scale_str)
	for child in node.get_children():
		_print_tree(child, indent + "  ")
