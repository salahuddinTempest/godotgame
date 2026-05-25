extends SceneTree

func _init():
    # Simulate what happens when New Game is clicked
    print("=== Simulating New Game click ===")
    
    # Check level scene exists
    if ResourceLoader.exists("res://scenes/levels/kingdom_hub.tscn"):
        print("OK: kingdom_hub.tscn exists")
        var level = load("res://scenes/levels/kingdom_hub.tscn")
        if level:
            print("OK: kingdom_hub.tscn loaded")
            var inst = level.instantiate()
            if inst:
                print("OK: kingdom_hub instantiated as: ", inst.get_class())
                inst.free()
        else:
            print("FAIL: kingdom_hub.tscn load returned null")
    else:
        print("MISSING: kingdom_hub.tscn")
    
    # Check player scene exists
    if ResourceLoader.exists("res://scenes/entities/player.tscn"):
        print("OK: player.tscn exists")
        var player_scene = load("res://scenes/entities/player.tscn")
        if player_scene:
            print("OK: player.tscn loaded")
            var player = player_scene.instantiate()
            if player:
                print("OK: player instantiated as: ", player.get_class())
                # Check expected nodes
                if player.has_node("CameraPivot"):
                    print("OK: has CameraPivot")
                if player.has_node("CameraPivot/Camera3D"):
                    print("OK: has Camera3D")
                if player.has_node("Model"):
                    print("OK: has Model")
                player.free()
        else:
            print("FAIL: player.tscn load returned null")
    else:
        print("MISSING: player.tscn")
    
    quit()
