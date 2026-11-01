extends StaticBody2D

@onready var anim: AnimationPlayer = $Anims

func _ready() -> void:
	if GameManager.coin_cache_1 == true:
		anim.play("opened")
	else:
		anim.play("unopened")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack") or area.is_in_group("player_attack_down") or area.is_in_group("player_attack_up"):
		if GameManager.coin_cache_1 == false:
			anim.play("open")
			GameManager.coin_cache_1 = true
		else:
			print(GameManager.coin_cache_1)
