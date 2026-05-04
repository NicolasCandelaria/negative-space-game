extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 2: guard patrols a closed rectangle; flashlight cone kills on contact.
## Patrol uses Curve2D in code only (no Path2D) so no path line is drawn.

signal completed

const GUARD_SPEED: float = 88.0

@onready var _rig: Node2D = $PatrolRig
@onready var _cone: Area2D = $PatrolRig/ConeKill
@onready var _win: Area2D = $WinZone
@onready var _player: CharacterBody2D = $Player

var _won: bool = false
var _patrol: Curve2D
var _path_length: float = 0.0
var _prog: float = 0.0


func _ready() -> void:
	_build_patrol()
	_path_length = maxf(1.0, _patrol.get_baked_length())
	_prog = _path_length * 0.12
	_player.died.connect(_on_player_died)
	_cone.body_entered.connect(_on_cone_body_entered)
	_update_rig_transform()
	DialogueUi.say(
		get_tree(),
		(
			"Negative Space — Parking garage.\n"
			+ "Stay out of the guard's flashlight cone — it is lethal.\n"
			+ "Reach the cyan exit strip along the north wall."
		)
	)


func _build_patrol() -> void:
	_patrol = Curve2D.new()
	_patrol.add_point(Vector2(-340, 130))
	_patrol.add_point(Vector2(300, 130))
	_patrol.add_point(Vector2(300, -110))
	_patrol.add_point(Vector2(-340, -110))
	_patrol.add_point(Vector2(-340, 130))


func _update_rig_transform() -> void:
	var t := fmod(_prog, _path_length)
	var p0 := _patrol.sample_baked(t)
	var ahead := fmod(t + maxf(6.0, _path_length * 0.03), _path_length)
	var p1 := _patrol.sample_baked(ahead)
	var diff := p1 - p0
	if diff.length_squared() < 0.0001:
		diff = Vector2.RIGHT.rotated(_rig.rotation)
	_rig.position = p0
	_rig.rotation = diff.angle()


func _process(delta: float) -> void:
	if _won:
		return
	_prog += GUARD_SPEED * delta
	_update_rig_transform()


func _physics_process(_delta: float) -> void:
	if _won:
		return
	if _player in _win.get_overlapping_bodies():
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


func _on_cone_body_entered(body: Node2D) -> void:
	if _won:
		return
	if body == _player:
		_player.die()


func _complete_level() -> void:
	if _won:
		return
	_won = true
	_player.input_frozen = true
	DialogueUi.say(get_tree(), "He guards the light. The light does not guard him.")
	await get_tree().create_timer(1.6).timeout
	completed.emit()
