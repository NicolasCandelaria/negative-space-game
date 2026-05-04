extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 3: Apartment. Soft light does not kill; it slows movement.
## Objective: witness 3 life moments, then settle in the dark corner.

signal completed

const NORMAL_SPEED_SCALE := 1.0
const SOFT_LIGHT_SPEED_SCALE := 0.52

@onready var _player: CharacterBody2D = $Player
@onready var _soft_zones := [$LaptopGlow, $LampGlow]
@onready var _photo_point: Area2D = $PhotoPoint
@onready var _water_point: Area2D = $WaterPoint
@onready var _desk_point: Area2D = $DeskPoint
@onready var _return_corner: Area2D = $ReturnCorner

var _slow_contacts: int = 0
var _won: bool = false
var _seen := {
	"photo": false,
	"water": false,
	"desk": false,
}


func _ready() -> void:
	for zone in _soft_zones:
		zone.body_entered.connect(_on_soft_zone_entered)
		zone.body_exited.connect(_on_soft_zone_exited)
	_photo_point.body_entered.connect(_on_photo_point_entered)
	_water_point.body_entered.connect(_on_water_point_entered)
	_desk_point.body_entered.connect(_on_desk_point_entered)
	DialogueUi.say(
		get_tree(),
		(
			"Negative Space - Apartment.\n"
			+ "Soft light will not kill you, but it slows your movement.\n"
			+ "Observe the room: photos, sink, desk. Then return to the dark corner."
		)
	)


func _physics_process(_delta: float) -> void:
	if _won:
		return
	if _all_memories_seen() and _player in _return_corner.get_overlapping_bodies():
		_complete_level()


func _on_soft_zone_entered(body: Node2D) -> void:
	if body != _player:
		return
	_slow_contacts += 1
	_player.speed_scale = SOFT_LIGHT_SPEED_SCALE


func _on_soft_zone_exited(body: Node2D) -> void:
	if body != _player:
		return
	_slow_contacts = maxi(0, _slow_contacts - 1)
	if _slow_contacts == 0:
		_player.speed_scale = NORMAL_SPEED_SCALE


func _on_photo_point_entered(body: Node2D) -> void:
	if body != _player or _seen["photo"]:
		return
	_seen["photo"] = true
	DialogueUi.say(get_tree(), "A woman, a child, a life under warm light. Memory noted.")


func _on_water_point_entered(body: Node2D) -> void:
	if body != _player or _seen["water"]:
		return
	_seen["water"] = true
	DialogueUi.say(get_tree(), "A glass by the sink. Small rituals hold a room together.")


func _on_desk_point_entered(body: Node2D) -> void:
	if body != _player or _seen["desk"]:
		return
	_seen["desk"] = true
	DialogueUi.say(get_tree(), "A half-finished thought glows on the desk. She is still awake.")


func _all_memories_seen() -> bool:
	return _seen["photo"] and _seen["water"] and _seen["desk"]


func _complete_level() -> void:
	if _won:
		return
	_won = true
	_player.input_frozen = true
	_player.speed_scale = NORMAL_SPEED_SCALE
	DialogueUi.say(get_tree(), "She thinks she is alone. She has never been alone.")
	await get_tree().create_timer(1.8).timeout
	completed.emit()