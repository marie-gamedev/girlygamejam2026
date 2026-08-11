class_name CleaningController
extends Node2D

@export var game_manager : GameManager
@export var test_init_carriage : Carriage # only needed for test scene

var pressed := false
var _current_carriage_to_clean = null
var _layer_by_type: Dictionary = {}

func _ready() -> void:
	EventBus.game_state_changed.connect(_on_game_state_changed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if test_init_carriage:
		_set_carriage(test_init_carriage)

func _input(event: InputEvent) -> void:
	if !_current_carriage_to_clean:
		pass
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.is_pressed()
	elif event is InputEventMouseMotion and pressed:
		var active_layer: DirtLayer = _layer_by_type.get(ToolsManager.bucket_mode)
		if active_layer:
			active_layer.scrub_at_global_pos(event.position)

func _process(_delta: float) -> void:
	if !_current_carriage_to_clean:
		pass
		
	if pressed:
		var active_layer: DirtLayer = _layer_by_type.get(ToolsManager.bucket_mode)
		if active_layer:
			active_layer.scrub_at_global_pos(get_global_mouse_position())

func set_tool(tool: Enums.bucket_mode) -> void:
	print("current bucket set to %s" % GlobalEnums.bucket_mode.keys()[tool])
	ToolsManager.bucket_mode = tool

func _on_layer_percentage_changed(material_type: Enums.bucket_mode, percent: float) -> void:
	print("%s: %.1f%% dirty remaining" % [Enums.bucket_mode.keys()[material_type], percent])
	# TODO UI here, e.g. update progress bar per material
	pass

func _on_game_state_changed(new_state: Enums.game_state, current_level: int) -> void:
	if new_state == GlobalEnums.game_state.WASH:
		_set_carriage(game_manager.carriage_list[current_level])
	else:
		_unset_carriage()
		pressed = false # idk if needed but better be safe

func _set_carriage(carriage : Carriage) -> void:
	if _current_carriage_to_clean:
		_unset_carriage()
	
	_current_carriage_to_clean = carriage
		
	for layer in _current_carriage_to_clean.layers:
		_layer_by_type[layer.material_type] = layer
		layer.dirt_percentage_changed.connect(_on_layer_percentage_changed)
	print("current carriage is %s" % carriage.get_path())

func _unset_carriage() -> void:
	if _current_carriage_to_clean:
		for layer in _current_carriage_to_clean.layers:
			_layer_by_type[layer.material_type] = layer
			layer.dirt_percentage_changed.disconnect(_on_layer_percentage_changed)
	
	_current_carriage_to_clean = null
	print("no current carriage!")
