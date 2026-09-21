shader_type canvas_item;
// Key out the green background at runtime while preserving approved skin artwork.
void fragment() {
    vec4 pixel = texture(TEXTURE, UV);
    float skin = smoothstep(0.015, 0.085, pixel.r - pixel.g);
    COLOR = vec4(pixel.rgb, pixel.a * skin);
}
