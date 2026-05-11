extends CharacterBody2D

const Autoload := preload("res://scripts/autoload_access.gd")

signal died

const SPEED := 220.0
const SPAWN_INVULN_SECONDS := 1.05

## When true, movement input is ignored (e.g. level complete).
var input_frozen: bool = false

## Runtime movement scale for level mechanics (e.g. soft-light slowdown).
var speed_scale: float = 1.0

var invulnerable_seconds: float = 0.0


func _ready() -> void:
	invulnerable_seconds = SPAWN_INVULN_SECONDS


func _physics_process(delta: float) -> void:
	if invulnerable_seconds > 0.0:
		invulnerable_seconds -= delta
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

	if _mouse_move_enabled() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var to_mouse := get_global_mouse_position() - global_position
		if to_mouse.length_squared() > 25.0:
			dir = to_mouse.normalized()

	if dir.length_squared() > 0.0:
		dir = dir.normalized()

	velocity = dir * SPEED * speed_scale
	move_and_slide()


func is_invulnerable() -> bool:
	return invulnerable_seconds > 0.0


func die() -> void:
	if is_invulnerable():
		return
	var ga := Autoload.audio(get_tree())
	if ga and ga.has_method("play_death"):
		ga.call("play_death")
	died.emit()


func _mouse_move_enabled() -> bool:
	var gs := Autoload.settings(get_tree())
	return gs != null and bool(gs.get("mouse_move_enabled"))
