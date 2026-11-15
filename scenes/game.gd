extends Node3D


@export var spawn_position: Node3D

var game_started: bool = false

var alive_players: Array[Player]

signal game_over(winner: String)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if !multiplayer.is_server(): return

	if body is Player:
		var player: Player = body
		player.apply_teleport.rpc_id(player.get_multiplayer_authority(), spawn_position.global_position)
		if game_started:
			player.disable_gravity.rpc_id(player.get_multiplayer_authority())
			alive_players.erase(player)
			if len(alive_players) <= 1:
				reset_game(alive_players[0].username.text)


func reset_game(winner: String) -> void:
	game_over.emit(winner)
	for node in spawn_position.get_children():
		if node is not Player: continue
		var player: Player = node

		var authority = player.get_multiplayer_authority()
		player.enable_movement.rpc_id(authority)
		player.enable_gravity.rpc_id(authority)
		player.apply_teleport.rpc_id(authority, spawn_position.global_position)


func _on_game_ui_start_game() -> void:
	if !multiplayer.is_server(): return

	game_started = true
	MultiplayerHandler.tube_client.refuse_new_connections = true
	alive_players = []

	var players = spawn_position.get_children()
	for i in range(len(players)):
		var angle = (i * TAU) / len(players)
	
		var x = cos(angle) * 5
		var z = sin(angle) * 5

		var player: Player = players[i] as Player
		var authority = player.get_multiplayer_authority()
		player.disable_movement.rpc_id(authority)
		player.disable_gravity.rpc_id(authority)
		player.apply_teleport.rpc_id.call_deferred(authority, Vector3(x, 5, z))
		player.stop_movement.rpc_id.call_deferred(authority)

		alive_players.append(player)


func _on_game_ui_countdown_finished() -> void:
	if !multiplayer.is_server(): return

	var players = spawn_position.get_children()
	for i in range(len(players)):
		var player: Player = players[i] as Player
		var authority = player.get_multiplayer_authority()
		player.enable_movement.rpc_id(authority)
		player.enable_gravity.rpc_id(authority)
