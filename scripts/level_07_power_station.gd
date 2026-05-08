extends Node2D

const DialogueUi := preload("res://scripts/dialogue_helper.gd")

## Level 7: Power station.
## Player activates temporary shadow bridges to cross a lit yard.

signal completed

const BRIDGE_ACTIVE_SECONDS := 2.4
const GUARD_SPEED := 60.0

@onready var _player: CharacterBody2D = $Player
@onready var _exit_zone: Area2D = $ExitZone
@onready var _flood_hazard: Area2D = $OpenYardHazard
@onready var _guard: Node2D = $Guard
@onready var _guard_touch: Area2D = $Guard/Touch

@onready var _switch_areas = [$SwitchA, $SwitchB, $SwitchC]
@onready var _bridge_bodies = [$BridgeA, $BridgeB, $BridgeC]
@onready var _bridge_labels = [$BridgeA/Ascii, $BridgeB/Ascii, $BridgeC/Ascii]
@onready var _bridge_timers = [$TimerA, $TimerB, $TimerC]

var _won: bool = false
var _guard_dir: float = 1.0


func _ready() -> void:
	_player.died.connect(_on_player_died)
	_guard_touch.body_entered.connect(_on_guard_touch_entered)
	_flood_hazard.body_entered.connect(_on_flood_body_entered)

	for i in range(_switch_areas.size()):
		_switch_areas[i].body_entered.connect(_on_switch_entered.bind(i))
		_bridge_timers[i].timeout.connect(_on_bridge_timeout.bind(i))
		_set_bridge_state(i, false)

	DialogueUi.say(
		get_tree(),
		(
			"Negative Space - Power station.\n"
			+ "The yard is flooded with lethal light.\n"
			+ "Touch [PULL] switches to create temporary shadow bridges and chain your crossing."
		)
	)


func _process(delta: float) -> void:
	if _won:
		return

	_guard.position.x += _guard_dir * GUARD_SPEED * delta
	if _guard.position.x > 210.0:
		_guard.position.x = 210.0
		_guard_dir = -1.0
	elif _guard.position.x < -210.0:
		_guard.position.x = -210.0
		_guard_dir = 1.0


func _physics_process(_delta: float) -> void:
	if _won:
		return

	if _player in _exit_zone.get_overlapping_bodies():
		_complete_level()
		return

	# Open yard is lethal unless standing on any active bridge platform.
	if _player in _flood_hazard.get_overlapping_bodies() and not _is_on_active_bridge():
		_player.die()


func _on_switch_entered(body: Node2D, index: int) -> void:
	if _won or body != _player:
		return
	_set_bridge_state(index, true)
	_bridge_timers[index].wait_time = BRIDGE_ACTIVE_SECONDS
	_bridge_timers[index].start()


func _on_bridge_timeout(index: int) -> void:
	_set_bridge_state(index, false)


func _set_bridge_state(index: int, active: bool) -> void:
	# Bridges are passable shadow, not walls; the hazard check treats visible bridges as safe ground.
	_bridge_bodies[index].collision_layer = 0
	_bridge_bodies[index].collision_mask = 0
	_bridge_labels[index].visible = active


func _is_on_active_bridge() -> bool:
	for i in range(_bridge_bodies.size()):
		if _bridge_labels[i].visible:
			var body := _bridge_bodies[i]
			if body is StaticBody2D:
				for child in body.get_children():
					if child is CollisionShape2D:
						var shape := child.shape
						if shape is RectangleShape2D:
							var ext := shape.size * 0.5
							var local := _player.global_position - body.global_position
							if absf(local.x) <= ext.x and absf(local.y) <= ext.y:
								return true
	return false


func _on_guard_touch_entered(body: Node2D) -> void:
	if _won:
		return
	if body == _player:
		_player.die()


func _on_flood_body_entered(body: Node2D) -> void:
	if _won:
		return
	if body == _player and not _is_on_active_bridge():
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
	DialogueUi.say(get_tree(), "This is where they think the light comes from. They are wrong.")
	await get_tree().create_timer(1.8).timeout
	completed.emit()
