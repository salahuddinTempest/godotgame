extends SceneTree

func _init() -> void:
	var path = "res://scenes/entities/player.tscn"
	var ps = load(path)
	if not ps:
		print("Failed to load")
		quit()
		return
	
	var scene = ps.instantiate()
	var model = scene.get_node("Model")
	
	var armatures = []
	for child in model.get_children():
		if child.name.begins_with("Armature"):
			armatures.append(child)
			
	if armatures.size() > 1:
		print("Found duplicate armatures: ", armatures.size())
		var to_remove = armatures[1]
		model.remove_child(to_remove)
		to_remove.queue_free()
		
		var packed = PackedScene.new()
		packed.pack(scene)
		ResourceSaver.save(packed, path)
		print("Saved fixed player.tscn")
	else:
		print("No duplicate armatures found.")
		
	quit()
