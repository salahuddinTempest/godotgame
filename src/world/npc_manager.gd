class_name NPCManager
extends Node
## Manages NPC spawning, lifecycles, and interactions.
##
## Tracks all active NPCs in a level, provides utilities for
## finding them, and manages dialogue states.

# === Public Variables ===
var active_npcs: Array[Node3D] = []

# === Public Methods ===

func register_npc(npc: Node3D) -> void:
	if not active_npcs.has(npc):
		active_npcs.append(npc)
		GameLogger.info("NPCManager", "Registered NPC: %s" % npc.name)

func unregister_npc(npc: Node3D) -> void:
	if active_npcs.has(npc):
		active_npcs.erase(npc)

func get_npc(npc_id: String) -> Node3D:
	for npc in active_npcs:
		if npc.has_method("get_id") and npc.get_id() == npc_id:
			return npc
	return null

func start_dialogue(npc: Node3D, player: Player) -> void:
	if not is_instance_valid(npc) or not is_instance_valid(player):
		return
		
	var npc_id: String = npc.get_id() if npc.has_method("get_id") else npc.name
	EventBus.dialogue_started.emit(npc_id)
	
	# Open dialogue UI...
	EventBus.ui_screen_opened.emit("dialogue_popup")
