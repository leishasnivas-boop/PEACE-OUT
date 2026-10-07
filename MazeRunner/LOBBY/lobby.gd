extends Control
## Main menu: shows the controls and best time, and starts the game.


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.07)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	var title := Label.new()
	title.text = "MAZE RUNNER"
	title.add_theme_font_size_override("font_size", 64)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)

	var goal := Label.new()
	goal.text = "Reach the green exit before the enemy catches you."
	goal.add_theme_font_size_override("font_size", 22)
	goal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(goal)

	var controls := Label.new()
	controls.text = "WASD / Arrows: move     Mouse: look     Shift: sprint     Esc: free mouse"
	controls.add_theme_font_size_override("font_size", 18)
	controls.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(controls)

	var best := Label.new()
	if GameState.best_time > 0.0:
		best.text = "Best escape: " + GameState.format_time(GameState.best_time)
	else:
		best.text = "Best escape: --"
	best.add_theme_font_size_override("font_size", 20)
	best.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(best)

	var start := Button.new()
	start.text = "Start Game"
	start.custom_minimum_size = Vector2(260, 52)
	start.pressed.connect(_on_start)
	box.add_child(start)

	var quit := Button.new()
	quit.text = "Quit"
	quit.custom_minimum_size = Vector2(260, 52)
	quit.pressed.connect(_on_quit)
	box.add_child(quit)


func _on_start() -> void:
	get_tree().change_scene_to_file(GameState.MAP_SCENE)


func _on_quit() -> void:
	get_tree().quit()
