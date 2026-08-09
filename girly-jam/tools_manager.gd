extends Node2D

@export var sponge: Tool
@export var towel: Tool
@export var brush: Tool
@export var yarn_and_needle: Tool

var mode : Enums.tools_mode
var bucket_mode : Enums.bucket_mode

var follow_tool : Tool

func _ready():
	pass # Replace with function body.

func _process(delta):
	if follow_tool:
		follow_tool.position = get_global_mouse_position()
		if follow_tool.check_particle_requirements():
			follow_tool.toggle_particle_system(true)
		else:
			follow_tool.toggle_particle_system(false)

func set_mode(_mode: Enums.tools_mode):
	if mode == Enums.tools_mode.SPONGE && _mode == Enums.tools_mode.NONE:
		set_bucket_mode(Enums.bucket_mode.NONE)
	mode = _mode

func set_bucket_mode(_mode : Enums.bucket_mode):
	bucket_mode = _mode

func deselect_old_follow_tool():
	if follow_tool:
		follow_tool.deselect()
