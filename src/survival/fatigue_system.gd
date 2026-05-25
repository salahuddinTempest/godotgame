class_name FatigueSystem
extends Node
## Fatigue mechanics per CLAUDE.md.
##
## -0.3/s only during active gameplay.
## Sleep restores to 100 over time (handled by interacting with beds).
## Low fatigue (<25): Reaction time -1s, hit chance -20%

# === Public Variables ===
var current_fatigue: float = Constants.FATIGUE_MAX
var is_low: bool = false
var is_sleeping: bool = false

# === Private Variables ===
var _manager: NeedsManager

# === Public Methods ===

func setup(manager: NeedsManager) -> void:
	_manager = manager
	current_fatigue = Constants.FATIGUE_MAX

func process_tick(delta: float, is_active_state: bool) -> void:
	if is_sleeping:
		# Sleeping restores fatigue quickly (e.g., 2-8 minutes for full restore)
		# 100 fatigue / 120 seconds = 0.83 per sec, let's say 1.0 for now
		current_fatigue = minf(Constants.FATIGUE_MAX, current_fatigue + (1.0 * delta))
		if current_fatigue >= Constants.FATIGUE_MAX:
			wake_up()
		return
		
	# Only drain during active gameplay (we assume process_tick is only called then)
	var drain_rate: float = Constants.FATIGUE_DRAIN_NORMAL
	current_fatigue = maxf(0.0, current_fatigue - (drain_rate * delta))
	
	if _manager:
		var pid: int = _manager.get_parent().peer_id if "peer_id" in _manager.get_parent() else 0
		EventBus.fatigue_changed.emit(pid, current_fatigue)
	
	if current_fatigue <= Constants.FATIGUE_LOW_THRESHOLD and not is_low:
		_apply_low()
	elif current_fatigue > Constants.FATIGUE_LOW_THRESHOLD and is_low:
		_remove_low()

func sleep() -> void:
	is_sleeping = true
	# Inform game manager or state machine
	
func wake_up() -> void:
	is_sleeping = false

# === Private Methods ===

func _apply_low() -> void:
	is_low = true
	if _manager and _manager.character_stats:
		# Modifiers
		_manager.character_stats.apply_multiplier("hit_chance", 1.0 - Constants.FATIGUE_HIT_CHANCE_PENALTY, true)
		# Reaction time penalty is complex, maybe handled at player input level
		var pid: int = _manager.get_parent().peer_id if "peer_id" in _manager.get_parent() else 0
		EventBus.fatigue_critical.emit(pid)
		GameLogger.warn("FatigueSystem", "Exhausted! Penalties applied.")

func _remove_low() -> void:
	is_low = false
	if _manager and _manager.character_stats:
		_manager.character_stats.remove_multiplier("hit_chance", true)
		GameLogger.info("FatigueSystem", "Well rested.")
