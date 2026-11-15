extends RigidBody3D
class_name Player


@export var TARGET_SPEED: float = 5.0
@export var JUMP_IMPULSE: float = 10.0
@export var MAX_FORCE: float = 40.0
@export var PID_CONSTANTS: Vector3 = Vector3(1.0, 0.0, 0.0)

@export_category("Node References")
@export var grounded_marker: RayCast3D
@export var shadow: Sprite3D
@export var shadow_raycast: RayCast3D

var pid = Pid2D.new()

var grounded: bool = true
var can_move: bool = true

var gravity = 0.0


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	pid.update_constants(PID_CONSTANTS.x, PID_CONSTANTS.y, PID_CONSTANTS.z)
	gravity = gravity_scale


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return

	grounded = grounded_marker.is_colliding()

	if can_move:
		var direction = Vector2(
			Input.get_axis("left", "right"),
			Input.get_axis("up", "down")
		).normalized()

		var target_velocity = direction * TARGET_SPEED
		var velocity_error = target_velocity - Vector2(linear_velocity.x, linear_velocity.z)

		var force = pid.update(velocity_error, delta)
		var force_3d = Vector3(force.x, 0.0, force.y).limit_length(MAX_FORCE)

		apply_central_force(force_3d * mass)

	if Input.is_action_pressed("jump") and grounded:
		apply_central_force(Vector3(0.0, JUMP_IMPULSE * mass, 0.0))
	
	if shadow_raycast.is_colliding():
		shadow.visible = true
		shadow.global_position.y = .5
	else:
		shadow.visible = false


@rpc("any_peer", "call_local", "reliable")
func apply_teleport(target_pos: Vector3):
	prints(multiplayer.get_unique_id(), "apply_teleport", get_multiplayer_authority(), multiplayer.get_remote_sender_id(), target_pos)
	global_position = target_pos

@rpc("any_peer", "call_local", "reliable")
func apply_impulse_to(impulse: Vector3):
	apply_central_impulse(impulse)

@rpc("any_peer", "call_local", "reliable")
func disable_gravity():
	gravity_scale = 0.0
	var stop_velocity = func(): linear_velocity.y = 0.0
	stop_velocity.call_deferred()

@rpc("any_peer", "call_local", "reliable")
func enable_gravity():
	gravity_scale = gravity

@rpc("any_peer", "call_local", "reliable")
func disable_movement():
	can_move = false

@rpc("any_peer", "call_local", "reliable")
func enable_movement():
	can_move = true
