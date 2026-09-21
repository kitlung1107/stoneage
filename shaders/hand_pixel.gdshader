shader_type spatial;
render_mode depth_test_disabled, unshaded;
varying vec3 local_position;
varying vec3 local_normal;

void vertex() {
	local_position = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec3 cell = floor((local_position + vec3(0.06, 0.16, 0.06)) / 0.0175);
	float tone = fract(sin(dot(cell, vec3(17.13, 93.71, 41.37))) * 43758.5453);
	float step_tone = floor(tone * 4.0) / 3.0;
	vec3 skin = mix(vec3(0.59, 0.36, 0.21), vec3(0.71, 0.47, 0.29), step_tone);
	float light = 0.88 + max(local_normal.y, 0.0) * 0.22 + max(local_normal.z, 0.0) * 0.09;
	ALBEDO = skin * light;
}
