vec3 d1 = vec3(sin(time), 0.0, 0.0);
vec3 d2 = vec3(-sin(time), 0.0, 0.0);

float u = smin(
    max(-sphere(p, abs(sin(time * 3.0))), box(p, vec3(1.0, 2.0, 0.5))),
    max(-sphere(p + d1, abs(sin(time * 3.0))), box(p + d1, vec3(1.0, 2.0, 0.5))), 0.2);

u = smin(
    u,
    max(-sphere(p + d2, abs(sin(time * 3.0))), box(p + d2, vec3(1.0, 2.0, 0.5))), 0.2);

u = max(-box(p + vec3(0.0, -3.5, 0.0), vec3(2.0, 2.0, 2.0)) + disp(p, 5.0), u);

u = min(terrain(p - vec3(0.0, -3.0, 0.0)), u);

return u;
