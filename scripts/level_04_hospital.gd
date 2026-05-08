extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 4: Hospital corridor.
## Crossing sensor zones triggers local bright light (temporarily lethal).

signal completed

const SEGMENT_ACTIVE_SECONDS := 1.4
const JANITOR_SPEED := 34.0

@onready var _player: CharacterBody2D = $Player
@onready var _exit_zone: Area2D = $ExitZone
@onready var _patient_pause: Area2D = $PatientPause
@onready var _janitor: Node2D = $Janitor
@onready var _janitor_touch: Area2D = $Janitor/Touch

@onready var _sensor_zones = [$SensorA, $SensorB, $SensorC]
@onready var _hazard_zones = [$HazardA, $HazardB, $HazardC]
@onready var _timers = [$TimerA, $TimerB, $TimerC]
@onready var _ascii_lights = [$LightA, $LightB, $LightC]

var _won: bool = false
var _patient_seen: bool = false


func _ready() -> void:
	_player.died.connect(_on_player_died)
	_janitor_touch.body_entered.connect(_on_janitor_touch_entered)
	_patient_pause.body_entered.connect(_on_patient_pause_entered)

	for i in range(_sensor_zones.size()):
		_sensor_zones[i].body_entered.connect(_on_sensor_entered.bind(i))
		_hazard_zones[i].body_entered.connect(_on_hazard_entered.bind(i))
		_timers[i].timeout.connect(_on_segment_timeout.bind(i))
		_set_segment_active(i, false)

	DialogueUi.say(
		get_tree(),
		(
			"Negative Space - Hospital corridor.\n"
			+ "Motion sensors trigger bright light in each section. Triggered sections are lethal for a moment.\n"
			+ "Stay ahead of the janitor and reach the EXIT at the north end."
		)
	)


func _process(delta: float) -> void:
	if _won:
		return

	_janitor.position.y -= JANITOR_SPEED * delta
	if _janitor.position.y < -286.0:
		_janitor.position.y = 300.0


func _physics_process(_delta: float) -> void:
	if _won:
		return

	if _player in _exit_zone.get_overlapping_bodies():
		_complete_level()
		return

	for i in range(_hazard_zones.size()):
		if _hazard_zones[i].monitoring and _player in _hazard_zones[i].get_overlapping_bodies():
			_player.die()
			return


func _on_sensor_entered(body: Node2D, index: int) -> void:
	if _won or body != _player:
		return
	_set_segment_active(index, true)
	_timers[index].wait_time = SEGMENT_ACTIVE_SECONDS
	_timers[index].start()


func _on_hazard_entered(body: Node2D, index: int) -> void:
	if _won:
		return
	if body == _player and _hazard_zones[index].monitoring:
		_player.die()


func _on_segment_timeout(index: int) -> void:
	_set_segment_active(index, false)


func _set_segment_active(index: int, active: bool) -> void:
	_hazard_zones[index].monitoring = active
	_ascii_lights[index].visible = active


func _on_janitor_touch_entered(body: Node2D) -> void:
	if _won:
		return
	if body == _player:
		_player.die()


func _on_patient_pause_entered(body: Node2D) -> void:
	if _won or _patient_seen or body != _player:
		return
	_patient_seen = true
	DialogueUi.say(get_tree(), "A monitor beeps softly in a side room. You pause. Nothing else moves.")


func _on_player_died() -> void:
	if _won:
		return
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
	for i in range(_hazard_zones.size()):
		_set_segment_active(i, false)
	DialogueUi.say(get_tree(), "They build their endings under bright lights. They are afraid of what comes for everyone.")
	await get_tree().create_timer(1.8).timeout
	completed.emit()