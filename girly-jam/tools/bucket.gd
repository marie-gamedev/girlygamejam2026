class_name Bucket extends Node2D

@export var particle_system: Node2D
@onready var timer = $Timer
@export var color_identifier : CanvasItem # getting color to tint sponge

func _ready():
	toggle_particle_system(false)

func _process(delta):
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

func _on_area_entered(area):
	if ToolsManager.mode == Enums.tools_mode.SPONGE:
		ToolsManager.set_bucket_mode(Enums.bucket_mode[String(name).to_upper()], color_identifier.modulate)
		print("timer wait time = ", timer.wait_time)
		timer.start()

func _on_timer_timeout():
	print("stopped timer and flüssigkeit!")
	ToolsManager.set_bucket_mode(Enums.bucket_mode.NONE)
	print("bucket_mode = ", ToolsManager.bucket_mode)
