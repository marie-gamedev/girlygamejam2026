extends Node2D

@export var dialogues: BaseDialogue
@onready var finish_wash_button = $"../Control/FinishWashButton"
@onready var inbetween_level_timer = $InbetweenLevelTimer
@onready var carriages = $"../World/Carriages"

var level: int = 1

var game_state : Enums.game_state = Enums.game_state.START:
	set(value):
		if game_state == value:
			return
		game_state = value
		game_state_changed.emit(game_state)

signal game_state_changed(new_state: Enums.game_state)

func _ready():
	carriages.position = Vector2(400,0)
	
	await dialogues.play_dialogue(Enums.dialogue_states.KEN, "start")
	
	move_carriage(level)
	
	await wait_for_game_state(Enums.game_state.PREDIALOGUE)
	
	while level <= 2:
		print("level = ", level)
		await _start_level(level)
		level += 1
	
	await dialogues.play_dialogue(Enums.dialogue_states.KEN, "ending")
	
	return get_tree().quit()

func _start_level(level: int) -> void:
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
	print("current game_state = ", game_state, " -> new game_state = ", target_state)
	game_state = target_state

func _process(delta):
	pass

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

func get_dialogue_per_level(level: int) -> Enums.dialogue_states:
	match level:
		1:
			return Enums.dialogue_states.DOMINICK
		2:
			return Enums.dialogue_states.JULIAN
		_:
			return Enums.dialogue_states.KEN

func wait_for_game_state(target_state: Enums.game_state) -> void:
	while game_state != target_state:
		await game_state_changed

func _on_finish_wash_button_pressed():
	set_game_state(Enums.game_state.POSTDIALOGUE)


func _on_inbetween_level_timer_timeout():
	set_game_state(Enums.game_state.PREDIALOGUE)
