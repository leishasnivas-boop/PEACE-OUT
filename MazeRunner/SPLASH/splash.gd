extends Control
## Title splash: fades the game name in and out, then opens the lobby.
## Press any key or click to skip.

var finished: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var bg := ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	center.add_child(box)

	var title := Label.new()
	title.text = "MAZE RUNNER"
	title.add_theme_font_size_override("font_size", 72)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Run. Escape. Survive."
	subtitle.add_theme_font_size_override("font_size", 28)
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(subtitle)

	# Fade in, hold, fade out, then go to the lobby.
	center.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(center, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.2)
	tween.tween_property(center, "modulate:a", 0.0, 0.8)
	tween.tween_callback(_go_to_lobby)


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventKey and event.pressed) \
			or (event is InputEventMouseButton and event.pressed):
		_go_to_lobby()


func _go_to_lobby() -> void:
	if finished:
		return
	finished = true
	get_tree().change_scene_to_file(GameState.LOBBY_SCENE)
