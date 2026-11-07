extends CharacterBody2D

@export var max_health: int = 10
@export var damage: int = 1
@export var detect_range: float = 400.0


enum State {IDLE, ATTACKING, DEAD}

var state: State = State.IDLE
var health: int
var player: Node2D
var boss_direction = -1


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea
@onready var health_ui: CanvasLayer = $CanvasLayer
@onready var health_bar: ProgressBar = $CanvasLayer/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_ui.visible = false
	_play("idle")
	

func _physics_process(delta: float) -> void:
	if state == State.DEAD: 
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = 0.0
	move_and_slide()
	
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
		return
		
	var dx := player.global_position.x - global_position.x
	var dist := global_position.distance_to(player.global_position)
	
	if dist <=  detect_range:
		health_ui.visible = true
		
	#if state == State.IDLE
	
func _play(anim: String) -> void:
	if animation_player.has_animation(anim): 
		animation_player.play(anim)
