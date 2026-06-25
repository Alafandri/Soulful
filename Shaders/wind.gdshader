shader_type canvas_item;

uniform float wind_start_threshold : hint_range(0,1) = 0.1;
uniform float wind_end_threshold : hint_range(0,10) = 2;
uniform float wind_end_threshold_2 : hint_range(0,2) = .1;
uniform float wind_strength : hint_range(0,1.5) = .2;
uniform float wind_speed : hint_range(.2,5) = 1;
uniform float scale = 2.0;

float random(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	VERTEX *= scale;
}

void fragment() {
	vec2 uv = (UV - REGION_RECT.xy) / REGION_RECT.zw;

	float tile_random = random(REGION_RECT.xy);
	float phase = tile_random * 6.283185;
	float tile_speed = wind_speed * mix(0.8, 1.2, tile_random);
	float tile_strength = wind_strength * mix(0.75, 1.25, random(REGION_RECT.xy + 17.0));
	float tile_curve = mix(0.85, 1.15, random(REGION_RECT.xy + 43.0));

	float dist_amount = smoothstep(
		wind_start_threshold * pow(1.0 - uv.y, wind_end_threshold * tile_curve),
		wind_end_threshold_2,
		1.0 - uv.y
	);

	uv.x += sin(TIME * tile_speed + phase)
		* pow(1.0 - uv.y, wind_end_threshold * tile_curve)
		* dist_amount
		* tile_strength;

	COLOR = texture(TEXTURE, uv * REGION_RECT.zw + REGION_RECT.xy);

	vec2 border = step(vec2(0.0), uv) * step(uv, vec2(1.0));
	COLOR.a *= border.x * border.y;
}