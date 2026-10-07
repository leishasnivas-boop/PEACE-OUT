extends CanvasLayer
## In-game overlay: timer, stamina bar, hint message and a danger warning.

var time_label: Label
var message_label: Label
var danger_label: Label
var stamina_bar: ProgressBar


func _ready() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	time_label = _make_label(root, Vector2(24, 16), 30)
	message_label = _make_label(root, Vector2(24, 56), 22)

	danger_label = _make_label(root, Vector2(0, 0), 44)
	danger_label.text = "! DANGER !"
	danger_label.add_theme_color_override("font_color", Color(1, 0.15, 0.15))
	danger_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	danger_label.position.y = 24
	danger_label.visible = false

	stamina_bar = ProgressBar.new()
	stamina_bar.max_value = 1.0
	stamina_bar.value = 1.0
	stamina_bar.show_percentage = false
	stamina_bar.custom_minimum_size = Vector2(220, 14)
	stamina_bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	stamina_bar.position = Vector2(24, -40)
	root.add_child(stamina_bar)


func _make_label(parent: Control, pos: Vector2, size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	parent.add_child(label)
	return label


func set_time(text: String) -> void:
	time_label.text = "Time  " + text


func set_message(text: String) -> void:
	message_label.text = text


func set_danger(on: bool) -> void:
	danger_label.visible = on


func set_stamina(ratio: float) -> void:
	stamina_bar.value = ratio
