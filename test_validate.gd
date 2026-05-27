extends SceneTree

func _init():
    # Check for script errors by accessing key scripts
    var scripts_to_check = [
        "res://src/ui/main_menu.gd",
        "res://src/core/event_bus.gd",
        "res://src/core/game_manager.gd",
        "res://src/core/constants.gd",
        "res://src/world/level_manager.gd",
        "res://src/economy/item_database.gd",
        "res://src/combat/combat_engine.gd",
        "res://src/utils/logger.gd",
        "res://src/player/abilities/fireball.gd",
        "res://src/player/abilities/active_skills.gd",
        "res://src/world/npc_base.gd",
        "res://src/enemies/enemy_base.gd",
        "res://src/enemies/enemy_ai.gd",
        "res://src/ui/floating_status_plate.gd",
    ]
    var all_ok = true
    for path in scripts_to_check:
        if ResourceLoader.exists(path):
            var res = load(path)
            if res:
                print("OK: ", path)
            else:
                print("FAIL: ", path)
                all_ok = false
        else:
            print("MISSING: ", path)
            all_ok = false
    
    # Load main scene
    if ResourceLoader.exists("res://scenes/ui/main_menu.tscn"):
        var scene = load("res://scenes/ui/main_menu.tscn")
        if scene:
            print("OK: Main scene loads")
        else:
            print("FAIL: Main scene failed to load")
            all_ok = false
    else:
        print("MISSING: Main scene")
        all_ok = false
    
    if all_ok:
        print("ALL CHECKS PASSED")
    else:
        print("SOME CHECKS FAILED")
    
    quit()
