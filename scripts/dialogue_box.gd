extends Control

signal dialogue_dismissed

@onready var _panel: Panel = $Panel
@onready var _label: Label = $Panel/MarginContainer/Label
@onready var _hint: Label = $Panel/MarginContainer/FooterHint


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
	_hint.add_theme_font_override("font", sf)
	_apply_font_size()
	GameSettings.dialogue_font_size_changed.connect(func(_s): _apply_font_size())
	_hint.text = "[Space / Enter / Click to continue]"
	_hint.add_theme_color_override("font_color", Color(0.45, 0.85, 0.65, 0.95))


func _apply_font_size() -> void:
	var sz: int = GameSettings.dialogue_font_size
	_label.add_theme_font_size_override("font_size", sz)
	_hint.add_theme_font_size_override("font_size", maxi(12, sz - 4))


func show_message(text: String) -> void:
	var body := text.replace("\n", "\n| ")
	_label.text = "+------------------------------------------------+\n| " + body + "\n+------------------------------------------------+"
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
