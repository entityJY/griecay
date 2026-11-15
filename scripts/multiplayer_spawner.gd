extends MultiplayerSpawner


@export var network_player: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerHandler.tube_client.peer_connected.connect(spawn_player)
	MultiplayerHandler.tube_client.session_created.connect(spawn_host)
	MultiplayerHandler.tube_client.peer_disconnected.connect(remove_player)

func spawn_host() -> void:
	if !multiplayer.is_server(): return

	var player: Node = network_player.instantiate()
	player.name = str(MultiplayerHandler.tube_client.peer_id)

	get_node(spawn_path).call_deferred("add_child", player)

func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return

	var player: Node = network_player.instantiate()
	player.name = str(id)

	get_node(spawn_path).call_deferred("add_child", player)

func remove_player(id: int) -> void:
	if multiplayer.is_server():
		get_node(spawn_path).find_child(str(id), true, false).queue_free()
