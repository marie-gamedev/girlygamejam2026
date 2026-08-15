class_name GameManager
extends Node2D

@export var ui_parent : Node2D
@export var dialogues: BaseDialogue
@onready var finish_wash_button = $"../UI Parent/Control/FinishWashButton"
@onready var inbetween_level_timer = $InbetweenLevelTimer
@onready var carriages: Node = $"../World/Carriages"
var carriage_list: Array[Carriage] = []

var level: int = 1

var game_state : Enums.game_state = Enums.game_state.NONE:
	set(value):
		if game_state == value:
			return
		game_state = value
		EventBus.game_state_changed.emit(game_state, level)
		ui_parent.visible = game_state == Enums.game_state.WASH
		ToolsManager.set_can_interact_with_tools(game_state == Enums.game_state.WASH)

signal game_state_changed(new_state: Enums.game_state, current_level : int)

func _ready() -> void:
	game_state = Enums.game_state.START
	carriage_list.clear()
	for i in carriages.get_child_count():
		var carriage: Carriage = carriages.get_child(i) as Carriage
		if carriage:
			carriage_list.append(carriage)
	
	carriages.position = Vector2(400,0)
	
	await dialogues.play_dialogue(Enums.dialogue_states.KEN, "start")
	
	move_carriage(level)
	
	await wait_for_game_state(Enums.game_state.PREDIALOGUE)
	
	while level <= 2:
		print("level = ", level)
		await _start_level(level)
		level += 1
	
	await dialogues.play_dialogue(Enums.dialogue_states.KEN, "ending")
	
	get_tree().quit()

func _start_level(lvl: int) -> void:
	level = lvl
	await dialogues.play_dialogue(get_dialogue_per_level(level), "start")
	
	# start kutschen cleaning for level and wait until kutsche abgeben mit dialogue
	set_game_state(Enums.game_state.WASH)
	await wait_for_game_state(Enums.game_state.POSTDIALOGUE)
	
	# then play finish dialoge von diesem prinzen
	await dialogues.play_dialogue(get_dialogue_per_level(level), "postdialogue")
	
	# chilli milli move carriages cutscene
	set_game_state(Enums.game_state.INBETWEEN)
	move_carriage(level+1)
	await wait_for_game_state(Enums.game_state.PREDIALOGUE)
	# -> next level

func set_game_state(target_state: Enums.game_state) -> void:
	print("current game_state = %s -> new game_state = %s" % [Enums.game_state.keys()[game_state], Enums.game_state.keys()[target_state]])
	game_state = target_state

func move_carriage(to_level: int) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(carriages, "position", get_next_carriage_pos(to_level), inbetween_level_timer.wait_time);
	inbetween_level_timer.start()

func get_next_carriage_pos(_level: int) -> Vector2:
	match _level:
		1:
			return Vector2(0, 0)
		2:
			return Vector2(-400, 0)
		_:
			return Vector2(-800, 0)

func get_dialogue_per_level(lvl: int) -> Enums.dialogue_states:
	match lvl:
		1:
			return Enums.dialogue_states.DOMINICK
		2:
			return Enums.dialogue_states.JULIAN
		_:
			return Enums.dialogue_states.KEN

func wait_for_game_state(target_state: Enums.game_state) -> void:
	while game_state != target_state:
		await EventBus.game_state_changed

func _on_finish_wash_button_pressed():
	set_game_state(Enums.game_state.POSTDIALOGUE)

func _on_inbetween_level_timer_timeout():
	set_game_state(Enums.game_state.PREDIALOGUE)
