extends LineEdit

func _input(event: InputEvent) -> void:
	# Check if the user pressed the left mouse button
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if the click happened outside this LineEdit's rectangle
		if not get_global_rect().has_point(event.position):
			release_focus()
