extends Node2D

signal fight_start
signal fight_end
@export var camera_limits: Rect2 = Rect2(-1664, -32, 1728, 288)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		fight_start.emit()
