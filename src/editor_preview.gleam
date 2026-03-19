// Mendix Studio Pro design view preview
// Uses React.createElement directly to avoid react-dom/client bundle
// that crashes Studio Pro's preview environment

import gleam/dynamic.{type Dynamic}
import glendix/js/object
import glendix/mendix.{type JsProps}
import redraw.{type Element}

// Import React.createElement directly — react is externalized by Rollup
@external(javascript, "react", "createElement")
fn create_element(tag: String, props: Dynamic, children: String) -> Element

/// Studio Pro design view preview - static DOOM placeholder
pub fn preview(props: JsProps) -> Element {
  let width = case mendix.get_string_prop(props, "viewportWidth") {
    "" -> "640px"
    w -> w
  }
  let height = case mendix.get_string_prop(props, "viewportHeight") {
    "" -> "400px"
    h -> h
  }

  let style =
    object.object([
      #("width", dynamic.string(width)),
      #("height", dynamic.string(height)),
      #("background", dynamic.string("#000")),
      #("display", dynamic.string("flex")),
      #("alignItems", dynamic.string("center")),
      #("justifyContent", dynamic.string("center")),
      #("color", dynamic.string("#b91c1c")),
      #("fontSize", dynamic.string("48px")),
      #("fontWeight", dynamic.string("bold")),
      #("fontFamily", dynamic.string("monospace")),
      #("letterSpacing", dynamic.string("8px")),
    ])
  let div_props =
    object.object([
      #("className", dynamic.string("mendix-doom-container")),
      #("style", style),
    ])
  create_element("div", div_props, "DOOM")
}
