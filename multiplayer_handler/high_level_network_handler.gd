extends Node


const PLAYER = preload("res://player/player.tscn")
const TUBE_CONTEXT = preload("res://tube_context.tres")

const IP_ADDRESS: String = "localhost"
const PORT: int = 45678

var peer: ENetMultiplayerPeer

@export var tube_client: TubeClient


func start_server() -> String:
	tube_client.create_session()
	return tube_client.session_id

func start_client(id: String) -> void:
	tube_client.join_session(id)

func quit_lobby() -> void:
	print(tube_client.peer_id)
	tube_client.leave_session()
