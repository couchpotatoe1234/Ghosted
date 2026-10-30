extends Control

@onready var hearts: Array[AnimatedSprite2D] = [$Heart1, $Heart2, $Heart3, $Heart4, $Heart5]
@onready var label: Label = $Label
@onready var label2: Label = $Label2

func _ready() -> void:
	label.text = str(GameManager.heals)
	label2.text = str(GameManager.coins)
	var player = get_tree(). get_first_node_in_group("player")
	GameManager.money_changed.connect(money)
	money(GameManager.coins)
	if player:
		_connect_to_player(player)
	else:
		get_tree().node_added.connect(_on_node_added)
		
@warning_ignore("unused_parameter")
func _on_health_changed(current_health: int, max_health: int) -> void:
	for i in range(hearts.size()):
		var last_frame = hearts[i].sprite_frames.get_frame_count("hit") - 1
		
		hearts[i].stop()
		
		if i < current_health:
			hearts[i].frame = 0
		elif i == current_health:
			hearts[i].play("hit")
		else:
			hearts[i].frame = last_frame
			
func _on_node_added(node: Node) -> void:
	if node.is_in_group("player"):
		_connect_to_player(node)
		get_tree().node_added.disconnect(_on_node_added)
		
func _connect_to_player(player: Node) -> void:
	if not player.health_changed.is_connected(_on_health_changed):
		player.health_changed.connect(_on_health_changed)
	
	_on_health_changed(GameManager.health, player.max_health)

	
func change_heals() -> void:
	label.text = str(GameManager.heals)
	
func money(new: int) -> void:
	label2.text = str(new)
	
