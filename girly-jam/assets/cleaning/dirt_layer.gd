extends Node2D
class_name DirtLayer

@export var material_type : GlobalEnums.bucket_mode = GlobalEnums.bucket_mode.NONE
@export var required_tool : GlobalEnums.tools_mode = GlobalEnums.tools_mode.NONE
@export var dirt_sprite: Sprite2D
@export var car_sprite: Sprite2D
@export var brush_radius: float = 50.0
@export var brush_strength: float = 0.2 # opacity removed per pass, 0..1
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

var _valid_pixels: PackedVector2Array = PackedVector2Array()
var _dirty := false

signal dirt_percentage_changed(material_type: Enums.bucket_mode, tool_type : Enums.tools_mode, percent: float)

func _ready() -> void:
	assert(material_type != GlobalEnums.bucket_mode.NONE, "you forgot to set a material on %s!" % get_path())
	assert(required_tool != GlobalEnums.tools_mode.NONE, "you forgot to set a required tool on %s!" % get_path())
	
	dirt_sprite.material = dirt_sprite.material.duplicate()

	# additive blend so repeated brush passes accumulate instead of just overwriting
	var draw_mat := CanvasItemMaterial.new()
	draw_mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	drawing.material = draw_mat

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
	drawing.draw_at(tex_pos, brush_radius, brush_strength)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	_dirty = true

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
	_valid_pixels.clear()
	if dirt_img == null or car_img == null:
		return
	var w := dirt_img.get_width()
	var h := dirt_img.get_height()
	# aim for a roughly fixed sample budget regardless of texture resolution
	var stride : int = max(1, int(sqrt(float(w * h) / 40000.0)))
	for y in range(0, h, stride):
		for x in range(0, w, stride):
			if dirt_img.get_pixel(x, y).a > 0.01 and _car_alpha_at_dirt_pixel(x, y, w, h) > 0.01:
				_valid_pixels.append(Vector2i(x, y))
	dirt_total_pixels = _valid_pixels.size()

func _update_dirt_percentage() -> void:
	if dirt_total_pixels == 0:
		return
	var mask_img := sub_viewport.get_texture().get_image()
	if mask_img == null:
		return
	var data := mask_img.get_data() # PackedByteArray, RGBA8 => 4 bytes/pixel
	var mw := mask_img.get_width()
	var remaining := 0
	for p in _valid_pixels:
		var idx := (int(p.y) * mw + int(p.x)) * 4
		if data[idx] < 220:  # R channel byte, < 0.5 threshold
			remaining += 1
	clean_percentage = 100.0 * float(remaining) / float(dirt_total_pixels)
	dirt_percentage_changed.emit(material_type, required_tool, clean_percentage)
