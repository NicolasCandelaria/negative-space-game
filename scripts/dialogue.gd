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
	_layer.add_child(_box)


func say(text: String) -> void:
	if _box and _box.has_method("show_message"):
		_box.show_message(text)


func hide() -> void:
	if _box and _box.has_method("hide_box"):
		_box.hide_box()
