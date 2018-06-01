#version 140

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;
const float PI = 3.1415926;

uniform vec2 resolution;
uniform vec3 cam_pos;
uniform float time;
uniform mat4 projection_matrix;
uniform mat4 modelview_matrix;

in vec2 v_tex_coords;

out vec4 frag_output;

float sphere(vec3 p, float s) {
    return length(p) - s;
}

float box(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float plane(vec3 p) {
	return p.y;
}

float iter_box(vec3 p, float init_d) {
   float d = init_d;

   float s = 1.0;
   for(int m=0; m<4; m++) {
      vec3 a = mod( p*s, 2.0 )-1.0;
      s *= 3.0;
      vec3 r = abs(1.0 - 3.0*abs(a));

      float da = max(r.x,r.y);
      float db = max(r.y,r.z);
      float dc = max(r.z,r.x);
      float c = (min(da,min(db,dc))-1.0)/s;

      d = max(d,c);
   }

   return d;
}

vec2 hash(vec2 x) {
    const vec2 k = vec2( 0.3183099, 0.3678794 );
    x = x*k + k.yx;
    return -1.0 + 2.0*fract( 16.0 * k*fract( x.x*x.y*(x.x+x.y)) );
}

float noised(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    vec2 u = f*f*f*(f*(f*6.0-15.0)+10.0);

    vec2 ga = hash(i + vec2(0.0,0.0));
    vec2 gb = hash(i + vec2(1.0,0.0));
    vec2 gc = hash(i + vec2(0.0,1.0));
    vec2 gd = hash(i + vec2(1.0,1.0));

    float va = dot(ga, f - vec2(0.0,0.0));
    float vb = dot(gb, f - vec2(1.0,0.0));
    float vc = dot(gc, f - vec2(0.0,1.0));
    float vd = dot(gd, f - vec2(1.0,1.0));

    return va + u.x*(vb-va) + u.y*(vc-va) + u.x*u.y*(va-vb-vc+vd);
}

float terrain(vec3 p) {
    return p.y - noised(p.xz * 0.5);
}

float smin(float a, float b, float k) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float disp(vec3 p, float amt) {
    return sin(amt*p.x)*sin(amt*p.y)*sin(amt*p.z);//*sin(time * 3.0);
}

mat3 rotateY(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat3(
        vec3(c, 0, s),
        vec3(0, 1, 0),
        vec3(-s, 0, c)
    );
}

float scene(vec3 p) {
    // start scene body
