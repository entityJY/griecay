extends Node


const PLAYER = preload("res://player/player.tscn")
const TUBE_CONTEXT = preload("res://tube_context.tres")

@export var tube_client: TubeClient

var usernames: Dictionary[int, String]


func _ready() -> void:
	tube_client.peer_connected.connect(set_initial_username)
	tube_client.peer_disconnected.connect(set_initial_username)
	tube_client.session_created.connect(set_initial_username)

func start_server() -> String:
	tube_client.create_session()
	return tube_client.session_id

func start_client(id: String) -> void:
	tube_client.join_session(id)

func quit_lobby() -> void:
	tube_client.leave_session()


func set_initial_username(id: int = 1) -> void:
	if multiplayer.is_server():
		PlayerData.send_username.rpc_id(id)

@rpc("any_peer", "call_local", "reliable")
func update_user_name(id: int, username: String) -> void:
	if MultiplayerHandler.tube_client.session_id != "" and multiplayer.is_server():
		usernames[id] = username
