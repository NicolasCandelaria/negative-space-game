extends Node

## Progress + player preferences (user://negative_space.cfg)

const CFG_PATH := "user://negative_space.cfg"

var last_level_index: int = 0
var best_completed_index: int = -1

var dialogue_font_size: int = 18
var mouse_move_enabled: bool = false
var sfx_enabled: bool = true

signal dialogue_font_size_changed(size: int)
signal mouse_move_changed(enabled: bool)
signal sfx_changed(enabled: bool)


func _ready() -> void:
	load_all()


func load_all() -> void:
	var cf := ConfigFile.new()
	if cf.load(CFG_PATH) != OK:
		return
	last_level_index = int(cf.get_value("progress", "last_level", 0))
	best_completed_index = int(cf.get_value("progress", "best_completed", -1))
	dialogue_font_size = int(cf.get_value("prefs", "dialogue_font_size", 18))
	mouse_move_enabled = bool(cf.get_value("prefs", "mouse_move", false))
	sfx_enabled = bool(cf.get_value("prefs", "sfx_enabled", true))


func save_progress() -> void:
	var cf := ConfigFile.new()
	cf.load(CFG_PATH)
	cf.set_value("progress", "last_level", last_level_index)
	cf.set_value("progress", "best_completed", best_completed_index)
	cf.save(CFG_PATH)


func save_prefs() -> void:
	var cf := ConfigFile.new()
	cf.load(CFG_PATH)
	cf.set_value("prefs", "dialogue_font_size", dialogue_font_size)
	cf.set_value("prefs", "mouse_move", mouse_move_enabled)
	cf.set_value("prefs", "sfx_enabled", sfx_enabled)
	cf.save(CFG_PATH)


func should_show_boot_menu() -> bool:
	return FileAccess.file_exists(CFG_PATH) and last_level_index > 0


func on_level_started(index: int) -> void:
	last_level_index = index
	save_progress()


func on_level_completed(index: int) -> void:
	best_completed_index = maxi(best_completed_index, index)
	last_level_index = index + 1
	save_progress()


func reset_progress() -> void:
	last_level_index = 0
	best_completed_index = -1
	save_progress()


func set_dialogue_font_size(v: int) -> void:
	dialogue_font_size = clampi(v, 14, 28)
	save_prefs()
	dialogue_font_size_changed.emit(dialogue_font_size)


func set_mouse_move_enabled(v: bool) -> void:
	mouse_move_enabled = v
	save_prefs()
	mouse_move_changed.emit(mouse_move_enabled)


func set_sfx_enabled(v: bool) -> void:
	sfx_enabled = v
	save_prefs()
	sfx_changed.emit(sfx_enabled)
