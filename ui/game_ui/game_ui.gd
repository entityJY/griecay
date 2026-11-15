extends CanvasLayer


@export var start_game_button: Button
@export var countdown_label: RichTextLabel


signal start_game()
signal countdown_finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerHandler.tube_client.session_created.connect(enable_start_button)


func enable_start_button() -> void:
	if multiplayer.is_server():
		start_game_button.visible = true

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
	start_countdown()
