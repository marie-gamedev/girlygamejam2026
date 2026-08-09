class_name CleaningController
extends Node2D

@export var current_tool: GlobalEnums.bucket_mode = GlobalEnums.bucket_mode.NONE
@export var layers: Array[DirtLayer] = []

var pressed := false
var _layer_by_type: Dictionary = {}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	for layer in layers:
		_layer_by_type[layer.material_type] = layer
		layer.dirt_percentage_changed.connect(_on_layer_percentage_changed)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pressed = event.is_pressed()
	elif event is InputEventMouseMotion and pressed:
		var active_layer: DirtLayer = _layer_by_type.get(current_tool)
		if active_layer:
			active_layer.scrub_at_global_pos(event.position)

func _process(_delta: float) -> void:
	if pressed:
		var active_layer: DirtLayer = _layer_by_type.get(current_tool)
		if active_layer:
			active_layer.scrub_at_global_pos(get_global_mouse_position())

func set_tool(tool: Enums.bucket_mode) -> void:
	print("current tool set to ", tool)
	current_tool = tool

func _on_layer_percentage_changed(material_type: Enums.bucket_mode, percent: float) -> void:
	print("%s: %.1f%% dirty remaining" % [Enums.bucket_mode.keys()[material_type], percent])
	# TODO UI here, e.g. update progress bar per material
	pass
