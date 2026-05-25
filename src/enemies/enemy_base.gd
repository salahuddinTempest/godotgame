class_name EnemyBase
extends CharacterBody3D
## Base class for all enemies.
##
## Manages common enemy logic: stats scaling based on Tier,
## health, death handling, and integration with CombatEngine.

# === Exports ===
@export var enemy_id: String = "base_enemy"
@export var display_name: String = "Enemy"
@export var level: int = 1
@export var tier: Constants.MonsterTier = Constants.MonsterTier.TIER_1_MINION

# Components
@export var ai_controller: EnemyAI

# === Public Variables ===
var stats: CharacterStats

# === Onready ===
@onready var model: Node3D = $Model if has_node("Model") else null
@onready var hitbox: Area3D = $Hitbox if has_node("Hitbox") else null

# === Lifecycle Methods ===

func _ready() -> void:
	_initialize_stats()
	
	if not ai_controller:
		ai_controller = get_node_or_null("EnemyAI") as EnemyAI
		
	if ai_controller:
		ai_controller.setup(self)
		
	if stats:
		stats.died.connect(_on_died)

# === Public Methods ===

func is_alive() -> bool:
	return stats and stats.is_alive()

func get_xp_reward() -> int:
	if not stats:
		return 0
	var tier_mult: float = 1.0 + (int(tier) * 0.5)
	return int(level * Constants.MONSTER_XP_PER_LEVEL * tier_mult)

func take_damage_from(attacker: Node, skill_data: Dictionary) -> void:
	# Typically called by Area3D overlap or Raycast from CombatEngine
	CombatEngine.apply_combat_hit(attacker, self, skill_data)

# === Private Methods ===

func _initialize_stats() -> void:
	stats = CharacterStats.new()
	stats.level = level
	stats.character_name = display_name
	
	# Scale based on tier (per CLAUDE.md)
	var tier_health_bonus: float = int(tier) * 100.0
	stats.base_max_health = (level * float(Constants.MONSTER_HEALTH_PER_LEVEL)) + tier_health_bonus
	
	stats.base_attack_power = float(level * Constants.MONSTER_DAMAGE_PER_LEVEL)
	
	# Apply immediately
	stats.current_health = stats.get_max_health()

func _on_died() -> void:
	# Play death animation, drop loot, queue_free
	if ai_controller:
		ai_controller.change_state(Constants.EnemyState.DEAD)
	
	# Example loot drop
	EventBus.loot_dropped.emit(global_position, ["gold", 10 * level])
	
	# Wait for animation then free
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(queue_free)
