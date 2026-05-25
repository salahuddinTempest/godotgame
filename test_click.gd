extends SceneTree

func _init():
	print("=== Loading main scene ===")

	var main_scene: PackedScene = load("res://scenes/ui/main_menu.tscn")
	if not main_scene:
		print("FAIL: Could not load main scene")
		quit()
		return

	var menu = main_scene.instantiate()
	root.add_child(menu)
	print("OK: MainMenu added to tree")

	await process_frame

	var main_menu = root.get_node_or_null("MainMenu")
	if main_menu:
		print("OK: MainMenu found as MainMenu")
		if main_menu.has_method("_on_new_game_pressed"):
			print("=== Clicking New Game ===")
			main_menu._on_new_game_pressed()
		else:
			print("FAIL: No _on_new_game_pressed method")
	else:
		print("Root children after add:")
		for c in root.get_children():
			print("  ", c.name, " (", c.get_class(), ")")

	await process_frame
	await process_frame
	await process_frame

	print("=== Checking results ===")
	for child in root.get_children():
		print("  Root: ", child.name, " (", child.get_class(), ")")
		if child.name == "KingdomHub":
			print("OK: Level loaded!")
		if child is CharacterBody3D:
			print("OK: Player spawned!")

	quit()
