extends StaticBody2D

var open: bool = true
var current_anim: String = ""
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var particles: GPUParticles2D = $GPUParticles2D
@onready var hitsound: AudioStreamPlayer = $AudioStreamPlayer

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

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "opening":
		anim.play("open")
	if anim_name == "closing":
		anim.play("closed")
		
