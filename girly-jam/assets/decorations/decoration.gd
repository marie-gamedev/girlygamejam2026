class_name Decoration
extends Area2D

var dragging := false
var drag_offset := Vector2.ZERO

func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select()
		dragging = true
		drag_offset = global_position - get_global_mouse_position()
		get_viewport().set_input_as_handled()

func _select() -> void:
	get_parent().move_child(self, -1) # -1 = move to end = drawn/picked last = on top

func _input(event: InputEvent) -> void:
	if not dragging:
		return
	if event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + drag_offset
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		dragging = false
		_check_if_in_carriage_bounds()

func _check_if_in_carriage_bounds() -> void:
	var game_manager : GameManager = $"../../GameManager"
	if !self.overlaps_area(game_manager.carriage_list[game_manager.level - 1].area):
		queue_free()
	pass
