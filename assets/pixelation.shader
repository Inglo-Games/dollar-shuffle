shader_type canvas_item;

// This shader pixelizes everything on-screen behind the textured node
// Code based on this forum post:
// https://www.geeks3d.com/20101029/shader-library-pixelation-post-processing-effect-glsl/

// Size of low-res pixels
uniform float pix_w;
uniform float pix_h;

void fragment() {
	// Calculate size of low-res pixels relative to screen
	float dx = pix_w * SCREEN_PIXEL_SIZE.x;
	float dy = pix_h * SCREEN_PIXEL_SIZE.y;
	// Get coordinate to take color from
	vec2 coord = vec2(dx*floor(SCREEN_UV.x/dx), dy*floor(SCREEN_UV.y/dy));
	// Set COLOR to color of sampled coordinate
	COLOR = texture(SCREEN_TEXTURE, coord);
}