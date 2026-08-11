class_name Bucket extends Node2D

@export var particle_system: Node2D
@onready var timer = $Timer
@export var color_identifier : CanvasItem # getting color to tint sponge
@export var type : GlobalEnums.bucket_mode

func _ready():
	toggle_particle_system(false)

func _process(_delta):
	if ToolsManager.bucket_mode != Enums.bucket_mode.NONE:
		'position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			toggle_particle_system(true)
		else:
			toggle_particle_system(false)'

func toggle_particle_system(toggle: bool) -> void:
	if get_child_count() == 0:
		return
	for ps in particle_system.get_children():
		ps.emitting = toggle

func _on_area_entered(_area):
	#_select_tool()
	pass

func _select_tool() -> void:
	if ToolsManager.mode == Enums.tools_mode.SPONGE:
		ToolsManager.set_bucket_mode(type, color_identifier.modulate)
		print("timer wait time = ", timer.wait_time)
		timer.start()

func _on_timer_timeout():
	print("stopped timer and flüssigkeit!")
	ToolsManager.set_bucket_mode(Enums.bucket_mode.NONE)

func _input_event(_viewport, event, _shape_idx):
	if ToolsManager.mode != GlobalEnums.tools_mode.SPONGE:
		pass
	
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				_select_tool()
