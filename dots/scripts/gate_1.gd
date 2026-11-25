extends StaticBody2D

var open: bool = true
var current_anim: String = ""
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var hitsound: AudioStreamPlayer = $Hitsound

func _ready() -> void:
	anim.play("open")

func _process(_delta: float) -> void:
	if open:
		change_anim("opening")

func change_anim(animation: String) -> void:
	if animation == current_anim:
		return
	if animation == "opening":
		anim.play("opening")
		current_anim = animation
	if animation == "closing":
		anim.play("closing")
		current_anim = animation
	if animation == "hit":
		anim.play("hit")
		current_anim = animation

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "opening":
		anim.play("open")
		current_anim = "open"
	if anim_name == "closing":
		anim.play("closed")
		current_anim = "closed"
	if anim_name == "hit":
		anim.play("closed")
		current_anim = "closed"

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_attack"):
		change_anim("hit")
		hitsound.play()

func _on_fight_start() -> void:
	open = false
	change_anim("closing")

func _on_fight_end() -> void:
	open = true
	change_anim("opening")
