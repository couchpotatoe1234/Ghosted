extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlyer

func _ready() -> void:
	if GameManager.coin_cache_1 == true:
		anim.play("opened")
		
