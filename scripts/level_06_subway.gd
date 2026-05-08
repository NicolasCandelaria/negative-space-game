extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 6: Subway platform.
## Continuous dim light slows movement, while train arrivals flood open areas with lethal light.

signal completed

const AMBIENT_SPEED_SCALE := 0.78
const TRAIN_INTERVAL_SECONDS := 5.8
const FLOOD_DURATION_SECONDS := 1.55
const MAX_TRAINS := 3

@onready var _player: CharacterBody2D = $Player
@onready var _exit_zone: Area2D = $ExitZone
@onready var _train_timer: Timer = $TrainTimer
@onready var _flood_timer: Timer = $FloodTimer
@onready var _train_banner: Label = $TrainBanner
@onready var _train_ascii: Label = $TrainAscii
@onready var _flood_hazards = [$FloodA, $FloodB, $FloodC]
@onready var _pause_area: Area2D = $SleepPause

var _won: bool = false
var _flood_on: bool = false
var _trains_passed: int = 0
var _sleep_seen: bool = false


func _ready() -> void:
	_player.died.connect(_on_player_died)
	_pause_area.body_entered.connect(_on_sleep_pause_entered)
	_train_timer.timeout.connect(_on_train_arrives)
	_flood_timer.timeout.connect(_on_flood_ends)
	for hz in _flood_hazards:
		hz.body_entered.connect(_on_flood_body_entered)
		hz.monitoring = false

	_player.speed_scale = AMBIENT_SPEED_SCALE
	_train_banner.visible = false
	_train_ascii.visible = false
	_train_timer.wait_time = TRAIN_INTERVAL_SECONDS
	_train_timer.start()

	DialogueUi.say(
		get_tree(),
		(
			"Negative Space - Subway platform.\n"
			+ "Ambient emergency light slows you constantly.\n"
			+ "Train arrivals flood open platform sections with lethal light. Reach the tunnel before 3 trains pass."
		)
	)


func _physics_process(_delta: float) -> void:
	if _won:
		return

	if _player in _exit_zone.get_overlapping_bodies():
		_complete_level()
		return

	if _flood_on:
		for hz in _flood_hazards:
			if _player in hz.get_overlapping_bodies():
				_player.die()
				return


func _on_train_arrives() -> void:
	if _won:
		return
	_flood_on = true
	_train_ascii.visible = true
	_train_banner.visible = true
	_train_banner.text = "<<< TRAIN ARRIVING: LIGHT FLOOD >>>"
	for hz in _flood_hazards:
		hz.monitoring = true
	_flood_timer.wait_time = FLOOD_DURATION_SECONDS
	_flood_timer.start()


func _on_flood_ends() -> void:
	if _won:
		return
	_flood_on = false
	_train_ascii.visible = false
	for hz in _flood_hazards:
		hz.monitoring = false

	_trains_passed += 1
	if _trains_passed >= MAX_TRAINS:
		_train_banner.text = "Too late. Three trains passed."
		_player.die()
		return

	_train_banner.text = "Train passed: %d/%d  --  Keep moving." % [_trains_passed, MAX_TRAINS]
	_train_timer.start()


func _on_flood_body_entered(body: Node2D) -> void:
	if _won or not _flood_on:
		return
	if body == _player:
		_player.die()


func _on_sleep_pause_entered(body: Node2D) -> void:
	if _won or _sleep_seen or body != _player:
		return
	_sleep_seen = true
	DialogueUi.say(get_tree(), "Someone sleeps under a bench. Even now, they do not stir.")


func _on_player_died() -> void:
	if _won:
		return
	_player.speed_scale = 1.0
	await get_tree().create_timer(0.25).timeout
	var gm := get_tree().get_first_node_in_group("game_main")
	if gm and gm.has_method("restart_current_level"):
		gm.restart_current_level()
	else:
		get_tree().reload_current_scene()


func _complete_level() -> void:
	if _won:
		return
	_won = true
	_player.input_frozen = true
	_player.speed_scale = 1.0
	_train_timer.stop()
	_flood_timer.stop()
	for hz in _flood_hazards:
		hz.monitoring = false
	_train_banner.text = "Tunnel reached."
	DialogueUi.say(get_tree(), "Safety. They have a word for the absence of dark.")
	await get_tree().create_timer(1.8).timeout
	completed.emit()
