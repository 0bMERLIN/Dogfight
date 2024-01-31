shader_type spatial;

void vertex() {
    // Pass the vertex position to the fragment shader
    // in view space
    vec3 view_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Calculate the distance from the object's center (assumed to be at the origin)
    float distance = length(view_pos);

    // Pass the distance to the fragment shader
    // The shader will use this distance to determine the color
    UV.x = distance;
}

void fragment() {
    // Define the colors for the blaster bolt (white and red)
    vec3 white_color = vec3(1.0, 1.0, 1.0);
    vec3 red_color = vec3(1.0, 0.0, 0.0);

    // Get the distance from the center of the object
    float distance_to_center = UV.x;

    // Interpolate between white and red based on the distance
    vec3 final_color = mix(white_color, red_color, smoothstep(0.8, 1.0, distance_to_center));

    // Output the final color
    ALBEDO = final_color;
    ALPHA = smoothstep(0.8, 1.0, distance_to_center);
}
