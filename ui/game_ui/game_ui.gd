extends CanvasLayer


@export var start_game_button: Button
@export var countdown_label: RichTextLabel
@export var game_over_label: RichTextLabel


signal start_game()
signal countdown_finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerHandler.tube_client.session_created.connect(check_start_button)
	MultiplayerHandler.tube_client.peer_connected.connect(check_start_button)
	MultiplayerHandler.tube_client.peer_disconnected.connect(check_start_button)


func check_start_button(_id = 0) -> void:
	if !multiplayer.is_server(): return
	if multiplayer.get_peers().size() < 1:
		start_game_button.visible = false
	else:
		start_game_button.visible = true


@rpc("any_peer", "call_local", "reliable")
func start_countdown() -> void:
	start_game_button.visible = false

	countdown_label.text = "3"
	countdown_label.visible = true
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "2"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "1"
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = "Start!"
	countdown_finished.emit()
	await get_tree().create_timer(1.0).timeout
	countdown_label.visible = false


func _on_button_pressed() -> void:
	start_game.emit()
	start_countdown.rpc()


func _on_map_game_over(winner: String) -> void:
	start_game_button.visible = true
	game_over.rpc(winner)

@rpc("any_peer", "call_local", "reliable")
func game_over(winner: String) -> void:
	game_over_label.text = "Game Over!\n" + winner + " won"
	game_over_label.visible = true
	await get_tree().create_timer(5.0).timeout
	game_over_label.visible = false


func _on_game_over_gui_input(_event: InputEvent) -> void:
	game_over_label.visible = false
