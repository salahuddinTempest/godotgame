extends SceneTree

func _init() -> void:
	var ps = load("res://scenes/entities/player.tscn")
	if ps:
		var player = ps.instantiate()
		_print_scales(player, "")
	else:
		print("Failed to load player.tscn")
	quit()

func _print_scales(node: Node, indent: String) -> void:
	var scale_str = ""
	if node is Node3D:
		scale_str = " | scale: " + str(node.scale) + " | global_scale: " + str(node.global_transform.basis.get_scale())
	print(indent, "- ", node.name, " (", node.get_class(), ")", scale_str)
	for child in node.get_children():
		_print_scales(child, indent + "  ")
