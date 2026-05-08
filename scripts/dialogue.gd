extends Node

const BOX_SCENE := preload("res://scenes/ui/dialogue_box.tscn")

var _layer: CanvasLayer
var _box: Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_layer = CanvasLayer.new()
	_layer.layer = 80
	add_child(_layer)
	_box = BOX_SCENE.instantiate()
	_box.process_mode = Node.PROCESS_MODE_ALWAYS
	_layer.add_child(_box)


func say(text: String) -> void:
	if _box and _box.has_method("show_message"):
		_box.show_message(text)


func say_async(text: String) -> void:
	say(text)
	if _box and _box.has_signal("dialogue_dismissed"):
		await _box.dialogue_dismissed


func hide() -> void:
	if _box and _box.has_method("hide_box"):
		_box.hide_box()
