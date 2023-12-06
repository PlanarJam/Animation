#version 140

in vec3 wc_frag_normal;        	// fragment normal in world coordinates (wc_)
in vec2 frag_texcoord;			// texture UV coordinates
in vec3 wc_frag_pos;			// fragment position in world coordinates

out vec3 color;			        // pixel colour

uniform sampler2D tex;  		  // 2D texture sampler
uniform samplerCube skybox;		  // Cubemap texture used for reflections
uniform vec3 wc_camera_position;  // Position of the camera in world coordinates

// Combined tone mapping and display encoding
vec3 tonemap(vec3 linearRGB)
{
    float L_white = 0.7; // Controls the brightness of the image

    float inverseGamma = 1./2.2;
    return pow(linearRGB/L_white, vec3(inverseGamma)); // Display encoding - a gamma
}



void main()
{
	vec3 linear_color = vec3(0, 0, 0);

	// Calculate colour using Phong illumination model

	const vec3 light_position = vec3(-1, 3, -1);
    const vec3 light_colour = vec3(0.941, 0.968, 1);
    const vec3 ambient_light = vec3(0.085, 0.085, 0.085);
    const float diffuse_constant = 0.4;
    const float specular_constant = 0.75;
    const vec3 specular_colour = vec3(1, 1, 1);
    const float phong_roughness = 32;

    // Sample the texture and replace diffuse surface colour (C_diff) with texel value
    vec3 diffuse_colour = texture(tex, frag_texcoord).rgb;

	vec3 L = normalize(light_position - wc_frag_pos);
    vec3 V = normalize(wc_camera_position - wc_frag_pos);
    vec3 R = reflect(-L, wc_frag_normal);

    vec3 ambient = diffuse_colour * ambient_light;
    vec3 diffuse = diffuse_colour * diffuse_constant * light_colour * max(0, dot(wc_frag_normal, L));
    vec3 specular = specular_colour * specular_constant * light_colour * pow(max(0, dot(R, V)), phong_roughness);

	linear_color = ambient + diffuse + specular + texture(skybox, reflect(-V, wc_frag_normal)).rgb*0.475;

	color = tonemap(linear_color);
}

