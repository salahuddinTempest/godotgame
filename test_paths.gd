extends SceneTree

func _init() -> void:
	var ps = load("res://scenes/entities/player.tscn")
	if ps:
		var player = ps.instantiate()
		print("Player scene root name: ", player.name)
		print("Node tree:")
		_print_tree(player, "")
	else:
		print("Failed to load player.tscn")
	quit()

func _print_tree(node: Node, indent: String) -> void:
	print(indent, "- ", node.name, " (", node.get_class(), ")")
	for child in node.get_children():
		_print_tree(child, indent + "  ")
