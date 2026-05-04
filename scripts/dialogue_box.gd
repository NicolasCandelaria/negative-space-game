extends Control

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/MarginContainer/Label


func _ready() -> void:
	visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.98, 0.98, 0.98, 1)
	sb.set_border_width_all(6)
	sb.border_color = Color.BLACK
	sb.set_corner_radius_all(2)
	sb.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", sb)
	_label.add_theme_font_size_override("font_size", 19)
	_label.add_theme_color_override("font_color", Color.BLACK)


func show_message(text: String) -> void:
	_label.text = text
	visible = true


func hide_box() -> void:
	visible = false
