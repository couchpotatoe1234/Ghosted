extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var main_node = get_tree().root.get_node("Main")
		if main_node and main_node.has_method("change_level"):
			print("3-mrt1")
			main_node.change_level("res://scenes/rooms/mtr1.tscn", Vector2(-2096, 271), Vector2(100, -300))
