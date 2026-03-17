// DOOM game component
// Loads js-dos v8 from CDN and runs the embedded DOOM bundle

import gleam/dynamic
import glendix/classic
import glendix/js/object
import glendix/react.{type ReactElement}
import glendix/react/attribute
import glendix/react/hook
import glendix/react/html

const jsdos_js = "https://v8.js-dos.com/latest/js-dos.js"

const jsdos_css = "https://v8.js-dos.com/latest/js-dos.css"

// Embedded in .mpk — served from same origin, no CORS issues
const default_bundle = "/widgets/ggobp/doom/doom.jsdos"

pub fn render() -> ReactElement {
  let container_ref = hook.use_ref(dynamic.nil())
  let dos_ref = hook.use_ref(dynamic.nil())
  let ready_ref = hook.use_ref(False)

  hook.use_effect_once_cleanup(fn() {
    let container = hook.get_ref(container_ref)
    let doc = object.get(container, "ownerDocument")
    let head = object.get(doc, "head")
    let window = object.get(doc, "defaultView")

    // Initialize DOOM via js-dos Dos(element, { url, autoStart })
    let start = fn() {
      let options =
        object.object([
          #("url", dynamic.string(default_bundle)),
          #("autoStart", dynamic.bool(True)),
        ])
      let dos = object.call_method(window, "Dos", [container, options])
      hook.set_ref(dos_ref, dos)
      hook.set_ref(ready_ref, True)
      Nil
    }

    // Load js-dos CSS
    let link =
      object.call_method(doc, "createElement", [dynamic.string("link")])
    let link = object.set(link, "rel", dynamic.string("stylesheet"))
    let link = object.set(link, "href", dynamic.string(jsdos_css))
    let _ = object.call_method(head, "appendChild", [link])

    // Load js-dos JS (skip if already loaded)
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

    // Cleanup: stop emulator on unmount
    fn() {
      case hook.get_ref(ready_ref) {
        True -> {
          let dos = hook.get_ref(dos_ref)
          let _ = object.call_method_0(dos, "stop")
          Nil
        }
        False -> Nil
      }
    }
  })

  html.div(
    [
      attribute.ref(container_ref),
      attribute.class("mendix-doom-container"),
      attribute.style([#("width", "640px"), #("height", "400px")]),
    ],
    [],
  )
}
