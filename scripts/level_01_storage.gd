extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 1: flickering overhead pool — lethal while ON. Exit only counts in darkness.

signal completed

@export var flicker_on_seconds: float = 1.4
@export var flicker_off_seconds: float = 1.1

@onready var _kill_area: Area2D = $KillZone
@onready var _point_light: PointLight2D = $KillZone/PointLight2D
@onready var _player: CharacterBody2D = $Player
@onready var _flicker_timer: Timer = $FlickerTimer
@onready var _exit: Area2D = $Exit

var _won: bool = false


func _ready() -> void:
	_player.died.connect(_on_player_died)
	_flicker_timer.timeout.connect(_on_flicker_tick)
	_kill_area.body_entered.connect(_on_kill_body_entered)
	_exit.body_entered.connect(_on_exit_body_entered)
	_set_light_on(true)
	_schedule_next_flicker()
	DialogueUi.say(
		get_tree(),
		(
			"Negative Space — Storage room.\n"
			+ "Move with WASD or the arrow keys. The overhead light flickers — it is lethal while it is ON.\n"
			+ "Reach the green exit while the light is OFF. Standing inside the exit counts."
		)
	)


func _physics_process(_delta: float) -> void:
	if _won:
		return
	if _point_light.enabled:
		return
	var bodies := _exit.get_overlapping_bodies()
	if _player in bodies:
		_complete_level()


func _on_player_died() -> void:
	if _won:
		return
	await get_tree().create_timer(0.25).timeout
	var gm := get_tree().get_first_node_in_group("game_main")
	if gm and gm.has_method("restart_current_level"):
		gm.restart_current_level()
	else:
		get_tree().reload_current_scene()


func _on_exit_body_entered(body: Node2D) -> void:
	if body != _player or _won:
		return
	if _point_light.enabled:
		DialogueUi.say(get_tree(), "Wait for darkness — then reach the exit.")
		return
	_complete_level()


func _complete_level() -> void:
	if _won:
		return
	_won = true
	_player.input_frozen = true
	DialogueUi.say(
		get_tree(),
		"Another room. Another century. The light here is cheap and tired. It will not last the night."
	)
	_flicker_timer.stop()
	_set_light_on(false)
	await get_tree().create_timer(1.8).timeout
	completed.emit()


func _on_flicker_tick() -> void:
	if _won:
		return
	var next_on := not _point_light.enabled
	_set_light_on(next_on)
	_schedule_next_flicker()


func _set_light_on(on: bool) -> void:
	if _won:
		_point_light.enabled = false
		_kill_area.monitoring = false
		return
	_point_light.enabled = on
	_kill_area.monitoring = on
	if on:
		for body in _kill_area.get_overlapping_bodies():
			if body == _player:
				_player.die()
				return


func _schedule_next_flicker() -> void:
	if _won:
		return
	_flicker_timer.stop()
	_flicker_timer.wait_time = flicker_on_seconds if _point_light.enabled else flicker_off_seconds
	_flicker_timer.start()


func _on_kill_body_entered(body: Node2D) -> void:
	if _won:
		return
	if body == _player and _point_light.enabled:
		_player.die()
