extends SceneTree

func _init() -> void:
	var f = FileAccess.open("res://scenes/entities/player.tscn", FileAccess.READ)
	if f:
		var line_num = 1
		while not f.eof_reached():
			var line = f.get_line()
			if "1_ss7kx" in line or "Model" in line or "Armature" in line:
				print(line_num, ": ", line)
			line_num += 1
	quit()
