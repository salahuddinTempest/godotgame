extends SceneTree

func _init() -> void:
	var ps = load("res://scenes/entities/player.tscn")
	if ps:
		var player = ps.instantiate()
		var skeleton: Skeleton3D = player.find_child("Skeleton3D", true, false) as Skeleton3D
		if skeleton:
			print("Skeleton3D found! Bone count: ", skeleton.get_bone_count())
			for i in range(skeleton.get_bone_count()):
				var bname = skeleton.get_bone_name(i)
				if "hand" in bname.to_lower() or "wrist" in bname.to_lower() or "weapon" in bname.to_lower():
					print("Match bone index ", i, ": ", bname)
		else:
			print("No Skeleton3D found.")
	else:
		print("Failed to load player.tscn")
	quit()
