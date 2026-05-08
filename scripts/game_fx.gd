extends Node


func screen_shake(strength: float = 6.0, duration: float = 0.11) -> void:
	for n in get_tree().get_nodes_in_group("shake_camera"):
		if n.has_method("shake"):
			n.shake(strength, duration)
