extern crate caper;

use caper::game::*;
use caper::imgui::Ui;
use caper::input::Key;
use caper::shader;
use caper::types::DefaultTag;
use caper::utils::handle_fp_inputs;

use std::str;

macro_rules! load_shaders {
    ($game:expr, $($s:expr),*) => {
        $(
            $game.renderer
                .shaders
                .add_post_shader(
                    &$game.renderer.display,
                    $s,
                    shader::post::gl330::VERT,
                    str::from_utf8(include_bytes!(concat!("shaders/",$s,".glsl"))).unwrap(),
                )
                .unwrap();
        )*
    }
}

fn main() {
    // crate an instance of the game struct
    let mut game = Game::<DefaultTag>::new();

    {
        load_shaders!(game, "frag");
    }

    game.renderer.post_effect.current_shader = "frag";

    loop {
        // run the engine update
        let status = game.update(
            |_: &Ui| {},
            |g: &mut Game<DefaultTag>| -> UpdateStatus {
                // update the first person inputs
                handle_fp_inputs(&mut g.input, &mut g.cams[0]);

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
