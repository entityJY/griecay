extends AnimatableBody3D
class_name Tile


var target_position: Vector3
var movement_tween: Tween
var initial_position: Vector3

func _ready() -> void:
	target_position = global_position
	target_position.y = -20

func _enter_tree() -> void:
	initial_position = global_position

func drop_tile() -> void:
	movement_tween = create_tween().set_loops().set_parallel(false)
	# Move to the target position relative to the start
	movement_tween.tween_property(self, "position", target_position, 4.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func reset_tile() -> void:
	global_position = initial_position
	if movement_tween:
		movement_tween.kill()
