class_name HungerSystem
extends Node
## Hunger mechanics per CLAUDE.md.
##
## -0.5/s normal, -1.5/s combat/sprint
## Critical (0): -50% Move Speed, -30% Attack Damage

# === Public Variables ===
var current_hunger: float = Constants.HUNGER_MAX
var is_critical: bool = false

# === Private Variables ===
var _manager: NeedsManager

# === Public Methods ===

func setup(manager: NeedsManager) -> void:
	_manager = manager
	current_hunger = Constants.HUNGER_MAX

func process_tick(delta: float, is_active_state: bool) -> void:
	var drain_rate: float = Constants.HUNGER_DRAIN_COMBAT if is_active_state else Constants.HUNGER_DRAIN_NORMAL
	current_hunger = maxf(0.0, current_hunger - (drain_rate * delta))
	
	if _manager:
		var pid: int = _manager.get_parent().peer_id if "peer_id" in _manager.get_parent() else 0
		EventBus.hunger_changed.emit(pid, current_hunger)
	
	if current_hunger <= Constants.HUNGER_CRITICAL_THRESHOLD and not is_critical:
		_apply_critical()
	elif current_hunger > Constants.HUNGER_CRITICAL_THRESHOLD and is_critical:
		_remove_critical()

func eat(amount: float) -> void:
	current_hunger = minf(Constants.HUNGER_MAX, current_hunger + amount)
	if current_hunger > Constants.HUNGER_CRITICAL_THRESHOLD and is_critical:
		_remove_critical()

# === Private Methods ===

func _apply_critical() -> void:
	is_critical = true
	if _manager and _manager.character_stats:
		_manager.character_stats.apply_multiplier("move_speed", 1.0 - Constants.HUNGER_CRITICAL_SPEED_PENALTY, true)
		_manager.character_stats.apply_multiplier("attack_power", 1.0 - Constants.HUNGER_CRITICAL_DAMAGE_PENALTY, true)
		var pid: int = _manager.get_parent().peer_id if "peer_id" in _manager.get_parent() else 0
		EventBus.hunger_critical.emit(pid)
		GameLogger.warn("HungerSystem", "Starving! Penalties applied.")

func _remove_critical() -> void:
	is_critical = false
	if _manager and _manager.character_stats:
		_manager.character_stats.remove_multiplier("move_speed", true)
		_manager.character_stats.remove_multiplier("attack_power", true)
		GameLogger.info("HungerSystem", "No longer starving.")
