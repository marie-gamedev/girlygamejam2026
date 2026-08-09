extends Button

@export var tool_type : GlobalEnums.bucket_mode = GlobalEnums.bucket_mode.NONE
@export var cleaning_controller : CleaningController

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			cleaning_controller.set_tool(tool_type)
