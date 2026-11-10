extends StaticBody2D

const COIN_PARTICLE_SCENE = preload("res://scenes/CoinParticles.tscn")
@export var coin_reward: int = 10
@onready var anim: AnimationPlayer = $Anims


func _ready() -> void:
	var level_path = owner.scene_file_path
	if GameManager.coin_cache_1 == true and level_path ==  "res://scenes/rooms/Room1.tscn":
		anim.play("opened")
	elif GameManager.coin_cache_2 == true and level_path == "res://scenes/rooms/caveRM1.tscn":
		anim.play("opened")
	else:
		anim.play("unopened")

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack") or area.is_in_group("player_attack_down") or area.is_in_group("player_attack_up"):
		$Open.play()
		var level_path = owner.scene_file_path
		if GameManager.coin_cache_1 == false and level_path == "res://scenes/rooms/Room1.tscn":
			anim.play("open")
			GameManager.coin_cache_1 = true
			call_deferred("spawn_coins", coin_reward)
		elif GameManager.coin_cache_2 == false and level_path == "res://scenes/rooms/caveRM1.tscn":
			anim.play("open")
			GameManager.coin_cache_2 = true
			call_deferred("spawn_coins", coin_reward)

func spawn_coins(amount: float) -> void:
	var level: Node2D = owner
	var coin_spawn_pos: Vector2 = global_position
	for i in range(amount):
				var coin = COIN_PARTICLE_SCENE.instantiate()
				level.add_child(coin)
				coin.set_spawn_position(coin_spawn_pos, Vector2(randf_range(-150, 150), randf_range(-200, -300)))
