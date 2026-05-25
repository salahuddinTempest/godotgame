extends Node

class_name FireballSkill

enum SkillType {
	MELEE,
	RANGED_SHOT,
	PROJECTILE,
	SELF_HEAL,
	AOE,
}

@export var base_damage: float = 50.0
@export var speed: float = 800.0
@export var explosion_radius: float = 64.0

var description: String = ""
var icon: Resource = null
var type: SkillType = SkillType.RANGED_SHOT
var cooldown: float = 4.0
var mana_cost: float = 35.0

func _ready() -> void:
	name = "Fireball"
	description = "Launch a fiery projectile that explodes on impact."
	type = SkillType.RANGED_SHOT
	cooldown = 4.0
	mana_cost = 35.0

func cast(caster: Node, target_position: Vector3) -> void:
	push_warning("Fireball cast: not yet implemented (requires projectile.tscn)")
