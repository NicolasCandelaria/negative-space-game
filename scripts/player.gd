extends CharacterBody2D

signal died

const SPEED := 220.0

## When true, movement input is ignored (e.g. level complete).
var input_frozen: bool = false


func _physics_process(delta: float) -> void:
	if input_frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		dir.y += 1.0
	dir = dir.normalized()
	velocity = dir * SPEED
	move_and_slide()


func die() -> void:
	died.emit()
