#version 140

const int MAX_MARCHING_STEPS = 255;
const float MIN_DIST = 0.0;
const float MAX_DIST = 100.0;
const float EPSILON = 0.0001;

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

float terrain(vec3 p) {
    return p.y - (1.0 + sin(p.x)*sin(p.z)) / 2.0;
}

float smin(float a, float b, float k) {
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float disp(vec3 p, float amt) {
    return sin(amt*p.x)*sin(amt*p.y)*sin(amt*p.z);//*sin(time * 3.0);
}

float scene(vec3 p) {
    // start scene body
