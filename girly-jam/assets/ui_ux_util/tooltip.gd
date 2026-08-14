extends PanelContainer

const OFFSET = Vector2 (5.0, 20.0)
var opacity_tween : Tween = null

func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		_update_position()

#func _update_position() -> void:
	#var viewport_size := get_viewport_rect().size
	#var target_pos := get_global_mouse_position() + OFFSET
#
	## Clamp so the tooltip's right/bottom edge never leaves the screen
	#target_pos.x = min(target_pos.x, viewport_size.x - size.x)
	#target_pos.y = min(target_pos.y, viewport_size.y - size.y)
#
	## Clamp so it never goes off the left/top edge either
	#target_pos.x = max(target_pos.x, 0.0)
	#target_pos.y = max(target_pos.y, 0.0)
#
	#global_position = target_pos
	
func _update_position() -> void:
	var viewport_size := get_viewport_rect().size
	var mouse_pos := get_global_mouse_position()
	var target_pos := mouse_pos + OFFSET

	if target_pos.x + size.x > viewport_size.x:
		target_pos.x = mouse_pos.x - OFFSET.x - size.x  # flip to the left of cursor

	if target_pos.y + size.y > viewport_size.y:
		target_pos.y = mouse_pos.y - OFFSET.y - size.y  # flip above cursor

	global_position = target_pos

func _ready() -> void:
	hide()

func toggle(on : bool) -> void:
	if on:
		show()
		modulate.a = 0.0
		tween_opacity(1.0)
	else:
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()
		
func tween_opacity(to : float):
	if opacity_tween:
		opacity_tween.kill()
	opacity_tween = get_tree().create_tween()
	opacity_tween.tween_property(self, 'modulate:a', to, 0.3)
	return opacity_tween
