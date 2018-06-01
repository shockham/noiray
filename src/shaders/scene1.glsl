vec3 ib_pos = rotateY(time * PI) * (p + vec3(0.0, 2.0, 3.0 * sin(time)));
float u = iter_box(ib_pos,
            mix(sphere(ib_pos, 1.0),
                box(ib_pos, vec3(1.0)),
                0.5 + (sin(time) / 2.0)))
    + disp(p, max(cos(time / 2.0), 0.0) * 2.0);

u = smin(terrain(p - vec3(0.0, -3.0, 0.0)), u, 1.0);

return u;
