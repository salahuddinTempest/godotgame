class_name ThirstSystem
extends Node
## Thirst mechanics per CLAUDE.md.
##
## -0.4/s normal, -1.2/s combat/sprint
## Critical (0): Stamina regeneration -50%

# === Public Variables ===
var current_thirst: float = Constants.THIRST_MAX
var is_critical: bool = false

# === Private Variables ===
var _manager: NeedsManager

# === Public Methods ===

func setup(manager: NeedsManager) -> void:
	_manager = manager
	current_thirst = Constants.THIRST_MAX

func process_tick(delta: float, is_active_state: bool) -> void:
	var drain_rate: float = Constants.THIRST_DRAIN_COMBAT if is_active_state else Constants.THIRST_DRAIN_NORMAL
	current_thirst = maxf(0.0, current_thirst - (drain_rate * delta))
	
	if _manager:
		var pid: int = _manager.get_parent().peer_id if "peer_id" in _manager.get_parent() else 0
		EventBus.thirst_changed.emit(pid, current_thirst)
	
	if current_thirst <= 0.0 and not is_critical:
		_apply_critical()
	elif current_thirst > 0.0 and is_critical:
		_remove_critical()

func drink(amount: float) -> void:
	current_thirst = minf(Constants.THIRST_MAX, current_thirst + amount)
	if current_thirst > 0.0 and is_critical:
		_remove_critical()

# === Private Methods ===

func _apply_critical() -> void:
	is_critical = true
	if _manager and _manager.character_stats:
		# Since stamina regen isn't fully implemented in CharacterStats yet, we use a placeholder or add it
		_manager.character_stats.apply_multiplier("stamina_regen", 1.0 - Constants.THIRST_CRITICAL_STAMINA_PENALTY, true)
		var pid: int = _manager.get_parent().peer_id if "peer_id" in _manager.get_parent() else 0
		EventBus.thirst_critical.emit(pid)
		GameLogger.warn("ThirstSystem", "Dehydrated! Penalties applied.")

func _remove_critical() -> void:
	is_critical = false
	if _manager and _manager.character_stats:
		_manager.character_stats.remove_multiplier("stamina_regen", true)
		GameLogger.info("ThirstSystem", "No longer dehydrated.")
