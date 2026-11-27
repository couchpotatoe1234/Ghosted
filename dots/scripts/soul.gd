extends Area2D

@onready var prompt: Label = $Label
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var npc_name: String = "legler"
@export var dialogue: Array[String] = [
	"Lucas:	alr	u fix soul guy	and i fix a couple things with mtr4 that annoy me	lie the fact that you put a fjking platform in the parallax2d thingadi:	whoopsLucas:	and u know you dont need to spam 50 respawn points onto each platform right	and then forget abt all the other platforms",
	"yes or nooo"
]

var player_in_range: bool = false


func _ready() -> void:
	prompt.text = "Press " + OS.get_keycode_string(InputMap.action_get_events("up")[0].physical_keycode) + " to talk"
	if sprite == null:
		push_error("missing")
		return
	
	sprite.play("default")
	prompt.hide()
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if player_in_range:
		if Input.is_action_just_pressed("up"):
			Dialogue.start_dialogue("Soul", dialogue, true)
			
			var answer: bool = await Dialogue.choice_selected
			
			if answer:
				if GameManager.coins > 4:
					activate()
					await get_tree().create_timer(0.5).timeout

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		if is_instance_valid(prompt):
			prompt.visible = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		if is_instance_valid(prompt):
			prompt.show()

func activate() -> void:
	GameManager.heals += 1
	get_tree().call_group("hud", "change_heals")
	GameManager.add_money(-5)
	GameManager.hitstop(0.1)
	
