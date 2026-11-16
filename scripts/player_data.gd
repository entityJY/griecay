extends Node


signal username_changed(new_name)

@export var username: String:
    set(new_name):
        username = new_name
        username_changed.emit(new_name)
        send_username()

@rpc("any_peer", "call_local", "reliable")
func send_username() -> void:
    MultiplayerHandler.update_user_name.rpc_id(1, MultiplayerHandler.tube_client.peer_id, username)
