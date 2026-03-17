// Mendix Pluggable Widget - DOOM
// React functional component: fn(JsProps) -> ReactElement

import components/game
import glendix/react.{type JsProps, type ReactElement}

/// Main widget function - called by Mendix runtime as a React component
pub fn widget(_props: JsProps) -> ReactElement {
  game.render()
}
