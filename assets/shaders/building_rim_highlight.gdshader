shader_type spatial;
render_mode blend_add, unshaded, depth_draw_opaque, cull_back;

uniform vec4 rim_color : source_color = vec4(1.0, 0.82, 0.3, 1.0);
uniform float rim_power : hint_range(0.5, 8.0) = 3.0;
uniform float rim_strength : hint_range(0.0, 5.0) = 1.5;

void fragment() {
	float fresnel = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), rim_power);
	ALBEDO = rim_color.rgb;
	ALPHA = fresnel * rim_strength * rim_color.a;
}
