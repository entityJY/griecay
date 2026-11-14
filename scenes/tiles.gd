extends Node3D
class_name Tiles


const V_DIS: float = 1.5
const H_DIS: float = 1.732


@export var hex_model: PackedScene
@export var initial_radius: int = 5

var hex_grid: Dictionary[Vector2, Node]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# var origin = hex_model.instantiate()
	# self.add_child(origin)
	# hex_grid[Vector3(0, 0, 0)] = origin

	generate_hex_grid(initial_radius)

func generate_hex_grid(radius: int) -> void:
	for q in range(-radius, radius + 1):
		var r1 = maxf(-radius, -q - radius)
		var r2 = minf(radius, -q + radius)
		for r in range(r1, r2 + 1):
			var new_tile: Node3D = hex_model.instantiate()
			self.add_child(new_tile)
			new_tile.position = Vector3(H_DIS*(q+float(r)/2), 0, V_DIS*r)
			hex_grid[Vector2(q, r)] = new_tile
