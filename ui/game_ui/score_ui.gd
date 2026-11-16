extends PanelContainer
class_name ScoreUI


@export var username_label: RichTextLabel
@export var score_label: RichTextLabel

var entry: Score
var id: int

func update_entry(new_entry: Score, _id: int) -> void:
	entry = new_entry
	username_label.text = entry.name
	score_label.text = str(entry.score)
	id = _id
