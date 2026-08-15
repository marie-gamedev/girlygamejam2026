class_name GameManager
extends Node2D

@export var ui_parent : Node2D
@export var dialogues: BaseDialogue
@onready var finish_wash_button = $"../UI Parent/Control/FinishWashButton"
@onready var carriages: Node = $"../World/Carriages"
var carriage_list: Array[Carriage] = []
var carriage_target_pos_list: Array[Vector2] = []
@export var decoration_parent : DecoParent

var level: int = 1
const transition_duration : float = 3

var game_state : Enums.game_state = Enums.game_state.NONE:
	set(value):
		if game_state == value:
			return
		game_state = value
		EventBus.game_state_changed.emit(game_state, level)
		ui_parent.visible = game_state == Enums.game_state.WASH
		ToolsManager.set_can_interact_with_tools(game_state == Enums.game_state.WASH)
		if game_state == Enums.game_state.WASH:
			decoration_parent.detach_from_carriage()
			decoration_parent.remove_all_children()
			decoration_parent.attach_to_carriage(carriage_list[level - 1])

signal game_state_changed(new_state: Enums.game_state, current_level : int)

func _ready() -> void:
	game_state = Enums.game_state.START
	carriage_list.clear()

	var viewport_size := get_viewport_rect().size
	for i in carriages.get_child_count():
		var carriage: Carriage = carriages.get_child(i) as Carriage
		if carriage:
			carriage_list.append(carriage)
			carriage_target_pos_list.append(carriage.position) # keep storing local "center" target, unchanged
			var half_width := get_carriage_half_width(carriage)
			var right_offscreen_global := Vector2(viewport_size.x + half_width, carriage.global_position.y)
			carriage.global_position = right_offscreen_global
	
	await dialogues.play_dialogue(Enums.dialogue_states.KYLE, "start")
	
	while level <= 2:
		print("level = ", level)
		await _start_level(level)
		level += 1
	
	await dialogues.play_dialogue(Enums.dialogue_states.KYLE, "ending")
	
	return_to_menu()

func _start_level(lvl: int) -> void:
	await move_carriage_to_center(lvl)
	set_game_state(Enums.game_state.PREDIALOGUE)
	level = lvl
	await dialogues.play_dialogue(get_dialogue_per_level(level), "start")
	
	# start kutschen cleaning for level and wait until kutsche abgeben mit dialogue
	set_game_state(Enums.game_state.WASH)
	await wait_for_game_state(Enums.game_state.POSTDIALOGUE)
	
	# then play finish dialoge von diesem prinzen
	await dialogues.play_dialogue(get_dialogue_per_level(level), "postdialogue")
	
	# chilli milli move carriages cutscene
	set_game_state(Enums.game_state.INBETWEEN)
	await move_carriage_offscreen(level)

func set_game_state(target_state: Enums.game_state) -> void:
	print("current game_state = %s -> new game_state = %s" % [Enums.game_state.keys()[game_state], Enums.game_state.keys()[target_state]])
	game_state = target_state

func move_carriage_to_center(to_level: int) -> void:
	var tween = get_tree().create_tween()
	var carriage = carriage_list[level - 1]
	tween.tween_property(carriage, "position", carriage_target_pos_list[to_level - 1], transition_duration);
	await tween.finished
	
func move_carriage_offscreen(to_level: int) -> void:
	var tween = get_tree().create_tween()
	var carriage = carriage_list[to_level - 1]
	var half_width := get_carriage_half_width(carriage)
	var left_offscreen_global := Vector2(-half_width, carriage.global_position.y)
	var left_offscreen_local : Vector2 = carriage.get_parent().to_local(left_offscreen_global)

	tween.tween_property(carriage, "position", left_offscreen_local, transition_duration)
	await tween.finished
	
func get_dialogue_per_level(lvl: int) -> Enums.dialogue_states:
	match lvl:
		1:
			return Enums.dialogue_states.DOMINICK
		2:
			return Enums.dialogue_states.NICHOLAS
		_:
			return Enums.dialogue_states.KYLE

func wait_for_game_state(target_state: Enums.game_state) -> void:
	while game_state != target_state:
		await EventBus.game_state_changed

func return_to_menu() -> void:
	#clear autoloads info
	ToolsManager.reset()
	
	get_tree().change_scene_to_file("res://menu.tscn")

func _on_finish_wash_button_pressed():
	set_game_state(Enums.game_state.POSTDIALOGUE)

func _on_full_screen_button_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func get_carriage_half_width(carriage : Carriage) -> float:
	if carriage.sprite:
		var rect := carriage.sprite.get_rect()
		return (rect.size.x * abs(carriage.global_scale.x)) / 2.0
	return 0.0
