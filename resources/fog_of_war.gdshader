shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled, shadows_disabled, skip_vertex_transform, blend_mix;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

uniform vec2 source_positions[16];
uniform float source_radii[16];
uniform int source_count;
uniform float edge_softness = 6.0;
uniform vec3 fog_color : source_color = vec3(0.04, 0.04, 0.045);

void vertex() {
	POSITION = vec4(VERTEX.xy, 0.0, 1.0);
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	vec4 world = INV_VIEW_MATRIX * vec4(view.xyz, 1.0);

	float visibility = 0.0;
	for (int i = 0; i < source_count; i++) {
		float d = distance(world.xz, source_positions[i]);
		float v = 1.0 - smoothstep(max(source_radii[i] - edge_softness, 0.0), source_radii[i], d);
		visibility = max(visibility, v);
	}

	ALBEDO = fog_color;
	ALPHA = 1.0 - visibility;
}
