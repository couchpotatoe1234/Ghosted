extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var main_node = get_tree().root.get_node("Main")
		if main_node and main_node.has_method("change_level"):
			print("mtr1-3")
			main_node.change_level("res://scenes/rooms/Room3.tscn", Vector2(-1400, -930), Vector2(0, 200))
