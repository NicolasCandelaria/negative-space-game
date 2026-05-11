extends CanvasLayer

const Autoload := preload("res://scripts/autoload_access.gd")

## Boot menu, pause, hints, web audio gate, debug overlay.

@onready var _hints: Label = $Hints
@onready var _banner: Label = $LevelBanner
@onready var _boot: Control = $BootMenu
@onready var _boot_continue: Button = $BootMenu/VBox/ContinueBtn
@onready var _boot_new: Button = $BootMenu/VBox/NewGameBtn

@onready var _pause: Control = $PauseMenu
@onready var _pause_resume: Button = $PauseMenu/Panel/VBox/ResumeBtn
@onready var _pause_restart: Button = $PauseMenu/Panel/VBox/RestartBtn
@onready var _pause_full: Button = $PauseMenu/Panel/VBox/FullscreenBtn
@onready var _pause_mouse: CheckBox = $PauseMenu/Panel/VBox/MouseMoveCheck
@onready var _pause_sfx: CheckBox = $PauseMenu/Panel/VBox/SfxCheck
@onready var _pause_small: Button = $PauseMenu/Panel/VBox/SmallTextBtn
@onready var _pause_large: Button = $PauseMenu/Panel/VBox/LargeTextBtn
@onready var _controls_block: Label = $PauseMenu/Panel/VBox/ControlsBlock

@onready var _web_gate: Control = $WebAudioGate
@onready var _web_btn: Button = $WebAudioGate/CenterContainer/Button

@onready var _debug: Label = $DebugHud

var _main: Node
var _paused: bool = false
var _debug_visible: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 110
	_main = get_parent()
	_hints.text = "WASD / arrows · hold LMB steer (opt.) · R restart · Esc pause · F3 debug"

	_boot.visible = false
	_pause.visible = false
	_banner.visible = false
	_debug.visible = false

	_controls_block.text = "Move: WASD or Arrow keys\nRestart level: R\nPause: Esc\nAdvance dialogue: Space / Enter / Click"

	var gs := _gs()
	if gs:
		_pause_mouse.button_pressed = bool(gs.get("mouse_move_enabled"))
		_pause_sfx.button_pressed = bool(gs.get("sfx_enabled"))
		if gs.has_signal("mouse_move_changed"):
			gs.connect("mouse_move_changed", func(v): _pause_mouse.button_pressed = v)
		if gs.has_signal("sfx_changed"):
			gs.connect("sfx_changed", func(v): _pause_sfx.button_pressed = v)

	_boot_continue.pressed.connect(_on_boot_continue)
	_boot_new.pressed.connect(_on_boot_new)
	_pause_resume.pressed.connect(_unpause)
	_pause_restart.pressed.connect(_on_pause_restart)
	_pause_full.pressed.connect(_toggle_fullscreen)
	_pause_mouse.toggled.connect(_on_mouse_toggled)
	_pause_sfx.toggled.connect(_on_sfx_toggled)
	_pause_small.pressed.connect(func(): _call_settings("set_dialogue_font_size", 16))
	_pause_large.pressed.connect(func(): _call_settings("set_dialogue_font_size", 22))

	_web_gate.visible = false

	for n: Node in [_boot, _pause, _web_gate]:
		n.process_mode = Node.PROCESS_MODE_ALWAYS

	if _main.has_signal("level_loaded"):
		_main.level_loaded.connect(_on_main_level_loaded)

	call_deferred("_bootstrap_flow")


func _gs() -> Node:
	return Autoload.settings(get_tree())


func _call_settings(method: String, arg = null) -> void:
	var gs := _gs()
	if gs == null or not gs.has_method(method):
		return
	if arg == null:
		gs.call(method)
	else:
		gs.call(method, arg)


func _on_mouse_toggled(p: bool) -> void:
	_call_settings("set_mouse_move_enabled", p)


func _on_sfx_toggled(p: bool) -> void:
	_call_settings("set_sfx_enabled", p)


func _bootstrap_flow() -> void:
	if OS.has_feature("web"):
		_web_gate.visible = true
		get_tree().paused = true
		_web_btn.pressed.connect(_on_web_unlock)
		return

	_flow_boot()


func _flow_boot() -> void:
	var gs := _gs()
	var show_boot := false
	if gs and gs.has_method("should_show_boot_menu"):
		show_boot = bool(gs.call("should_show_boot_menu"))
	if show_boot:
		_boot.visible = true
		_boot_continue.visible = true
		_boot_continue.disabled = false
	else:
		_main.call("start_at_level", _continue_index())


func _continue_index() -> int:
	var gs := _gs()
	if gs:
		return clampi(int(gs.get("last_level_index")), 0, 8)
	return 0


func _on_web_unlock() -> void:
	var ga := Autoload.audio(get_tree())
	if ga and ga.has_method("unlock_web_audio"):
		ga.call("unlock_web_audio")
	_web_gate.visible = false
	get_tree().paused = false
	_flow_boot()


func _on_boot_continue() -> void:
	_boot.visible = false
	_main.call("start_at_level", _continue_index())


func _on_boot_new() -> void:
	_call_settings("reset_progress")
	_boot.visible = false
	_main.call("start_at_level", 0)


func _on_main_level_loaded(index: int, display_name: String) -> void:
	_banner.text = "Level %d — %s" % [index + 1, display_name]
	_banner.visible = true
	_banner.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_property(_banner, "modulate:a", 0.0, 2.5).set_delay(1.4)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if _web_gate.visible:
		return
	if _boot.visible:
		return
	if event.is_action_pressed(&"toggle_debug"):
		_debug_visible = not _debug_visible
		_debug.visible = _debug_visible
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed(&"pause_game"):
		if _paused:
			_unpause()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()
		return
	if _paused:
		return
	if event.is_action_pressed(&"restart_level"):
		if _main.has_method("restart_current_level"):
			_main.restart_current_level()
		get_viewport().set_input_as_handled()


func _pause_game() -> void:
	_paused = true
	_pause.visible = true
	get_tree().paused = true


func _unpause() -> void:
	_paused = false
	_pause.visible = false
	get_tree().paused = false


func _on_pause_restart() -> void:
	_unpause()
	if _main.has_method("restart_current_level"):
		_main.restart_current_level()


func _toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _process(_delta: float) -> void:
	if not _debug_visible:
		return
	var idx := -1
	if _main.get("current_level_index") != null:
		idx = _main.current_level_index
	var fps := Engine.get_frames_per_second()
	_debug.text = "FPS: %d\nLevel index: %s\nPaused: %s" % [fps, idx, _paused]
