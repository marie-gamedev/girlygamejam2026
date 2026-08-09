class_name Tool extends Node2D

var starting_pos: Vector2

@export var particle_system: Node2D

func _ready():
	starting_pos = position
	toggle_particle_system(false)

func _process(delta):
	pass

func toggle_particle_system(toggle: bool) -> void:
	if get_child_count() == 0:
		return
	for ps in particle_system.get_children():
		ps.emitting = toggle

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select()
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				deselect()

func select() -> void:
	if Enums.tools_mode[String(name).to_upper()] == ToolsManager.mode:
		return
	print("select object!")
	ToolsManager.deselect_old_follow_tool()
	ToolsManager.follow_tool = self
	ToolsManager.set_mode(Enums.tools_mode[String(name).to_upper()])

func deselect() -> void:
	print("unselected object!, mode = ", ToolsManager.mode)
	toggle_particle_system(false)
	position = starting_pos
	ToolsManager.follow_tool = null
	ToolsManager.set_mode(Enums.tools_mode.NONE)

func check_particle_requirements() -> bool:
	if (ToolsManager.mode == Enums.tools_mode.SPONGE
	&& Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	&& ToolsManager.bucket_mode != Enums.bucket_mode.NONE):
		return true
	return false
