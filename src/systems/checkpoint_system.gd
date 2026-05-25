class_name CheckpointSystem
extends Node
## Manages physical checkpoints in the world (Bonfires).
##
## Tracks the last visited checkpoint for respawns and triggers auto-saves.

# === Public Variables ===
var active_checkpoint_id: String = ""
var active_checkpoint_position: Vector3 = Vector3.ZERO

# === Lifecycle Methods ===

func _ready() -> void:
	EventBus.checkpoint_reached.connect(_on_checkpoint_reached)
	EventBus.player_died.connect(_on_player_died)

# === Public Methods ===

func activate_checkpoint(checkpoint_id: String, position: Vector3) -> void:
	if active_checkpoint_id == checkpoint_id:
		return
		
	active_checkpoint_id = checkpoint_id
	active_checkpoint_position = position
	
	# Trigger an auto-save (let's use slot 1 as auto-save)
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		save_manager.save_game(1)
		
	var p: Player = GameManager.get_player(multiplayer.get_unique_id()) if GameManager else null
	if p and p.stats:
		# Heal on checkpoint rest
		p.stats.heal(p.stats.get_max_health())
		p.stats.restore_mana(p.stats.get_max_mana())
		
	GameLogger.info("CheckpointSystem", "Checkpoint activated: %s" % checkpoint_id)

# === Private Methods ===

func _on_checkpoint_reached(player_id: int, checkpoint_id: String) -> void:
	# Assume the local player reached it
	if player_id == multiplayer.get_unique_id():
		# Logic is handled by the interaction event usually, but this is a fallback
		pass

func _on_player_died(player_id: int) -> void:
	if player_id == multiplayer.get_unique_id():
		GameLogger.info("CheckpointSystem", "Player died. Respawning at %s..." % active_checkpoint_id)
		
		# Delay respawn
		var timer = get_tree().create_timer(3.0)
		timer.timeout.connect(func():
			var p: Player = GameManager.get_player(player_id)
			if p:
				p.global_position = active_checkpoint_position
				if p.stats:
					p.stats.current_health = p.stats.get_max_health()
					p.stats.current_mana = p.stats.get_max_mana()
					p.stats._is_dead = false
					p.stats.stats_recalculated.emit()
				
				EventBus.player_respawned.emit(player_id, active_checkpoint_position)
		)
