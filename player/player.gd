extends RigidBody3D
class_name Player


@export var TARGET_SPEED: float = 5.0
@export var JUMP_IMPULSE: float = 10.0
@export var MAX_FORCE: float = 40.0
@export var PID_CONSTANTS: Vector3 = Vector3(1.0, 0.0, 0.0)

@export_category("Node References")
@export var grounded_marker: RayCast3D

var pid = Pid2D.new()

var grounded: bool = true


func _ready() -> void:
	pid.update_constants(PID_CONSTANTS.x, PID_CONSTANTS.y, PID_CONSTANTS.z)


func _physics_process(delta: float) -> void:

	grounded = grounded_marker.is_colliding()

	var direction = Vector2(
		Input.get_axis("left", "right"),
		Input.get_axis("up", "down")
	).normalized()

	var target_velocity = direction * TARGET_SPEED
	var velocity_error = target_velocity - Vector2(linear_velocity.x, linear_velocity.z)

	var force = pid.update(velocity_error, delta)
	var force_3d = Vector3(force.x, 0.0, force.y).limit_length(MAX_FORCE)

	apply_central_force(force_3d * mass)

	if Input.is_action_just_pressed("jump") and grounded:
		apply_central_impulse(Vector3(0.0, JUMP_IMPULSE, 0.0))
