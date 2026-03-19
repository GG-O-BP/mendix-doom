// Mendix Pluggable Widget - DOOM
// React functional component: fn(JsProps) -> Element

import components/game
import glendix/mendix.{type JsProps}
import redraw.{type Element}

/// Main widget function - called by Mendix runtime as a React component
pub fn widget(props: JsProps) -> Element {
  let width = mendix.get_string_prop(props, "viewportWidth")
  let height = mendix.get_string_prop(props, "viewportHeight")

  let width = case width {
    "" -> "640px"
    w -> w
  }
  let height = case height {
    "" -> "400px"
    h -> h
  }

  game.render(width, height)
}
