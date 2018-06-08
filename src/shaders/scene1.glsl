vec3 ib_pos = (p + vec3(0.0, 2.0, 3.0 * sin(time)));
vec3 rib_pos = rotateY(time * PI) * ib_pos;

float u = iter_box(rib_pos,
            mix(sphere(rib_pos, 1.0),
                box(ib_pos, vec3(1.0)),
                0.5 + (sin(time) / 2.0)))
    + disp(p, max(cos(time / 2.0), 0.0) * 2.0);

u = smin(terrain(p - vec3(0.0, -3.0, 0.0)), u, 1.0);

return u;
