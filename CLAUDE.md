# MendixDoom

A project for developing Mendix Pluggable Widgets with Gleam (glendix v3.0). Widgets are implemented using Gleam + [glendix](https://hexdocs.pm/glendix/) + [redraw](https://hexdocs.pm/redraw/) bindings, without JSX.

## Commands

```bash
gleam run -m glendix/install      # Install dependencies (Gleam deps + npm + bindings.json code generation)
gleam run -m glendix/build        # Production build (.mpk output)
gleam run -m glendix/dev          # Dev server (HMR, port 3000)
gleam run -m glendix/start        # Link with Mendix test project
gleam run -m glendix/release      # Release build
gleam run -m glendix/lint         # Run ESLint
gleam run -m glendix/lint_fix     # ESLint auto-fix
gleam run -m glendix/marketplace  # Search/download Marketplace widgets
gleam run -m glendix/define       # Widget property definition TUI editor
gleam test                        # Run tests
gleam format                      # Format code
```

If you add external React packages to bindings.json, install the npm package manually before running `glendix/install`.

## Hard Rules

IMPORTANT: Breaking these rules will break the build or compromise the architecture.

- **Do not write JSX/JS files directly.** All widget logic and UI must be written in Gleam
- **Do not write FFI files (.mjs) in the widget project.** React/Mendix FFI is provided by the glendix package
- **Do not manually manage bridge JS files (src/*.js).** glendix auto-generates/deletes them at build time
- **Use `redraw`/`redraw_dom` for React bindings.** glendix v3.0 delegates React elements, hooks, and events to the `redraw` ecosystem. Do NOT use the removed `glendix/react` module
- **Do not use `lustre` element types for the widget return value.** The widget must return `redraw.Element`. Use `glendix/lustre` bridge functions (`use_tea`, `use_simple`, `render`) to convert lustre elements
- **Do not add `react`/`react-dom` to `dependencies`.** `pluggable-widgets-tools` provides them. Use `overrides`/`resolutions` with exact versions (no caret) to pin React 19
- **Editor config must not use Gleam Lists.** Studio Pro runs via Jint (.NET JS engine) which crashes on Gleam List literals. Use comma-separated Strings instead
- The Gleam compilation output path (`build/dev/javascript/{gleam.toml name}/`) must match the Rollup input path
- Mendix widget names allow only alphabetic characters (a-zA-Z)

## Code Style

- Format with `gleam format`
- Use English comments
- Do not manually edit compiled JS output (`build/`)

## Architecture

Widget entry point signature: `pub fn widget(props: JsProps) -> Element` — identical to a React functional component. `Element` is from `redraw`.

**v3.0 dependency structure:**

```
User code
├── redraw          ← React hooks, components, fragment
├── redraw_dom      ← HTML/SVG tags, attributes, events
├── lustre          ← TEA update/view (optional)
└── glendix
    ├── mendix      ← Mendix API types + props access
    ├── interop     ← External JS components → redraw.Element
    ├── lustre      ← Lustre Element → redraw.Element bridge
    ├── widget      ← .mpk widget components
    ├── binding     ← bindings.json external React components
    ├── classic     ← Classic (Dojo) widgets
    └── js/*        ← JS interop escape hatch
```

**Two rendering paths** (both return `redraw.Element`, freely composable):

| Path | State | View | Best for |
|------|-------|------|----------|
| redraw (direct React) | `redraw.use_state`, `redraw.use_reducer` | `redraw/dom/html` | Simple UI, Mendix value display/edit |
| lustre (TEA bridge) | `update` function (pure) | `lustre/element/html` | Complex state machines, TEA pattern |

**Project structure:**

- `src/mendix_doom.gleam` — Main widget (called by Mendix runtime)
- `src/editor_config.gleam` — Studio Pro property panel configuration
- `src/editor_preview.gleam` — Studio Pro design view preview
- `src/components/` — Shared components
- `src/MendixDoom.xml` — Widget property definitions. Adding `<property>` triggers automatic type generation by the build tool
- `src/package.xml` — Mendix package manifest
- `bindings.json` — External React component binding configuration
- `widgets/` — .mpk widget file bindings (used via `glendix/widget`)

## Build Pipeline

```
src/*.gleam → gleam build → build/dev/javascript/**/*.mjs → Bridge JS (auto-generated) → Rollup → dist/**/*.mpk
```

## Mendix Widget Conventions

- Widget ID: `mendix.mendixdoom.MendixDoom`
- `packagePath: "mendix"` in `package.json` determines the deployment path
- `needsEntityContext="true"` → Requires Mendix data context
- `offlineCapable="true"` → Offline support
- `.mpk` output: `dist/` directory
- Test project: `./tests/testProject`

## Key Concepts

- Mendix props (`JsProps`) are accessed via `mendix.get_prop`/`mendix.get_string_prop`/`mendix.get_prop_required` etc.
- Mendix complex types (`EditableValue`, `ActionValue`, `ListValue`) are opaque types with FFI accessors
- JS `undefined` ↔ Gleam `Option` conversion is handled automatically at the FFI boundary
- HTML elements: `redraw/dom/html` (e.g. `html.div(attrs, children)`)
- HTML attributes: `redraw/dom/attribute` (e.g. `attribute.class("x")`)
- Events: `redraw/dom/events` (e.g. `events.on_click(handler)`)
- Hooks: `redraw` module (e.g. `redraw.use_state(0)`, `redraw.use_effect(fn, deps)`)
- Gleam tuples `#(a, b)` = JS `[a, b]` — directly compatible with `use_state` return values
- Lustre TEA in widget: `glendix/lustre.use_tea(init, update, view)` or `use_simple(init, update, view)`
- Mix rendering: `gl.embed(redraw_element)` inserts redraw into lustre tree; `gl.render(lustre_element, dispatch)` inserts lustre into redraw tree

## Common Mistakes (v3.0)

| Mistake | Correct approach |
|---------|-----------------|
| `import glendix/react` | **Removed.** Use `import redraw` |
| Adding `react`/`react-dom` to `dependencies` | Use `overrides`/`resolutions` only (exact version, no caret) |
| Calling hooks inside conditions | Hooks must always be called at function top level |
| `html.text("")` for empty render | Use `html.none()` |
| `binding.resolve(m(), "pie_chart")` | Keep original JS name: `"PieChart"` |
| Writing `.mjs` FFI for external React components | Use `bindings.json` + `glendix/binding` |
| Writing `.mjs` FFI for `.mpk` widgets | Use `widgets/` + `glendix/widget` |
| Using Gleam Lists in editor config | Use comma-separated Strings (Jint compatibility) |

## Reference Docs

For detailed glendix API and Gleam syntax, see:

- docs/glendix_guide.md — Complete glendix v3.0 guide (redraw/lustre rendering, Mendix API, external components, editor config, JS interop, practical patterns, troubleshooting)
- docs/gleam_language_tour.md — Gleam syntax reference (types, pattern matching, FFI, use keyword, etc.)

## Mendix Documentation Sources

docs.mendix.com is not accessible. Use GitHub raw sources:

- Pluggable Widgets API: `https://github.com/mendix/docs/blob/development/content/en/docs/apidocs-mxsdk/apidocs/pluggable-widgets/`
- Build tools source: `https://github.com/mendix/widgets-tools`
- Official widget examples: `https://github.com/mendix/web-widgets`
