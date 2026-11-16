extends Node


const PLAYER = preload("res://player/player.tscn")
const TUBE_CONTEXT = preload("res://tube_context.tres")

@export var tube_client: TubeClient

var usernames: Dictionary[int, Score]

signal scoreboard_updated(id: int, new_score: Score)
signal scoreboard_removed_player(id: int)
signal scoreboard_added_player(new_user: Score, id: int)


func _ready() -> void:
	tube_client.peer_connected.connect(set_initial_username)
	tube_client.peer_disconnected.connect(remove_user_name)
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
	if tube_client.session_id != "" and multiplayer.is_server():
		usernames[id] = Score.new(username, 0)
		scoreboard_added_player.emit(usernames[id], id)

func remove_user_name(id: int) -> void:
	usernames.erase(id)
	scoreboard_removed_player.emit(id)

func increment_score(id: int, new_score: int) -> void:
	usernames[id].score += new_score
	scoreboard_updated.emit(id, usernames[id])


@rpc("any_peer", "call_local", "reliable")
func send_user(id: int, _name: String, _score: int) -> void:
	if tube_client.session_id != "":
		scoreboard_added_player.emit(Score.new(_name, _score), id)

@rpc("any_peer", "call_local", "reliable")
func send_scores(id: int) -> void:
	for score_id in usernames.keys():
		send_user.rpc_id(id, score_id, usernames[score_id].name, usernames[score_id].score)
