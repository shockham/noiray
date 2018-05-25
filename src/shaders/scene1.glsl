vec3 ib_pos = p + vec3(0.0, 0.0, 3.0 * sin(time));
float u = iter_box(ib_pos, sphere(ib_pos, 1.0));

u = min(terrain(p - vec3(0.0, -3.0, 0.0)), u);

return u;
