shader_type spatial;
render_mode unshaded;
void fragment() {
    float ripple = step(0.88, fract(UV.y * 100.0 + sin(UV.x * 36.0) * 0.14 - TIME * 0.35));
    ALBEDO = mix(vec3(0.16,0.48,0.62), vec3(0.38,0.69,0.75), ripple * 0.5);
}
