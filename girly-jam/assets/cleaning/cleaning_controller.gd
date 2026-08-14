class_name CleaningController
extends Node2D

@export var game_manager : GameManager
@export var test_init_carriage : Carriage # only needed for test scene

var last_cleaned_pos : Vector2 = Vector2.INF
@export var tex_draw_distance = 1000

var pressed := false
var _current_carriage_to_clean : Carriage = null
var _layer_by_type: Dictionary = {}
var _active_layer = null

func _ready() -> void:
	EventBus.game_state_changed.connect(_on_game_state_changed)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if test_init_carriage:
		_set_carriage(test_init_carriage)

func _input(event: InputEvent) -> void:
	if !_current_carriage_to_clean:
		return
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.is_pressed()
		if !pressed:
			last_cleaned_pos = Vector2.INF
	elif event is InputEventMouseMotion and pressed:
		_active_layer = get_layer_entry(ToolsManager.bucket_mode, ToolsManager.mode)
		if _active_layer:
			_active_layer.scrub_at_global_pos(event.position)

func _process(_delta: float) -> void:
	if !_current_carriage_to_clean:
		return
	
	var mouse_pos = get_global_mouse_position()
	if pressed && _current_carriage_to_clean.sprite.get_rect().has_point(_current_carriage_to_clean.sprite.to_local(mouse_pos)):
		if _active_layer:
			var sqd = (last_cleaned_pos - mouse_pos).length_squared()
			if last_cleaned_pos == Vector2.INF || sqd > tex_draw_distance:
				last_cleaned_pos = mouse_pos
				_active_layer.scrub_at_global_pos(mouse_pos)
		
		ToolsManager.emit_particles(true)
		return
	
	ToolsManager.emit_particles(false)

func set_tool(tool: Enums.bucket_mode) -> void: # only used in test scene
	print("current bucket set to %s" % GlobalEnums.bucket_mode.keys()[tool])
	ToolsManager.bucket_mode = tool

func _on_layer_percentage_changed(material_type: Enums.bucket_mode, tool_type : Enums.tools_mode, percent: float) -> void:
	print("%s, %s: %.1f%% dirty remaining" % [Enums.bucket_mode.keys()[material_type], Enums.tools_mode.keys()[tool_type], percent])
	# TODO UI here, e.g. update progress bar per material
	pass

func _on_game_state_changed(new_state: Enums.game_state, current_level: int) -> void:
	if new_state == GlobalEnums.game_state.WASH:
		_set_carriage(game_manager.carriage_list[current_level - 1])
	else:
		_unset_carriage()
		pressed = false # idk if needed but better be safe

func _set_carriage(carriage : Carriage) -> void:
	if _current_carriage_to_clean:
		_unset_carriage()
	
	_current_carriage_to_clean = carriage
		
	for layer in _current_carriage_to_clean.layers:
		set_layer_entry(layer.material_type, layer.required_tool, layer)
		layer.dirt_percentage_changed.connect(_on_layer_percentage_changed)
	print("current carriage is %s" % carriage.get_path())

func _unset_carriage() -> void:
	if _current_carriage_to_clean:
		for layer in _current_carriage_to_clean.layers:
			set_layer_entry(layer.material_type, layer.required_tool, null)
			layer.dirt_percentage_changed.disconnect(_on_layer_percentage_changed)
	
	_current_carriage_to_clean = null
	print("no current carriage!")


func _make_key(mat: GlobalEnums.bucket_mode, tool: GlobalEnums.tools_mode) -> Vector2i:
	if tool != GlobalEnums.tools_mode.SPONGE:
		mat =  GlobalEnums.bucket_mode.NONE
	return Vector2i(mat, tool)

func set_layer_entry(mat: GlobalEnums.bucket_mode, tool: GlobalEnums.tools_mode, value) -> void:
	_layer_by_type[_make_key(mat, tool)] = value

func get_layer_entry(mat: GlobalEnums.bucket_mode, tool: GlobalEnums.tools_mode):
	if tool != GlobalEnums.tools_mode.SPONGE:
		mat =  GlobalEnums.bucket_mode.NONE
	return _layer_by_type.get(_make_key(mat, tool))
