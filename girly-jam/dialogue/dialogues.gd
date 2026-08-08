class_name BaseDialogue extends Node2D


const DialogueSettings = preload("../addons/dialogue_manager/settings.gd")
const DialogueResource = preload("../addons/dialogue_manager/dialogue_resource.gd")


@onready var title: String = DialogueSettings.get_user_value("run_title")
#@onready var resource: DialogueResource = load(DialogueSettings.get_user_value("run_resource_path"))
#@onready var resource: DialogueResource = load("res://dialogue/julian.dialogue")
#var dialogue_ken: DialogueResource = preload("res://dialogue/ken.dialogue")
#var dialogue_julian: DialogueResource = preload("res://dialogue/julian.dialogue")
#var dialogue_dominick: DialogueResource = preload("res://dialogue/king-dominick.dialogue")
const DIALOGUES := "res://dialogue/"


func _ready():
	if not Engine.is_embedded_in_editor:
		var window: Window = get_viewport()
		var screen_index: int = DisplayServer.get_primary_screen()
		window.position = Vector2(DisplayServer.screen_get_position(screen_index)) + (DisplayServer.screen_get_size(screen_index) - window.size) * 0.5
		window.mode = Window.MODE_WINDOWED

	# Normally you can just call DialogueManager directly but doing so before the plugin has been
	# enabled in settings will throw a compiler error here so I'm using `get_singleton` instead.
	var dialogue_manager = Engine.get_singleton("DialogueManager")
	#dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	#dialogue_manager.show_dialogue_balloon(resource, title if not title.is_empty() else resource.first_title)
	#_play_dialogue(Enums.dialogue_states.DOMINICK)

func _enter_tree() -> void:
	DialogueSettings.set_user_value("is_running_test_scene", false)

func play_dialogue(state: Enums.dialogue_states) -> void:
	var dialogue_resource = get_dialogue(state)
	DialogueManager.show_dialogue_balloon(dialogue_resource, title if not title.is_empty() else dialogue_resource.first_title)
	
	await DialogueManager.dialogue_ended

func get_dialogue(state: Enums.dialogue_states) -> DialogueResource:
	var character_name: String = Enums.dialogue_states.keys()[state].to_lower()
	var path := DIALOGUES + character_name + ".dialogue"
	
	return load(path) as DialogueResource
