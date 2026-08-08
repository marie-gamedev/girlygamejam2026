extends Node2D

@export var sponge: Tool
@export var towel: Tool
@export var brush: Tool
@export var yarn_and_needle: Tool

var mode : Enums.tools_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_mode(_mode: Enums.tools_mode):
	print("old mode = ", mode)
	mode = _mode
	print("new mode = ", mode)
