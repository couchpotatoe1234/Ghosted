extends CharacterBody2D

const COIN_PARTICLE_SCENE = preload("res://scenes/CoinParticles.tscn")

@export var coin_reward: int = 1
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wall_ray: RayCast2D = $WallRayCheck
@onready var ledge_ray: RayCast2D = $LedgeRayCheck
@onready var hit_particles: GPUParticles2D = $HurtParticlesFX/GPUParticles2D
@onready var moving_audio: AudioStreamPlayer2D = $MovingAudio
var health: int = 2
var knock_dir: int = 1
var damaged = false
var speed: float = 30.0
var is_dead: bool = false
var stop: bool = false
var direction: int = 1

func _ready():
	sprite.play("walk")
	sprite.flip_h = (direction > 0)
	moving_audio.play()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		
		velocity += get_gravity() * delta
	if stop:
		velocity.x = 0
		move_and_slide()
		return
	if not damaged:
		if not moving_audio.playing:
			moving_audio.play()
		if is_on_wall() or (
			(wall_ray.is_colliding() or not ledge_ray.is_colliding())
			and is_on_floor()
		):
			flip_direction()
			
		velocity.x = direction * speed
	move_and_slide()
		


func flip_direction() -> void:
	if stop or not is_on_floor():
		return
		
	direction *= -1
	sprite.flip_h = direction > 0
	wall_ray.position.x = -wall_ray.position.x
	ledge_ray.position.x = -ledge_ray.position.x
	
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if is_dead or health <= 0:
		return
		
	if area.is_in_group("player_attack"):
		knock_dir = 1 if GameManager.player_x > global_position.x else -1
		take_damage(1, Vector2(-40 * knock_dir, -150), 0.4)
		
	elif area.is_in_group("player_attack_up"):
		knock_dir = 1 if GameManager.player_x > global_position.x else -1
		take_damage(1, Vector2(-40 * knock_dir, -150), 0.4)
	
	elif area.is_in_group("player_attack_down"):
		take_damage(1, Vector2(0, 0), 0.4)
	
	elif area.is_in_group("normal_hazard"):
		take_damage(health, Vector2.ZERO, 0.0)
		
func take_damage(amount: int, knockback: Vector2, hurt_duration: float) -> void:
	if is_dead:
		return
	moving_audio.stop()
	health -= amount
	
		
	damaged = true
	hit_particles.restart()
	sprite.play("hurt")
	velocity = knockback
	
	await get_tree().create_timer(hurt_duration).timeout
	if health <= 0:
		die.call_deferred()
		return
	if is_dead or not is_inside_tree():
		return
	damaged = false
	sprite.play("walk")


func die() -> void:
	is_dead = true
	stop = true
	damaged = false
	speed = 0.0
	
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	
	var death_position: Vector2 = global_position
	var level: Node2D = owner
	print(level)
	
	print("ground enemy died at", death_position)
	
	for i in range(coin_reward):
		var coin = COIN_PARTICLE_SCENE.instantiate()
		level.add_child(coin)
		coin.set_spawn_position(death_position)
		print("coin spawn", coin.global_position)
	
	sprite.play("death")

func _on_animation_finished() -> void:
	if sprite.animation == "death":
		queue_free()
