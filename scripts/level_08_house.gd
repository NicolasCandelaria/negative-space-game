extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 8: The House.
## Final quiet level. Explore marked memories, then face the man and end the light.

signal completed

@onready var _player: CharacterBody2D = $Player
@onready var _photo_a: Area2D = $PhotoA
@onready var _photo_b: Area2D = $PhotoB
@onready var _book_point: Area2D = $BookPoint
@onready var _man_zone: Area2D = $ManZone
@onready var _lamp_glow: Label = $LampGlow
@onready var _lamp_hazard: Area2D = $LampHazard
@onready var _ending_text: Label = $EndingText

var _won: bool = false
var _seen := {
	"photo_a": false,
	"photo_b": false,
	"book": false,
}
var _dialogue_index: int = 0


func _ready() -> void:
	_photo_a.body_entered.connect(_on_photo_a_entered)
	_photo_b.body_entered.connect(_on_photo_b_entered)
	_book_point.body_entered.connect(_on_book_entered)
	_man_zone.body_entered.connect(_on_man_zone_entered)
	_lamp_hazard.body_entered.connect(_on_lamp_hazard_entered)
	_ending_text.visible = false
	_lamp_hazard.monitoring = false

	DialogueUi.say(
		get_tree(),
		(
			"Negative Space - The House.\n"
			+ "No chase. No puzzle rush.\n"
			+ "Move through the rooms, observe what remains, then stand before the man in the dark corner."
		)
	)


func _on_photo_a_entered(body: Node2D) -> void:
	if _won or body != _player or _seen["photo_a"]:
		return
	_seen["photo_a"] = true
	DialogueUi.say(get_tree(), "A younger face in a wooden frame. Time keeps its own receipts.")


func _on_photo_b_entered(body: Node2D) -> void:
	if _won or body != _player or _seen["photo_b"]:
		return
	_seen["photo_b"] = true
	DialogueUi.say(get_tree(), "A child, grown now. A life moved onward under warm electric light.")


func _on_book_entered(body: Node2D) -> void:
	if _won or body != _player or _seen["book"]:
		return
	_seen["book"] = true
	DialogueUi.say(get_tree(), "He reads slowly. He is not waiting for a page to end.")


func _on_man_zone_entered(body: Node2D) -> void:
	if _won or body != _player:
		return
	if not _all_memories_seen():
		DialogueUi.say(get_tree(), "Not yet. Walk the rooms first.")
		return
	_play_final_dialogue()


func _play_final_dialogue() -> void:
	if _dialogue_index > 0:
		return
	_dialogue_index = 1
	_player.input_frozen = true
	var lines := [
		"Man: You've been here before. Haven't you.",
		"Shadow: Yes.",
		"Man: How long.",
		"Shadow: Longer than this house. Longer than the word for house.",
		"Man: And if I turn it off.",
		"Shadow: You know what happens.",
		"Man: ...Okay.",
	]
	for line in lines:
		DialogueUi.say(get_tree(), line)
		await get_tree().create_timer(1.35).timeout
	_start_lamp_off_sequence()


func _start_lamp_off_sequence() -> void:
	_lamp_glow.visible = false
	_lamp_hazard.monitoring = false
	await get_tree().create_timer(1.2).timeout
	_ending_text.visible = true
	DialogueUi.say(get_tree(), "The dark is older than this. It will be older than what comes next.")
	await get_tree().create_timer(2.0).timeout
	_complete_level()


func _on_lamp_hazard_entered(body: Node2D) -> void:
	# Non-lethal in final chapter; kept only as a scene affordance hook.
	if _won or body != _player:
		return


func _all_memories_seen() -> bool:
	return _seen["photo_a"] and _seen["photo_b"] and _seen["book"]


func _complete_level() -> void:
	if _won:
		return
	_won = true
	completed.emit()
