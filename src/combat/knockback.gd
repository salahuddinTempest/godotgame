class_name Knockback
extends Node
## Physics-based knockback applier.
##
## Attach to CharacterBody3D to handle external impulse forces.

# === Exports ===
@export var character_body: CharacterBody3D
@export var mass: float = 1.0
@export var recovery_rate: float = 5.0

# === Public Variables ===
var knockback_velocity: Vector3 = Vector3.ZERO

# === Lifecycle Methods ===

func _ready() -> void:
	if not character_body:
		character_body = get_parent() as CharacterBody3D

func _physics_process(delta: float) -> void:
	if knockback_velocity.length_squared() > 0.1:
		if character_body:
			character_body.velocity += knockback_velocity
			character_body.move_and_slide() # Let the body handle collisions
			
		# Dampen over time
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, recovery_rate * delta)
	else:
		knockback_velocity = Vector3.ZERO

# === Public Methods ===

func apply_knockback(origin: Vector3, force: float) -> void:
	if not character_body:
		return
		
	var direction: Vector3 = (character_body.global_position - origin).normalized()
	# Optional: Only apply horizontally
	# direction.y = 0.5 # Add a little upward bounce
	# direction = direction.normalized()
	
	var actual_force: float = force / maxf(0.1, mass)
	knockback_velocity += direction * actual_force
