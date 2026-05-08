extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 5: Lighthouse cliff.
## A rotating beam sweeps the path; beam contact is lethal.

signal completed

const BEAM_ROTATION_SPEED := 0.95

@onready var _player: CharacterBody2D = $Player
@onready var _beam_hazard: Area2D = $Lighthouse/BeamHazard
@onready var _beam_visual: Label = $Lighthouse/BeamAscii
@onready var _win_zone: Area2D = $DoorZone

var _won: bool = false
var _beam_angle: float = -PI * 0.25


func _ready() -> void:
	_player.died.connect(_on_player_died)
	_beam_hazard.body_entered.connect(_on_beam_body_entered)
	DialogueUi.say(
		get_tree(),
		(
			"Negative Space - Lighthouse.\n"
			+ "The beam sweeps in long arcs. It is lethal in the lit sector.\n"
			+ "Climb the path and reach the door while the beam looks away."
		)
	)


func _process(delta: float) -> void:
	if _won:
		return

	_beam_angle += BEAM_ROTATION_SPEED * delta
	if _beam_angle > PI * 2.0:
		_beam_angle -= PI * 2.0

	$Lighthouse/BeamHazard.rotation = _beam_angle
	$Lighthouse/BeamAscii.rotation = _beam_angle


func _physics_process(_delta: float) -> void:
	if _won:
		return

	if _player in _win_zone.get_overlapping_bodies():
		_complete_level()
		return

	if _player in _beam_hazard.get_overlapping_bodies():
		_player.die()


func _on_beam_body_entered(body: Node2D) -> void:
	if _won:
		return
	if body == _player:
		_player.die()


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
	DialogueUi.say(get_tree(), "I have been here before. Different stone. Same purpose.")
	await get_tree().create_timer(1.8).timeout
	completed.emit()