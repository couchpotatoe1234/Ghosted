extends Area2D

@export var fly_speed: float = 250.0
@export var scatter_distance: float = 20.0 
@export var pickup_range: float = 100.0

var player: Node2D
var scatter_target: Vector2
var is_scattering: bool = true

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player") as Node2D
	
	var start_position = global_position
	
	scatter_target = start_position + Vector2(randf_range(-scatter_distance, scatter_distance), randf_range(-scatter_distance, scatter_distance))
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_scattering:
		global_position = global_position.move_toward(
			scatter_target, 100 * delta
		)
		
		if global_position.distance_to(scatter_target) < 1.0:
			is_scattering = false
			
		return
		
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		return
		
	var distance_to_player = global_position.distance_to(
		player.global_position
	)
	
	if distance_to_player > pickup_range:
		return
		
	global_position = global_position.move_toward(
		player.global_position, fly_speed * delta
	)
	
	if global_position.distance_to(player.global_position) < 12.0:
		GameManager.add_money(1)
		queue_free()
