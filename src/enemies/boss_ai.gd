class_name BossAI
extends EnemyAI
## Specialized AI for Boss encounters.
##
## Implements complex patterns and phase transitions based on health thresholds.

# === Public Variables ===
var current_phase: int = 1

# === Private Variables ===
var _phase_thresholds: Array[float] = [0.66, 0.33] # Transitions at 66% and 33% HP

# === Public Methods ===

func setup(body: EnemyBase) -> void:
	super.setup(body)
	if _body and _body.stats:
		_body.stats.health_changed.connect(_on_health_changed)

# === Private Methods ===

func _on_health_changed(current: float, maximum: float) -> void:
	var percent: float = current / maximum
	
	if current_phase == 1 and percent <= _phase_thresholds[0]:
		_transition_to_phase(2)
	elif current_phase == 2 and percent <= _phase_thresholds[1]:
		_transition_to_phase(3)

func _transition_to_phase(new_phase: int) -> void:
	current_phase = new_phase
	GameLogger.info("BossAI", "Transitioning to Phase %d!" % new_phase)
	
	# Temporary invulnerability or AoE knockback
	# Change attack patterns (e.g., increase speed, unlock new skills)
	
	if _body and _body.stats:
		_body.stats.apply_multiplier("attack_power", 1.0 + (0.2 * new_phase)) # +20% damage per phase
		_body.stats.apply_multiplier("move_speed", 1.0 + (0.1 * new_phase))   # +10% speed per phase

func _process_combat(delta: float) -> void:
	if not _is_target_valid():
		change_state(Constants.EnemyState.PATROL)
		return
		
	# Bosses don't retreat
	
	var dist: float = _body.global_position.distance_to(target.global_position)
	if dist > attack_range:
		change_state(Constants.EnemyState.PURSUIT)
		return
		
	# Phase-specific attacks
	match current_phase:
		1:
			_execute_phase1_attack()
		2:
			_execute_phase2_attack()
		3:
			_execute_phase3_attack()

func _execute_phase1_attack() -> void:
	pass

func _execute_phase2_attack() -> void:
	pass

func _execute_phase3_attack() -> void:
	pass
