extends Node

var controls_allowed = true
var last_save_point = Vector2(0, 0)
var last_level = "res://scenes/rooms/cave2.tscn"
var save_facing: bool = false
var player_x: float = 0
var last_respawn_position: Vector2 = Vector2.ZERO
var hitstop_active: bool = false
var current_hitstop_duration: float = 0.0
var can_pause = false
var heals = 2
var coins: int = 0
var health: int = 5
var hitstop_id: int = 0
var has_boss: bool
var boss_defeated := false
var defeatedBoss : Array[CharacterBody2D] = []
signal money_changed(new: int)

func hitstop(duration: float, magnitude: float = 0.0) -> void:
	if hitstop_active and duration < current_hitstop_duration:
		return
	else:
		current_hitstop_duration = duration
		hitstop_active = true
		Engine.time_scale = magnitude
		hitstop_id += 1
		var current_id = hitstop_id
		await get_tree().create_timer(duration, true, false, true).timeout
		if hitstop_id == current_id:
			Engine.time_scale = 1.0
			hitstop_active = false
			current_hitstop_duration = 0.0
		
func add_money(amount: int) -> void:
	coins += amount
	money_changed.emit(coins)

#ROOMSS Starting Position; where you first enter from.
#room 1 = -675, -400
#room 2 = -2415, -65
#room 3 = -2543, -161
#bar = 0, -256
#mtr1 = 81, -61
#mtr2 = 75, -91
#mtr3 = 0, 0
#bar_trans = 
#Shop-Trans = -623, 159



var block1_broken = false
var block2_broken = false

var coin_cache_1 = false
var coin_cache_2 = false
