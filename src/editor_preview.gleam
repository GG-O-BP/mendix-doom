// Mendix Studio Pro design view preview
// Shows a static DOOM placeholder in the designer

import glendix/react.{type JsProps, type ReactElement}
import glendix/react/attribute
import glendix/react/html

/// Studio Pro design view preview - static DOOM placeholder
pub fn preview(_props: JsProps) -> ReactElement {
  html.div(
    [
      attribute.class("mendix-doom-container"),
      attribute.style([
        #("width", "640px"),
        #("height", "400px"),
        #("background", "#000"),
        #("display", "flex"),
        #("align-items", "center"),
        #("justify-content", "center"),
        #("color", "#b91c1c"),
        #("font-size", "48px"),
        #("font-weight", "bold"),
        #("font-family", "monospace"),
        #("letter-spacing", "8px"),
      ]),
    ],
    [react.text("DOOM")],
  )
}
