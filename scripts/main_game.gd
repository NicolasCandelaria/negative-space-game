extends Node

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

const LEVEL_SCENES = [
	"res://scenes/level_01_storage.tscn",
	"res://scenes/level_02_garage.tscn",
	"res://scenes/level_03_apartment.tscn",
	"res://scenes/level_04_hospital.tscn",
	"res://scenes/level_05_lighthouse.tscn",
	"res://scenes/level_06_subway.tscn",
	"res://scenes/level_07_power_station.tscn",
	"res://scenes/level_08_house.tscn",
]

const LEVEL_NAMES: PackedStringArray = [
	"Storage",
	"Garage",
	"Apartment",
	"Hospital corridor",
	"Lighthouse",
	"Subway",
	"Power station",
	"House",
]

signal level_loaded(index: int, display_name: String)

@onready var _slot: Node = $LevelRoot

var _level_index: int = -1
var _restart_running: bool = false

var current_level_index: int:
	get:
		return _level_index


func _ready() -> void:
	add_to_group("game_main")
	GameSettings.load_all()


func start_at_level(idx: int) -> void:
	_spawn_index(idx)


func restart_current_level() -> void:
	if _level_index < 0 or _level_index >= LEVEL_SCENES.size():
		return
	if _restart_running:
		return
	_restart_running = true
	await _spawn_index(_level_index)
	_restart_running = false


func _spawn_index(i: int) -> void:
	for c in _slot.get_children():
		c.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	if i >= LEVEL_SCENES.size():
		_level_index = LEVEL_SCENES.size()
		_spawn_end_card()
		return
	_level_index = i
	var packed: PackedScene = load(LEVEL_SCENES[i])
	var inst: Node = packed.instantiate()
	_slot.add_child(inst)
	GameSettings.on_level_started(i)
	level_loaded.emit(i, LEVEL_NAMES[i])
	if inst.has_signal("completed"):
		inst.completed.connect(_on_level_completed.bind(i))


func _on_level_completed(finished_index: int) -> void:
	GameSettings.on_level_completed(finished_index)
	GameAudio.play_exit()
	_spawn_index(finished_index + 1)


func _spawn_end_card() -> void:
	DialogueUi.say(get_tree(), "Negative Space - proof of concept complete.\nThanks for playing.")
