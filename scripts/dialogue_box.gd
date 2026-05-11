extends Control

const Autoload := preload("res://scripts/autoload_access.gd")

signal dialogue_dismissed

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/MarginContainer/Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
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
	_apply_font_size()
	var gs := Autoload.settings(get_tree())
	if gs:
		gs.connect("dialogue_font_size_changed", func(_s): _apply_font_size())


func _apply_font_size() -> void:
	var sz: int = 18
	var gs := Autoload.settings(get_tree())
	if gs:
		sz = int(gs.get("dialogue_font_size"))
	if sz < 12:
		sz = 18
	sz = clampi(sz, 12, 28)
	_label.add_theme_font_size_override("font_size", sz)
	_label.add_theme_color_override("font_color", Color(0.65, 1, 0.85, 1))


func show_message(text: String) -> void:
	var body := text.replace("\n", "\n| ")
	var hint := "\n| \n| [Space / Enter / Click to continue]\n+------------------------------------------------+"
	_label.text = "+------------------------------------------------+\n| " + body + hint
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP


func hide_box() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialogue_dismissed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_accept") or event.is_action_pressed(&"ui_cancel"):
		hide_box()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.pressed:
		hide_box()
		accept_event()
