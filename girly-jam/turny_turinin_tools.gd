extends Node2D

@export var time : float = 5
var current_time : float
var next_rot : int = -1

func _ready() -> void:
	set_rotations()

func set_rotations() -> void:
	for node : Node2D in get_children():
		node.rotation_degrees = 45 * next_rot
		
	next_rot *= -1

func _process(delta: float) -> void:
	current_time += delta
	if current_time >= time:
		set_rotations()
		current_time = 0
