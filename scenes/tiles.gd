extends Node3D
class_name Tiles


const V_DIS: float = 1.5
const H_DIS: float = 1.732


@export var hex_model: PackedScene
@export var initial_radius: int = 5

var hex_grid: Dictionary[Vector2, Tile]

var tiles_falling: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		generate_hex_grid(initial_radius)

func generate_hex_grid(radius: int) -> void:
	if !multiplayer.is_server(): return
	for q in range(-radius, radius + 1):
		var r1 = maxf(-radius, -q - radius)
		var r2 = minf(radius, -q + radius)
		for r in range(r1, r2 + 1):
			var new_tile: Tile = hex_model.instantiate()
			new_tile.position = Vector3(H_DIS*(q+float(r)/2), 0, V_DIS*r)
			self.add_child(new_tile)

			hex_grid[Vector2(q, r)] = new_tile

func reset_tiles() -> void:
	if !multiplayer.is_server(): return
	for tile in hex_grid.values():
		tile.reset_tile()

func drop_tiles() -> void:
	if !multiplayer.is_server(): return
	var non_dropped_tiles: Array[Tile] = hex_grid.values()
	while !non_dropped_tiles.is_empty():
		await get_tree().create_timer(clampf(randfn(1.0, .5), 0.0, 5.0)).timeout
		if !tiles_falling:
			break
		var tile: Tile = non_dropped_tiles.pop_at(randi() % non_dropped_tiles.size())
		tile.drop_tile()
