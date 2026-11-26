extends Node2D

signal fight_start
signal fight_end
var fighting: bool = false
@export var camera_limits: Rect2 = Rect2(-1664, -32, 1728, 288)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and not fighting:
		var main_node = get_tree().root.get_node("Main")
		await main_node.player_move_start(Vector2(-912, 191))
		main_node.change_camera(Rect2(-1312, -128, 800, 480), 1.44)
		await main_node.player_move_end()
		fight_start.emit()
		fighting = true
