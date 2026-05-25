class_name CharacterStats
extends Resource
## Stats calculation engine untuk player dan enemy.
##
## Semua stat dihitung dari base + equipment + buffs.
## Gunakan signal untuk notify perubahan ke UI.

# === Signals ===
signal health_changed(current: float, maximum: float)
signal mana_changed(current: float, maximum: float)
signal stamina_changed(current: float, maximum: float)
signal stats_recalculated()
signal died()

# === Exports ===
@export_group("Base Stats")
@export var character_name: String = "Adventurer"
@export var level: int = 1
@export var character_class: Constants.CharacterClass = Constants.CharacterClass.ADVENTURER

@export_group("Health & Resources")
@export var base_max_health: float = 100.0
@export var base_max_mana: float = 50.0
@export var base_max_stamina: float = 100.0

@export_group("Offense")
@export var base_attack_power: float = 10.0
@export var base_magic_power: float = 5.0
@export var base_attack_speed: float = 1.0
@export var base_crit_rate: float = 0.0    # Added on top of BASE_CRIT_CHANCE

@export_group("Defense")
@export var base_defense: float = 5.0
@export var base_magic_resist: float = 3.0
@export var base_dodge_chance: float = 0.05

@export_group("Movement")
@export var base_move_speed: float = 5.0
@export var base_jump_height: float = 5.0

# === Public Variables ===
var current_health: float = 100.0
var current_mana: float = 50.0
var current_stamina: float = 100.0
var xp: int = 0
var xp_to_next_level: int = 100

# Bonus from equipment (recalculated when equipping/removing)
var equipment_health_bonus: float = 0.0
var equipment_attack_bonus: float = 0.0
var equipment_defense_bonus: float = 0.0
var equipment_speed_bonus: float = 0.0

# Bonus from buffs/debuffs (temporary)
var buff_multipliers: Dictionary = {}   # stat_name -> multiplier
var debuff_multipliers: Dictionary = {} # stat_name -> multiplier

# === Private Variables ===
var _is_dead: bool = false

# === Lifecycle Methods ===

func _init() -> void:
	xp_to_next_level = _calculate_xp_to_level(level + 1)
	current_health = get_max_health()
	current_mana = get_max_mana()
	current_stamina = get_max_stamina()

# === Public Calculated Stats ===

func get_max_health() -> float:
	var base: float = base_max_health + equipment_health_bonus
	base += (level - 1) * 10.0  # +10 HP per level
	return _apply_multipliers(base, "max_health")

func get_max_mana() -> float:
	var base: float = base_max_mana
	base += (level - 1) * 5.0
	return _apply_multipliers(base, "max_mana")

func get_max_stamina() -> float:
	return _apply_multipliers(base_max_stamina, "max_stamina")

func get_attack_power() -> float:
	var base: float = base_attack_power + equipment_attack_bonus
	base += (level - 1) * 2.0
	return _apply_multipliers(base, "attack_power")

func get_magic_power() -> float:
	return _apply_multipliers(base_magic_power + (level - 1) * 1.5, "magic_power")

func get_defense() -> float:
	return _apply_multipliers(base_defense + equipment_defense_bonus, "defense")

func get_magic_resist() -> float:
	return _apply_multipliers(base_magic_resist, "magic_resist")

func get_move_speed() -> float:
	return _apply_multipliers(base_move_speed + equipment_speed_bonus, "move_speed")

func get_crit_rate() -> float:
	return clampf(Constants.BASE_CRIT_CHANCE + base_crit_rate, 0.0, 1.0)

func get_defense_reduction() -> float:
	# Defense to % reduction (diminishing returns formula)
	var def: float = get_defense()
	return def / (def + 100.0)

# === Health / Damage Methods ===

func take_damage(amount: float) -> float:
	if _is_dead:
		return 0.0
	var actual: float = maxf(0.0, amount)
	current_health = maxf(0.0, current_health - actual)
	health_changed.emit(current_health, get_max_health())
	if current_health <= 0.0:
		_on_died()
	return actual

func heal(amount: float) -> float:
	if _is_dead:
		return 0.0
	var max_hp: float = get_max_health()
	var before: float = current_health
	current_health = minf(max_hp, current_health + amount)
	var healed: float = current_health - before
	if healed > 0.0:
		health_changed.emit(current_health, max_hp)
	return healed

func use_mana(amount: float) -> bool:
	if current_mana < amount:
		return false
	current_mana -= amount
	mana_changed.emit(current_mana, get_max_mana())
	return true

func restore_mana(amount: float) -> void:
	current_mana = minf(get_max_mana(), current_mana + amount)
	mana_changed.emit(current_mana, get_max_mana())

func is_alive() -> bool:
	return not _is_dead

func get_health_percent() -> float:
	return current_health / get_max_health()

# === XP & Leveling ===

func add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_to_next_level and level < Constants.MAX_PLAYER_LEVEL:
		_level_up()

func _level_up() -> void:
	xp -= xp_to_next_level
	level += 1
	xp_to_next_level = _calculate_xp_to_level(level + 1)
	# Fully restore on level up
	current_health = get_max_health()
	current_mana = get_max_mana()
	stats_recalculated.emit()
	EventBus.player_level_up.emit(get_instance_id(), level)
	GameLogger.info("CharacterStats", "%s reached level %d!" % [character_name, level])

func _calculate_xp_to_level(target_level: int) -> int:
	return target_level * 100 + (target_level - 1) * 50

# === Buff / Debuff ===

func apply_multiplier(stat_name: String, multiplier: float, is_debuff: bool = false) -> void:
	var dict: Dictionary = debuff_multipliers if is_debuff else buff_multipliers
	dict[stat_name] = multiplier
	stats_recalculated.emit()

func remove_multiplier(stat_name: String, is_debuff: bool = false) -> void:
	var dict: Dictionary = debuff_multipliers if is_debuff else buff_multipliers
	dict.erase(stat_name)
	stats_recalculated.emit()

# === Private Methods ===

func _apply_multipliers(base_value: float, stat_name: String) -> float:
	var result: float = base_value
	if buff_multipliers.has(stat_name):
		result *= buff_multipliers[stat_name]
	if debuff_multipliers.has(stat_name):
		result *= debuff_multipliers[stat_name]
	return result

func _on_died() -> void:
	if _is_dead:
		return
	_is_dead = true
	died.emit()
	GameLogger.info("CharacterStats", "%s died." % character_name)
