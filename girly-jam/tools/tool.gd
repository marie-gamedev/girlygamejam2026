class_name Tool extends Node2D

#var hovering: bool = false
var follow: bool = false
var starting_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	starting_pos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if follow:
		position = get_global_mouse_position()
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			print("cleeaaaningg or doing smth.. yeyyy!!!")


#func _on_mouse_entered():
	#print("mouse hovering tool")
	#ToolsManager.set_mode(Enums.tools_mode[String(name).to_upper()])
	#hovering = true


#func _on_mouse_exited():
	#print("mouse left tool area")
	#ToolsManager.set_mode(Enums.tools_mode.NONE)
	#hovering = false


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
