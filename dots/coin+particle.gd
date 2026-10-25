extends CharacterBody2D

@export var fly_speed: float = 250.0
@export var scatter_distance: float = 20.0 
@export var pickup_range: float = 100.0
@export var gravity: float = 98.0
@export var collect_distance: float = 20.0

var player: Node2D
var scatter_target: Vector2
var is_scattering: bool = true
var collected: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	
	scatter_target = global_position + Vector2(randf_range(-scatter_distance, scatter_distance), randf_range(-scatter_distance, scatter_distance))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if collected:
		return
		
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	
	if is_scattering:
		var to_target = scatter_target - global_position
		
		velocity.x = to_target.x * 5.0
		velocity.y = to_target.y * 5.0 + gravity * delta
		
		move_and_slide()
		
		if global_position.distance_to(scatter_target) < 5.0:
			is_scattering = false
			
		return
		
	if not is_instance_valid(player):
		velocity.y += gravity * delta
		move_and_slide()
		return
		
	var distance_to_player := global_position.distance_to(player.global_position)
	
	if distance_to_player <= collect_distance:
		collected = true
		GameManager.add_money(1)
		queue_free()
		return
	
	if distance_to_player <= pickup_range:
		
		velocity = global_position.direction_to(
			player.global_position
		) * fly_speed
	else:
		velocity.y += gravity * delta
		velocity.x = move_toward(velocity.x, 0.0, 300.0 * delta)
		
	move_and_slide()
	
	if is_instance_valid(player):
		if global_position.distance_to(player.global_position) < 12.0:
			GameManager.add_money(1)
			queue_free()
