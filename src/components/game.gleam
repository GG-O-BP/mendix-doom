// DOOM game component
// Loads js-dos v8 from CDN and runs the embedded DOOM bundle
// Supports configurable viewport size and fullscreen toggle

import gleam/dynamic
import gleam/option.{Some}
import glendix/classic
import glendix/js/object
import redraw.{type Element}
import redraw/dom/attribute
import redraw/dom/events
import redraw/dom/html
import redraw/ref

const jsdos_js = "https://v8.js-dos.com/latest/js-dos.js"

const jsdos_css = "https://v8.js-dos.com/latest/js-dos.css"

// Embedded in .mpk — served from same origin, no CORS issues
const default_bundle = "/widgets/ggobp/doom/doom.jsdos"

pub fn render(width: String, height: String) -> Element {
  let container_ref = redraw.use_ref()
  let wrapper_ref = redraw.use_ref()
  let dos_ref = redraw.use_ref_(dynamic.nil())
  let ready_ref = redraw.use_ref_(False)
  let #(is_fullscreen, set_fullscreen) = redraw.use_state(False)

  // Listen for fullscreenchange to sync state when user presses Escape
  redraw.use_effect_(
    fn() {
      let assert Some(wrapper) = ref.current(wrapper_ref)
      let doc = object.get(wrapper, "ownerDocument")

      let on_change =
        classic.to_dynamic(fn() {
          let fs_element = object.get(doc, "fullscreenElement")
          case dynamic.classify(fs_element) {
            "Null" | "Undefined" -> set_fullscreen(False)
            _ -> set_fullscreen(True)
          }
        })

      let _ =
        object.call_method(doc, "addEventListener", [
          dynamic.string("fullscreenchange"),
          on_change,
        ])

      fn() {
        let _ =
          object.call_method(doc, "removeEventListener", [
            dynamic.string("fullscreenchange"),
            on_change,
          ])
        Nil
      }
    },
    Nil,
  )

  // Load js-dos
  redraw.use_effect_(
    fn() {
      let assert Some(container) = ref.current(container_ref)
      let doc = object.get(container, "ownerDocument")
      let head = object.get(doc, "head")
      let window = object.get(doc, "defaultView")

      let start = fn() {
        let options =
          object.object([
            #("url", dynamic.string(default_bundle)),
            #("autoStart", dynamic.bool(True)),
          ])
        let dos = object.call_method(window, "Dos", [container, options])
        ref.assign(dos_ref, dos)
        ref.assign(ready_ref, True)
        Nil
      }

      let link =
        object.call_method(doc, "createElement", [dynamic.string("link")])
      let link = object.set(link, "rel", dynamic.string("stylesheet"))
      let link = object.set(link, "href", dynamic.string(jsdos_css))
      let _ = object.call_method(head, "appendChild", [link])

      let _ = case object.has(window, "Dos") {
        True -> start()
        False -> {
          let script =
            object.call_method(doc, "createElement", [dynamic.string("script")])
          let script = object.set(script, "src", dynamic.string(jsdos_js))
          let _ =
            object.set(script, "onload", classic.to_dynamic(fn() { start() }))
          let _ = object.call_method(head, "appendChild", [script])
          Nil
        }
      }

      fn() {
        case ref.current(ready_ref) {
          True -> {
            let dos = ref.current(dos_ref)
            let _ = object.call_method(dos, "stop", [])
            Nil
          }
          False -> Nil
        }
      }
    },
    Nil,
  )

  // Toggle fullscreen via Fullscreen API
  let toggle_fullscreen = fn(_event) {
    let assert Some(wrapper) = ref.current(wrapper_ref)
    let doc = object.get(wrapper, "ownerDocument")

    case is_fullscreen {
      False -> {
        let _ = object.call_method(wrapper, "requestFullscreen", [])
        Nil
      }
      True -> {
        let _ = object.call_method(doc, "exitFullscreen", [])
        Nil
      }
    }
  }

  // Wrapper div — fullscreen target
  html.div(
    [
      attribute.ref(wrapper_ref),
      attribute.class("mendix-doom-wrapper"),
      attribute.style([
        #("position", "relative"),
        #("width", width),
        #("height", height),
      ]),
    ],
    [
      // Game container
      html.div(
        [
          attribute.ref(container_ref),
          attribute.class("mendix-doom-container"),
          attribute.style([#("width", "100%"), #("height", "100%")]),
        ],
        [],
      ),
      // Fullscreen toggle button
      html.button(
        [
          events.on_click(toggle_fullscreen),
          attribute.class("mendix-doom-fullscreen-btn"),
          attribute.style([
            #("position", "absolute"),
            #("top", "8px"),
            #("right", "8px"),
            #("z-index", "10000"),
            #("background", "rgba(0,0,0,0.6)"),
            #("color", "#fff"),
            #("border", "1px solid rgba(255,255,255,0.3)"),
            #("border-radius", "4px"),
            #("padding", "4px 8px"),
            #("cursor", "pointer"),
            #("font-size", "14px"),
          ]),
        ],
        [
          case is_fullscreen {
            True -> html.text("Exit Fullscreen")
            False -> html.text("Fullscreen")
          },
        ],
      ),
    ],
  )
}
