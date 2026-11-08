extends CharacterBody2D

@export var max_health: int = 10
@export var damage: int = 1
@export var detect_range: float = 400.0
@export var windup_time: float = 0.5
@export var strike_time: float = 0.25
@export var cooldown_time: float = 1.2
@export var attack_range: float = 140.0




enum State {IDLE, ATTACKING, RAGING, DEAD}

var attack_range_reached : bool  = false
var state: State = State.IDLE
var health: int
var player: Node2D
var boss_direction = -1
var hit_lock:   bool = false


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_ui: CanvasLayer = $CanvasLayer
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimatedSprite2D/AnimationPlayer

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_ui.visible = false
	print("start")
	_play("idle")
	

func _physics_process(delta: float) -> void:
	if state == State.DEAD: 
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = 0.0
	move_and_slide()
	
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
		
	var dx := player.global_position.x - global_position.x
	var dist := global_position.distance_to(player.global_position)
		
	if dist <= detect_range:
		health_ui.visible = true
		
	if state == State.IDLE:
		_face(dx)
		if dist <= attack_range:
			_attack()
		
	
func _face(dx: float) -> void:
	boss_direction = 1 if dx > 0 else -1
	animated_sprite_2d.flip_h = boss_direction < 0
	#attack_area.scale.x = boss_direction
	pass

func _attack() -> void:
	state = State.RAGING
	_play("idle")
	await  get_tree().create_timer(windup_time).timeout
	if state == State.DEAD:
		return
			
	state = State.ATTACKING
	_play("attack")
	
	var hit := false
	var elapsed := 0.0
	while elapsed < strike_time and not hit:
		await  get_tree().physics_frame
		if state == State.DEAD:
			return
		elapsed += get_physics_process_delta_time()
		if attack_range_reached and state == State.ATTACKING:
			player.take_damage(damage)
			hit = true
			
	
	state = State.RAGING
	_play("idle")
	await  get_tree().create_timer(cooldown_time).timeout
	if state != State.DEAD:
		state = State.IDLE

func take_hit(_direction: Vector2) -> void:
	if state == State.DEAD or hit_lock:
		return
	hit_lock = true	
	health -= 1
	health_bar.value = health
#	broadcast signal
	
	animated_sprite_2d.modulate = Color(1.0, 0.3, 0.3)
	create_tween().tween_property(animated_sprite_2d, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
#		die
		pass
	
	await get_tree().create_timer(0.25).timeout
	hit_lock = false

func _play(anim: String) -> void:
	animated_sprite_2d.play(anim)




func _on_attack_area_body_entered(body: Node2D) -> void:
	attack_range_reached = true


func _on_attack_area_body_exited(body: Node2D) -> void:
	attack_range_reached = false
