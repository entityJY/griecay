extends RigidBody3D
class_name Player


@export var target_speed: float = 5.0
@export var jump_force: float = 320.0
@export var MAX_FORCE: float = 40.0
@export var PID_CONSTANTS: Vector3 = Vector3(1.0, 0.0, 0.0)
@export var attack_cooldown: float = 1.0
@export var knockback_impulse: float = 20.0

@export var dash_impulse: float = 10.0
@export var dash_cooldown: float = 2.0
var num_dashes: int = 1
var max_dashes: int = 1

@export_category("Node References")
@export var grounded_marker: RayCast3D
@export var shadow: Sprite3D
@export var shadow_raycast: RayCast3D
@export var animation_player: AnimationPlayer
@export var username: Label3D
@export var color_sprite: Sprite3D

var pid = Pid2D.new()

var grounded: bool = true
var can_move: bool = true
var can_attack: bool = true

var gravity = 0.0


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	PlayerData.set_multiplayer_authority(name.to_int())
	update_colors(PlayerData.color)


func _ready() -> void:
	pid.update_constants(PID_CONSTANTS.x, PID_CONSTANTS.y, PID_CONSTANTS.z)
	gravity = gravity_scale

	update_username_label(PlayerData.username)
	PlayerData.username_changed.connect(update_username_label)
	PlayerData.color_changed.connect(update_colors)


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return

	grounded = grounded_marker.is_colliding()

	if can_move:
		var direction = Vector2(
			Input.get_axis("left", "right"),
			Input.get_axis("up", "down")
		).normalized()

		var target_velocity = direction * target_speed
		var velocity_error = target_velocity - Vector2(linear_velocity.x, linear_velocity.z)

		var force = pid.update(velocity_error, delta)
		var force_3d = Vector3(force.x, 0.0, force.y).limit_length(MAX_FORCE)

		if Input.is_action_pressed("jump") and grounded:
			force_3d.y = jump_force * mass
		
		apply_central_force(force_3d * mass)

		if Input.is_action_just_pressed("dash") and num_dashes > 0:
			apply_central_impulse(dash_impulse * Vector3(direction.x, 0.1, direction.y).normalized())
			num_dashes -= 1
			regen_dash()
		
	if Input.is_action_pressed("attack") and can_attack:
		can_attack = false
		animation_player.play("attack")
		var enable_attack = func(): can_attack = true
		get_tree().create_timer(attack_cooldown).timeout.connect(enable_attack)
	
	if shadow_raycast.is_colliding():
		shadow.visible = true
		shadow.global_position.y = .5
	else:
		shadow.visible = false

func regen_dash() -> void:
	await get_tree().create_timer(dash_cooldown).timeout
	if num_dashes < max_dashes:
		num_dashes += 1
	if num_dashes < max_dashes:
		regen_dash()

func update_username_label(new_name: String) -> void:
	username.text = new_name

func update_colors(new_color) -> void:
	color_sprite.modulate = new_color
	username.modulate = new_color

@rpc("any_peer", "call_local", "reliable")
func apply_teleport(target_pos: Vector3) -> void:
	# prints(multiplayer.get_unique_id(), "apply_teleport", get_multiplayer_authority(), multiplayer.get_remote_sender_id(), target_pos)
	global_position = target_pos

@rpc("any_peer", "call_local", "reliable")
func apply_impulse_to(impulse: Vector3) -> void:
	apply_central_impulse(impulse)

@rpc("any_peer", "call_local", "reliable")
func disable_gravity() -> void:
	gravity_scale = 0.0
	var stop_velocity = func(): linear_velocity.y = 0.0
	stop_velocity.call_deferred()

@rpc("any_peer", "call_local", "reliable")
func enable_gravity() -> void:
	gravity_scale = gravity

@rpc("any_peer", "call_local", "reliable")
func disable_movement() -> void:
	can_move = false

@rpc("any_peer", "call_local", "reliable")
func enable_movement() -> void:
	can_move = true

@rpc("any_peer", "call_local", "reliable")
func stop_movement() -> void:
	linear_velocity = Vector3.ZERO


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var player: Player = body
		var direction = player.global_position - global_position
		direction.y = 0
		direction = direction.normalized()
		var impulse = direction * knockback_impulse
		player.apply_impulse_to.rpc_id(player.get_multiplayer_authority(), impulse)
