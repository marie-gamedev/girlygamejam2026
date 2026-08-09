extends Node2D

var draw_pos: Vector2 = Vector2.ZERO
var draw_radius: float = 50.0
var has_pos := false

func _draw() -> void:
	if not has_pos:
		return
	draw_circle(draw_pos, draw_radius, Color.WHITE)

func draw_at(pos: Vector2, radius: float = 50.0) -> void:
	draw_pos = pos
	draw_radius = radius
	has_pos = true
	queue_redraw()
