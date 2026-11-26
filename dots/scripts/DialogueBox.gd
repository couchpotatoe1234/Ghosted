extends CanvasLayer

signal dialogue_finished
signal choice_selected(answer: bool)
signal remove_hud
signal add_hud

@export var typing_speed: float = 35.0

@onready var panel = $Panel
@onready var name_label = $Panel/Name
@onready var dialogue_label = $Panel/Dialogue
@onready var continue_label = $Panel/Continue
@onready var yes_button = $Panel/Yes
@onready var no_button = $Panel/No

var dialogue_lines: Array[String] = []
var current_line: int = 0

var is_dialogue_active: bool = false
var is_typing: bool = false
var waiting_for_choice: bool = false
var has_choice: bool = false

var character_timer: float = 0.0

func _ready() -> void:
	panel.hide()
	yes_button.hide()
	no_button.hide()
	
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_on_no_pressed)
	
	
func start_dialogue(npc_name: String, lines: Array[String], with_choice: bool = false) -> void:
	if is_dialogue_active or lines.is_empty():
		return
	
	dialogue_lines = lines
	current_line = 0
	has_choice = with_choice
	
	name_label.text = npc_name
	panel.show()
	
	is_dialogue_active = true
	remove_hud.emit()
	show_line()
	
	
func show_line() -> void:
	dialogue_label.text = dialogue_lines[current_line]
	dialogue_label.visible_characters = 0
	
	is_typing = true
	character_timer = 0.0
	
	continue_label.hide()
	yes_button.hide()
	no_button.hide()
	
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
		
		if waiting_for_choice:
			return
			
		if is_typing:
			dialogue_label.visible_characters = -1
			finish_typing()
		else:
			next_line()
			
func next_line() -> void:
	current_line += 1
	
	if current_line >= dialogue_lines.size():
		if has_choice:
			show_choice()
		else:
			end_dialogue()
	else:
		show_line()

func show_choice() -> void:
	waiting_for_choice = true
	
	continue_label.hide()
	yes_button.show()
	no_button.show()
	
func _on_yes_pressed() -> void:
	select_choice(true)
	
func _on_no_pressed() -> void:
	select_choice(false)

func select_choice(answer: bool) -> void:
	if not waiting_for_choice:
		return
	waiting_for_choice = false
	
	yes_button.hide()
	no_button.hide()
	
	end_dialogue()
	
	choice_selected.emit(answer)
	
func end_dialogue() -> void:
	is_dialogue_active = false
	is_typing = false
	waiting_for_choice = false
	
	panel.hide()
	
	
	dialogue_finished.emit()
	add_hud.emit()
	
	
