extends CanvasLayer

signal dialogue_finished

@export var typing_speed: float = 35.0

@onready var panel = $Panel
@onready var name_label = $Panel/Name
@onready var dialogue_label = $Panel/Dialogue
@onready var continue_label = $Panel/Continue

var dialogue_lines: Array[String] = []
var current_line: int = 0

var is_dialogue_active: bool = false
var is_typing: bool = false

var character_timer: float = 0.0

func _ready() -> void:
	panel.hide()
	
func start_dialogue(npc_name: String, lines: Array[String]) -> void:
	if is_dialogue_active:
		return
	
	if lines.is_empty():
		return
		
	dialogue_lines = lines
	current_line = 0
	
	name_label.text = npc_name
	panel.show()
	
	is_dialogue_active = true
	show_line()
func show_line() -> void:
	dialogue_label.text = dialogue_lines[current_line]
	dialogue_label.visible_characters = 0
	
	is_typing = true
	character_timer = 0.0
	
	continue_label.hide()
	
func _process(delta: float) -> void:
	if not is_typing:
		return
		
	character_timer += delta
	
	var characters_to_show = int(character_timer * typing_speed)
	
	dialogue_label.visible_characters = characters_to_show
	
	if dialogue_label.visible_characters >= dialogue_label.get_total_character_count():
		finish_typing()
		
func finish_typing() -> void:
	is_typing = false
	continue_label.show()
	
func _unhandled_input(event: InputEvent) -> void:
	if not is_dialogue_active:
		return
		
	if event.is_action_pressed("down") and not event.is_echo():
		get_viewport().set_input_as_handled()
		
		if is_typing:
			dialogue_label.visible_characters = -1
			finish_typing()
		else:
			next_line()
			
func next_line() -> void:
	current_line += 1
	
	if current_line >= dialogue_lines.size():
		end_dialogue()
	else:
		show_line()

func end_dialogue() -> void:
	is_dialogue_active = false
	is_typing = false
	
	panel.hide()
	
	dialogue_finished.emit()
	
	
