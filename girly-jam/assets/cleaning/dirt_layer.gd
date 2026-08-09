extends Node2D
class_name DirtLayer

@export var material_type: GlobalEnums.bucket_mode = GlobalEnums.bucket_mode.NONE
@export var dirt_sprite: Sprite2D
@export var car_sprite: Sprite2D
@export var brush_radius: float = 50.0
@export var percentage_update_interval: float = 0.2

@onready var sub_viewport: SubViewport = $SubViewport
@onready var drawing: Node2D = $SubViewport/Drawing

var dirt_img: Image
var car_img: Image
var car_rect_pos: Vector2
var car_rect_size: Vector2
var dirt_total_pixels := 0
var _percentage_timer := 0.0
var clean_percentage := 100.0

var _dirty := false

signal dirt_percentage_changed(material_type: Enums.bucket_mode, percent: float)

func _ready() -> void:
	print("material_type on ready: ", material_type, " node path: ", get_path())
	assert(material_type != GlobalEnums.bucket_mode.NONE, "you forgot to set a material!")
	
	dirt_sprite.material = dirt_sprite.material.duplicate()

	var tex_size: Vector2i = dirt_sprite.texture.get_size()
	sub_viewport.size = tex_size
	sub_viewport.transparent_bg = true
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE  # render initial empty frame
	sub_viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE

	dirt_sprite.material.set_shader_parameter("mask_texture", sub_viewport.get_texture())

	dirt_img = dirt_sprite.texture.get_image()
	car_img = car_sprite.texture.get_image()

	call_deferred("_setup_car_alignment")

func _setup_car_alignment() -> void:
	var dirt_size_scaled := Vector2(dirt_sprite.texture.get_size()) * dirt_sprite.scale
	var car_size_scaled := Vector2(car_sprite.texture.get_size()) * car_sprite.scale

	var dirt_top_left := dirt_sprite.position - dirt_size_scaled * 0.5
	var car_top_left := car_sprite.position - car_size_scaled * 0.5

	car_rect_pos = (car_top_left - dirt_top_left) / dirt_size_scaled
	car_rect_size = car_size_scaled / dirt_size_scaled

	dirt_sprite.material.set_shader_parameter("car_texture", car_sprite.texture)
	dirt_sprite.material.set_shader_parameter("car_rect_pos", car_rect_pos)
	dirt_sprite.material.set_shader_parameter("car_rect_size", car_rect_size)

	_compute_dirt_total_pixels()

func _process(delta: float) -> void:
	_percentage_timer += delta
	if _percentage_timer >= percentage_update_interval:
		_percentage_timer = 0.0
		if _dirty:
			_update_dirt_percentage()
			_dirty = false

# called externally by CleaningController only when this layer's tool is active
func scrub_at_global_pos(global_pos: Vector2) -> void:
	var tex_pos := _global_to_texture_pos(global_pos)
	drawing.draw_at(tex_pos, brush_radius)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_dirty = true  # see part 2

func _global_to_texture_pos(global_pos: Vector2) -> Vector2:
	var local := dirt_sprite.to_local(global_pos)
	if dirt_sprite.centered:
		local += Vector2(dirt_sprite.texture.get_size()) * 0.5
	return local

func _car_alpha_at_dirt_pixel(dx: int, dy: int, dirt_w: int, dirt_h: int) -> float:
	var uv := Vector2(float(dx) / dirt_w, float(dy) / dirt_h)
	var car_uv := (uv - car_rect_pos) / car_rect_size
	if car_uv.x < 0.0 or car_uv.x > 1.0 or car_uv.y < 0.0 or car_uv.y > 1.0:
		return 0.0
	var cx = clamp(int(car_uv.x * car_img.get_width()), 0, car_img.get_width() - 1)
	var cy = clamp(int(car_uv.y * car_img.get_height()), 0, car_img.get_height() - 1)
	return car_img.get_pixel(cx, cy).a

func _compute_dirt_total_pixels() -> void:
	dirt_total_pixels = 0
	if dirt_img == null or car_img == null:
		return
	var stride := 2
	var w := dirt_img.get_width()
	var h := dirt_img.get_height()
	for y in range(0, h, stride):
		for x in range(0, w, stride):
			if dirt_img.get_pixel(x, y).a > 0.01 and _car_alpha_at_dirt_pixel(x, y, w, h) > 0.01:
				dirt_total_pixels += 1

func _update_dirt_percentage() -> void:
	if dirt_total_pixels == 0 or dirt_img == null or car_img == null:
		return
	var mask_img := sub_viewport.get_texture().get_image()
	if mask_img == null:
		return
	var stride := 2
	var w := dirt_img.get_width()
	var h := dirt_img.get_height()
	var remaining := 0
	for y in range(0, h, stride):
		for x in range(0, w, stride):
			if dirt_img.get_pixel(x, y).a > 0.01 \
			and mask_img.get_pixel(x, y).r < 0.5 \
			and _car_alpha_at_dirt_pixel(x, y, w, h) > 0.01:
				remaining += 1
	clean_percentage = 100.0 * float(remaining) / float(dirt_total_pixels)
	dirt_percentage_changed.emit(material_type, clean_percentage)
