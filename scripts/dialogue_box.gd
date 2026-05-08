extends Control

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/MarginContainer/Label


func _ready() -> void:
	visible = false
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.03, 0.04, 0.06, 0.96)
	sb.set_border_width_all(3)
	sb.border_color = Color(0.3, 0.95, 0.55, 1)
	sb.set_corner_radius_all(2)
	sb.set_content_margin_all(16)
	_panel.add_theme_stylebox_override("panel", sb)
	var sf := SystemFont.new()
	sf.font_names = ["Consolas", "Courier New", "monospace"]
	_label.add_theme_font_override("font", sf)
	_label.add_theme_font_size_override("font_size", 18)
	_label.add_theme_color_override("font_color", Color(0.65, 1, 0.85, 1))


func show_message(text: String) -> void:
	var body := text.replace("\n", "\n| ")
	_label.text = "+------------------------------------------------+\n| " + body + "\n+------------------------------------------------+"
	visible = true


func hide_box() -> void:
	visible = false
