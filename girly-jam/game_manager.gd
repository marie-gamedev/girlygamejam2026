extends Node2D

@export var dialogues: BaseDialogue

var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	await dialogues._play_dialogue(Enums.dialogue_states.KEN)
	
	
	while level <= 2:
		print(level)
		await _start_level(level)
		level += 1
	return get_tree().quit()

func _start_level(level: int) -> void:
	await dialogues._play_dialogue(_get_dialogue_per_level(level))
	# start kutschen cleaning for level

func _get_dialogue_per_level(level: int) -> Enums.dialogue_states:
	match level:
		1:
			return Enums.dialogue_states.DOMINICK
		2:
			return Enums.dialogue_states.JULIAN
		_:
			return Enums.dialogue_states.KEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
