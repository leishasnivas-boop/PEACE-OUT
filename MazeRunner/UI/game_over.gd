extends CanvasLayer
## Result screen shown after winning or losing.

var title_label: Label
var info_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep working while the game is paused
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.75)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	center.add_child(box)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 56)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title_label)

	info_label = Label.new()
	info_label.add_theme_font_size_override("font_size", 24)
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(info_label)

	var again := Button.new()
	again.text = "Play Again"
	again.custom_minimum_size = Vector2(240, 48)
	again.pressed.connect(_on_play_again)
	box.add_child(again)

	var lobby := Button.new()
	lobby.text = "Back to Lobby"
	lobby.custom_minimum_size = Vector2(240, 48)
	lobby.pressed.connect(_on_lobby)
	box.add_child(lobby)


func show_result(won: bool, time_text: String, new_record: bool) -> void:
	if won:
		title_label.text = "YOU ESCAPED!"
		title_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
		info_label.text = "Escape time: " + time_text
		if new_record:
			info_label.text += "   (NEW BEST!)"
	else:
		title_label.text = "CAUGHT!"
		title_label.add_theme_color_override("font_color", Color(1.0, 0.25, 0.25))
		info_label.text = "You survived for " + time_text
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true


func _on_play_again() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_lobby() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(GameState.LOBBY_SCENE)
