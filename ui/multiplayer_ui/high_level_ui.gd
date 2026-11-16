extends CanvasLayer


@export var session_id_button: Button
@export var input_session_id: LineEdit
@export var user_name_edit: LineEdit


func _ready() -> void:
	user_name_edit.text = PlayerData.username


func _on_server_pressed() -> void:
	session_id_button.text = MultiplayerHandler.start_server()


func _on_client_pressed() -> void:
	MultiplayerHandler.start_client(input_session_id.text)


func _on_quit_pressed() -> void:
	MultiplayerHandler.quit_lobby()
	get_tree().reload_current_scene()


func _on_session_id_pressed() -> void:
	DisplayServer.clipboard_set(session_id_button.text)


func _on_line_edit_text_changed(new_text: String) -> void:
	PlayerData.username = new_text
