extends Node3D
class_name Tiles

const V_DIS: float = 3
const H_DIS: float = 1.732

@export_file var hex_model
var hex_grid: Array[Array]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func generate_hex_grid(radius: int) -> void:
	pass
