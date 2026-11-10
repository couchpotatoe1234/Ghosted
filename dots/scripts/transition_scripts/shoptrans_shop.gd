extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $Sprite2D/Label

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		anim.play("idle")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		anim.play("hidden")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("up") and anim.current_animation == "idle" and GameManager.controls_allowed:
		var main_node = get_tree().root.get_node("Main")
		if main_node and main_node.has_method("change_level"):
			main_node.change_level("res://scenes/rooms/Shop.tscn", Vector2(9, 30), Vector2(-50, 0))
