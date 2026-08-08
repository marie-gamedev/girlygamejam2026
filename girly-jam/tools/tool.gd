class_name Tool extends Node2D

#var hovering: bool = false
var follow: bool = false
var starting_pos: Vector2

@export var particle_system: Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_pos = position
	toggle_particle_system(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if follow:
		position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			toggle_particle_system(true)
		else:
			toggle_particle_system(false)

func toggle_particle_system(toggle: bool) -> void:
	if get_child_count() == 0:
		return
	for ps in particle_system.get_children():
		ps.emitting = toggle

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("select object!")
			ToolsManager.set_mode(Enums.tools_mode[String(name).to_upper()])
			follow = true
		else: if event.button_index == MOUSE_BUTTON_RIGHT:
			if follow:
				print("unselected object!")
				position = starting_pos
				ToolsManager.set_mode(Enums.tools_mode.NONE)
				follow = false
