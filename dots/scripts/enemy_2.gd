extends CharacterBody2D

const COIN_PARTICLE_SCENE = preload("res://scenes/CoinParticles.tscn")

enum Anim { IDLE, AGGRO, ATTACK, HIT, HURT, DIE }
var current_anim: Anim = Anim.IDLE 
var health: int = 2
var hover_speed: float = 60.0
var attack_speed: float = 140.0
var aggro_range: float = 160.0
var attack_range: float = 160.0
var target_player: Node2D = null
var is_recovering: bool = false
var knocked_back: bool = false
var attack_target_pos: Vector2 = Vector2.ZERO
var hover_offset: Vector2 = Vector2.ZERO
var attack_timer: float = 0.0
var lose_sight_timer: float = 0.0
var coin_reward: int = 5
var is_dead: bool = false
@onready var movement_audio: AudioStreamPlayer2D = $MovingAudio
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D
@onready var hit_particles: GPUParticles2D = $HurtParticlesFX/GPUParticles2D

func _ready() -> void:
	change_anim(Anim.IDLE)
	movement_audio.play()
	movement_audio.pitch_scale = 1.0

func _physics_process(delta: float) -> void:
	if current_anim == Anim.DIE:
		movement_audio.stop()
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			velocity.x = move_toward(velocity.x, 0, 300 * delta)
			velocity.y = 0
		move_and_slide()
		return
	find_player()
	if not knocked_back:
		match current_anim:
			Anim.IDLE:
				velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
				if can_see_player():
					start_attack_cooldown()
					pick_new_hover_offset()
					change_anim(Anim.AGGRO)
			
			Anim.AGGRO:
				if can_see_player():
					lose_sight_timer = 0.0
					if target_player and global_position.distance_to(target_player.global_position) <= aggro_range:
						lose_sight_timer = 0.0
				else:
					lose_sight_timer += delta
					if lose_sight_timer >= 3.0:
						change_anim(Anim.IDLE)
						movement_audio.pitch_scale = 1.0
						return
				var x_diff = target_player.global_position.x - global_position.x
				if abs(x_diff) > 12.0:
					sprite.flip_h = x_diff < 0
				var hover_target = target_player.global_position + hover_offset
				var dir = (hover_target - global_position).normalized()
				velocity = velocity.move_toward(dir * hover_speed, 300 * delta)
				movement_audio.pitch_scale = 1.1
				if global_position.distance_to(target_player.global_position) <= attack_range and not is_recovering:
					change_anim(Anim.ATTACK)
			Anim.ATTACK:
				attack_timer += delta
				var dir = (attack_target_pos - global_position).normalized()
				velocity = dir * attack_speed
				movement_audio.pitch_scale = 1.3
				if is_on_wall() or is_on_floor() or global_position.distance_to(attack_target_pos) < 15.0 or attack_timer >= 1.5:
					start_attack_cooldown()
					pick_new_hover_offset()
					change_anim(Anim.AGGRO)
	move_and_slide()

func change_anim(new_anim: Anim) -> void:
	current_anim = new_anim
	match current_anim:
		Anim.IDLE:
			sprite.play("idle")
		Anim.AGGRO:
			sprite.play("aggro")
		Anim.ATTACK:
			sprite.play("attack")
			attack_timer = 0.0
			if target_player:
				attack_target_pos = target_player.global_position
				sprite.flip_h = attack_target_pos.x < global_position.x
		Anim.HIT:
			sprite.play("hit")
		Anim.HURT:
			sprite.play("hurt")
		Anim.DIE:
			sprite.play("die")
			if has_node("Hitbox/CollisionShape2D"):
				$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			if has_node("Hurtbox/CollisionShape2D"):
				$Hurtbox/CollisionShape2D.set_deferred("disabled", true)

func find_player() -> void:
	if not target_player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target_player = players[0]

func pick_new_hover_offset() -> void:
	var side = -1.0 if (randf() > 0.5) else 1.0
	hover_offset = Vector2(side * randf_range(40.0, 60.0), randf_range(-60.0, -90.0))

func start_attack_cooldown() -> void:
	is_recovering = true
	await get_tree().create_timer(3.0).timeout
	is_recovering = false

func _on_animation_finished() -> void:
	match current_anim:
		Anim.ATTACK, Anim.HIT:
			if is_dead:
				return
			start_attack_cooldown()
			pick_new_hover_offset()
			change_anim(Anim.AGGRO)
			
		Anim.HURT:
			if is_dead:
				return
			if health <= 0:
				call_deferred("die")
			else:
				change_anim(Anim.AGGRO)
		Anim.DIE:
			queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox") and current_anim == Anim.ATTACK:
		velocity = Vector2.ZERO
		change_anim(Anim.HIT)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if current_anim == Anim.DIE:
		return
	var push_dir = 1.0 if area.global_position.x < global_position.x else -1.0
	if area.is_in_group("player_attack"):
		take_damage(1, Vector2(push_dir * 150, 0))
	elif area.is_in_group("player_attack_up"):
		take_damage(1, Vector2(0, -150))
	elif area.is_in_group("player_attack_down"):
		take_damage(1, Vector2(0, 100))
	elif area.is_in_group("normal_hazard"):
		take_damage(2, Vector2.ZERO)

func take_damage(amount: int, knockback: Vector2) -> void:
	if is_dead or current_anim == Anim.DIE:
		return
	health -= amount
	hit_particles.restart() 
	knocked_back = true
	velocity = knockback
	change_anim(Anim.HURT)
	await get_tree().create_timer(0.15).timeout
	if health <= 0:
		call_deferred("die")
		return
	velocity = Vector2.ZERO
	knocked_back = false
	start_attack_cooldown()
	pick_new_hover_offset()
	change_anim(Anim.AGGRO)

func can_see_player() -> bool:
	if not target_player:
		return false
	if global_position.distance_to(target_player.global_position) > aggro_range:
		return false
	if ray_cast:
		ray_cast.target_position = to_local(target_player.global_position)
		ray_cast.force_raycast_update()
		if ray_cast.is_colliding() and ray_cast.get_collider() != target_player:
			return false
	return true
	
func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	knocked_back = false
	velocity = Vector2.ZERO
	
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	var death_position = global_position
	var level: Node2D = owner
	
	for i in range(coin_reward):
		var coin = COIN_PARTICLE_SCENE.instantiate()
		level.add_child(coin)
		coin.set_spawn_position(death_position)

		
	change_anim(Anim.DIE)
