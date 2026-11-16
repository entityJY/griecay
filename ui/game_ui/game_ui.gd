extends CanvasLayer
class_name GameUI


@export var score_ui_element: PackedScene

@export var start_game_button: Button
@export var countdown_label: RichTextLabel
@export var game_over_label: RichTextLabel
@export var score_board_container: VBoxContainer
@export var power_up_selector: PowerUpSelector

var score_ui_element_array: Array[ScoreUI]

var ENABLED_COLOR = "#dfdfdf"
var DISABLED_COLOR = "#dfdfdf80"


signal start_game()
signal countdown_finished()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MultiplayerHandler.tube_client.session_created.connect(check_start_button)
	MultiplayerHandler.tube_client.peer_connected.connect(check_start_button)
	MultiplayerHandler.tube_client.peer_disconnected.connect(check_start_button)
	MultiplayerHandler.tube_client.session_joined.connect(get_current_scores)


	MultiplayerHandler.scoreboard_updated.connect(update_scoreboard)
	MultiplayerHandler.scoreboard_removed_player.connect(scoreboard_remove_user)
	MultiplayerHandler.scoreboard_added_player.connect(scoreboard_add_user)

	disable_start_button()


func enable_start_button() -> void:
	start_game_button.disabled = false
	start_game_button.add_theme_color_override("font_color", Color(ENABLED_COLOR))

func disable_start_button() -> void:
	start_game_button.disabled = true
	start_game_button.add_theme_color_override("font_color", Color(DISABLED_COLOR))


func check_start_button(_id = 0) -> void:
	if !multiplayer.is_server(): return
	if multiplayer.get_peers().size() < 1:
		disable_start_button()
	else:
		enable_start_button()


@rpc("any_peer", "call_local", "reliable")
func start_countdown() -> void:
	disable_start_button()

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
	enable_start_button()
	game_over.rpc(winner)

@rpc("any_peer", "call_local", "reliable")
func game_over(winner: String) -> void:
	game_over_label.text = "Game Over!\n" + winner + " won"
	game_over_label.visible = true
	await get_tree().create_timer(5.0).timeout
	game_over_label.visible = false


func _on_game_over_gui_input(_event: InputEvent) -> void:
	game_over_label.visible = false


func scoreboard_remove_user(id: int) -> void:
	sb_r_u.rpc(id)

@rpc("any_peer", "call_local", "reliable")
func sb_r_u(id: int) -> void:
	var element: ScoreUI = score_ui_element_array[score_ui_element_array.find_custom(func(score_ui: ScoreUI): 
		return score_ui.id == id)]
	score_ui_element_array.erase(element)
	element.queue_free()


func scoreboard_add_user(new_user: Score, id: int) -> void:
	sb_a_u.rpc(new_user.score, new_user.name, id)

@rpc("any_peer", "call_local", "reliable")
func sb_a_u(score: int, _name: String, id: int) -> void:
	var element_index: int = score_ui_element_array.find_custom(func(score_ui: ScoreUI): return score_ui.id == id)
	if element_index == -1:
		var new_element: ScoreUI = score_ui_element.instantiate()
		score_board_container.add_child(new_element)
		new_element.update_entry(Score.new(_name, score), id)
		score_ui_element_array.append(new_element)
	else:
		score_ui_element_array[element_index].update_entry(Score.new(_name, score), id)


func update_scoreboard(id: int, new_score: Score) -> void:
	u_sb.rpc(id, new_score.score, new_score.name)

@rpc("any_peer", "call_local", "reliable")
func u_sb(id: int, score: int, _name: String) -> void:
	score_ui_element_array[score_ui_element_array.find_custom(func(score_ui: ScoreUI): return score_ui.id == id)].update_entry(Score.new(_name, score), id)
	var children = score_board_container.get_children()
	children.sort_custom(func(a: ScoreUI, b: ScoreUI): return a.entry.score < b.entry.score)

func get_current_scores() -> void:
	MultiplayerHandler.send_scores.rpc_id.call_deferred(1, MultiplayerHandler.tube_client.peer_id)
