extends SceneTree

func _init() -> void:
	var path = "res://assets/Medieval Weapons Pack by Quaternius/FBX/Sword.fbx"
	print("ResourceLoader.exists: ", ResourceLoader.exists(path))
	var res = load(path)
	print("Load result: ", res)
	if res:
		var inst = res.instantiate()
		print("Instantiated: ", inst)
	quit()
