extern crate caper;

use caper::game::*;
use caper::imgui::Ui;
use caper::input::Key;
use caper::shader;
use caper::types::DefaultTag;
use caper::utils::handle_fp_inputs;

macro_rules! load_shaders {
    ($game:expr, $($s:expr),*) => {
        $(


            $game.renderer
                .shaders
                .add_post_shader(
                    &$game.renderer.display,
                    $s,
                    shader::post::gl330::VERT,
                    concat!(include_str!("shaders/template.glsl"),
                            include_str!(concat!("shaders/",$s,".glsl")),
                            include_str!("shaders/template_end.glsl"))
                )
                .unwrap();
        )*
    }
}

fn main() {
    // crate an instance of the game struct
    let mut game = Game::<DefaultTag>::new();

    load_shaders!(game, "frag", "scene1");

    game.renderer.post_effect.current_shader = "frag";

    loop {
        // run the engine update
        let status = game.update(
            |_: &Ui| {},
            |g: &mut Game<DefaultTag>| -> UpdateStatus {
                // update the first person inputs
                handle_fp_inputs(&mut g.input, &mut g.cams[0]);

                if g.input.keys_down.contains(&Key::T) {
                    g.renderer.post_effect.current_shader = "frag";
                }

                if g.input.keys_down.contains(&Key::Y) {
                    g.renderer.post_effect.current_shader = "scene1";
                }

                // quit
                if g.input.keys_down.contains(&Key::Escape) {
                    return UpdateStatus::Finish;
                }

                UpdateStatus::Continue
            },
        );

        if let UpdateStatus::Finish = status {
            break;
        }
    }
}
