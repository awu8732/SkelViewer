// Fragment shader for Qt 6.5 CustomMaterial
uniform vec3 color1;
uniform vec3 color2;
uniform float checkerSize; // number of checks per 1 unit of UV

void MAIN()
{
    // Get UV coordinates
    vec2 uv = MATERIAL_TEXCOORD0.xy * checkerSize;

    // Compute checker pattern
    float check = mod(floor(uv.x) + floor(uv.y), 2.0);

    vec3 col = mix(color1, color2, check);

    BASE_COLOR = vec4(col, 1.0);
}
