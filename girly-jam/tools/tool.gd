class_name Tool extends Node2D

var starting_pos: Vector2

@export var particle_system: Node2D
@export var sprite : CanvasItem # for tinting
@export var type : GlobalEnums.tools_mode
@export var audio_player : AudioStreamPlayer2D

func _ready():
	assert(type != GlobalEnums.tools_mode.NONE)
	ToolsManager.register_tool(self)
	starting_pos = position
	toggle_particle_system(false)

func toggle_particle_system(toggle: bool) -> void:
	if toggle && !audio_player.playing:
		audio_player.play()
	elif !toggle && audio_player.playing:
		print("stop")
		audio_player.stop()
	
	if get_child_count() == 0:
		return
	for ps in particle_system.get_children():
		ps.emitting = toggle

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			select()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
				deselect()

func select() -> void:
	if type == ToolsManager.mode:
		return
	print("select object!")
	ToolsManager.deselect_old_follow_tool()
	ToolsManager.follow_tool = self
	ToolsManager.set_mode(type)

func deselect() -> void:
	print("unselected object!, mode = ", ToolsManager.mode)
	toggle_particle_system(false)
	position = starting_pos
	ToolsManager.follow_tool = null
	ToolsManager.set_mode(Enums.tools_mode.NONE)

func check_particle_requirements() -> bool:
	if (ToolsManager.mode == Enums.tools_mode.NONE
	|| !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		return false
	
	if (ToolsManager.mode == Enums.tools_mode.SPONGE &&
		ToolsManager.bucket_mode == Enums.bucket_mode.NONE):
		return false

	return true

func tint_tool(color : Color) -> void:
	sprite.modulate = color;
	pass
