shader_type canvas_item;

varying flat vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	COLOR = COLOR == modulate ? vec4(1) : vec4(modulate.rgb, COLOR.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
