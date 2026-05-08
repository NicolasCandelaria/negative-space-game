extends Camera2D

var _shake_time: float = 0.0
var _shake_mag: float = 0.0


func _ready() -> void:
	add_to_group("shake_camera")


func _process(delta: float) -> void:
	if _shake_time <= 0.0:
		offset = Vector2.ZERO
		return
	_shake_time -= delta
	offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_mag


func shake(strength: float, duration: float) -> void:
	_shake_mag = strength
	_shake_time = maxf(_shake_time, duration)
