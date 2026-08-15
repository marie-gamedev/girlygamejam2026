shader_type canvas_item;
uniform sampler2D mask_texture;
uniform sampler2D car_texture;
uniform vec2 car_rect_pos; // top-left of car, in dirt-sprite UV space (0..1)
uniform vec2 car_rect_size; // size of car, in dirt-sprite UV space (0..1)

void fragment() {
	float mask = texture(mask_texture, UV).r;

	vec2 car_uv = (UV - car_rect_pos) / car_rect_size;
	float car_alpha = 0.0;
	if (car_uv.x >= 0.0 && car_uv.x <= 1.0 && car_uv.y >= 0.0 && car_uv.y <= 1.0) {
		car_alpha = texture(car_texture, car_uv).a;
	}

	COLOR.a *= (1.0 - mask) * car_alpha;
}

//void fragment() {
	//vec2 car_uv = (UV - car_rect_pos) / car_rect_size;
	//float car_alpha = 0.0;
	//if (car_uv.x >= 0.0 && car_uv.x <= 1.0 && car_uv.y >= 0.0 && car_uv.y <= 1.0) {
		//car_alpha = texture(car_texture, car_uv).a;
	//}
	//COLOR = vec4(1.0, 0.0, 0.0, car_alpha); // solid red where car alpha exists
//}