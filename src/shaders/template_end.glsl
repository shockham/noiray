    // end scene body
}

float shortest_dist(vec3 eye, vec3 marchingDirection, float start, float end) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {
        float dist = scene(eye + depth * marchingDirection);
        if (dist < EPSILON) {
			return depth;
        }
        depth += dist;
        if (depth >= end) {
            return end;
        }
    }
    return end;
}

vec3 ray_dir(float fieldOfView, vec2 size, vec2 fragCoord) {
    vec2 xy = fragCoord - size / 2.0;
    float z = size.y / tan(radians(fieldOfView) / 2.0);
    return normalize(vec3(xy, -z));
}

vec3 estimate_normal(vec3 p) {
    return normalize(vec3(
        scene(vec3(p.x + EPSILON, p.y, p.z)) - scene(vec3(p.x - EPSILON, p.y, p.z)),
        scene(vec3(p.x, p.y + EPSILON, p.z)) - scene(vec3(p.x, p.y - EPSILON, p.z)),
        scene(vec3(p.x, p.y, p.z  + EPSILON)) - scene(vec3(p.x, p.y, p.z - EPSILON))
    ));
}

vec3 phong_contrib(vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye,
                          vec3 lightPos, vec3 lightIntensity) {
    vec3 N = estimate_normal(p);
    vec3 L = normalize(lightPos - p);
    vec3 V = normalize(eye - p);
    vec3 R = normalize(reflect(-L, N));

    float dotLN = dot(L, N);
    float dotRV = dot(R, V);

    if (dotLN < 0.0) {
        // Light not visible from this point on the surface
        return vec3(0.0, 0.0, 0.0);
    }

    if (dotRV < 0.0) {
        // Light reflection in opposite direction as viewer, apply only diffuse
        // component
        return lightIntensity * (k_d * dotLN);
    }
    return lightIntensity * (k_d * dotLN + k_s * pow(dotRV, alpha));
}

float soft_shadow(vec3 ro, vec3 rd, float mint, float maxt, float k ) {
    float res = 1.0;
    for(float t=mint; t < maxt;) {
        float h = scene(ro + rd*t);
        if( h<0.001 )
            return 0.0;
        res = min( res, k*h/t );
        t += h;
    }
    return res;
}

float calc_AO(vec3 pos, vec3 nor) {
	float occ = 0.0;
    float sca = 1.0;
    for(int i=0; i<5; i++) {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = scene(aopos);
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec3 lighting(vec3 k_a, vec3 k_d, vec3 k_s, float alpha, vec3 p, vec3 eye) {
    const vec3 ambientLight = 0.5 * vec3(1.0, 1.0, 1.0);
    vec3 color = ambientLight * k_a;

    float occ = calc_AO(p, estimate_normal(p));

    vec3 light1Pos = vec3(4.0 * sin(time),
                          5.0,
                          4.0 * cos(time));
    vec3 light1Intensity = vec3(0.4, 0.4, 0.4);

    color += phong_contrib(k_d, k_s, alpha, p, eye,
                                  light1Pos,
                                  light1Intensity);
    color = mix(color,  color * occ * soft_shadow(p, normalize(light1Pos), 0.02, 5.0, 16.0), 0.5);

    color = mix(color, vec3(rand(v_tex_coords * time)), 0.1);

    return color;
}

void main() {
    vec3 cam_pos = cam_pos;
    cam_pos.y = 1.0;
    cam_pos.y = terrain(cam_pos);

	vec3 dir = ray_dir(45.0, resolution, v_tex_coords * resolution);

    vec3 v_dir = (inverse(modelview_matrix) * vec4(dir, 0.0)).xyz;

    float dist = shortest_dist(cam_pos, v_dir, MIN_DIST, MAX_DIST);

    // The closest point on the surface to the eyepoint along the view ray
    vec3 p = cam_pos + dist * v_dir;

    if (dist > MAX_DIST - EPSILON) {
        // Didn't hit anything
        frag_output = vec4(rand(p.xy + time) * 0.02);
		return;
    }

    vec3 K_a = vec3(0.2, 0.2, 0.2);
    vec3 K_d = vec3(0.2, 0.2, 0.2);
    vec3 K_s = vec3(1.0, 1.0, 1.0);
    float shininess = 20.0;

    vec3 color = lighting(K_a, K_d, K_s, shininess, p, cam_pos);

    frag_output = vec4(color, 1.0);
}