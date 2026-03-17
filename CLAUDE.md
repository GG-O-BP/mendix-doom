# MendixDoom

Embeds the original DOOM (1993) shareware as a playable Mendix widget via js-dos DOSBox emulator. Built with Gleam + [glendix](https://hexdocs.pm/glendix/) bindings, without JSX.

## Commands

```bash
gleam run -m glendix/install      # Install dependencies (Gleam deps + npm)
gleam run -m glendix/build        # Production build (.mpk output)
gleam run -m glendix/dev          # Dev server (HMR, port 3000)
gleam run -m glendix/start        # Link with Mendix test project
gleam run -m glendix/release      # Release build
gleam run -m glendix/lint         # Run ESLint
gleam run -m glendix/lint_fix     # ESLint auto-fix
gleam run -m glendix/marketplace  # Search/download Marketplace widgets
gleam test                        # Run tests
gleam format                      # Format code
```

## Hard Rules

IMPORTANT: Breaking these rules will break the build or compromise the architecture.

- **Do not write JSX/JS files directly.** All widget logic and UI must be written in Gleam
- **Do not write FFI files (.mjs) in the widget project.** React/Mendix FFI is provided by the glendix package
- **Do not manually manage bridge JS files (src/*.js).** glendix auto-generates/deletes them at build time
- **Do not use external Gleam React libraries such as Redraw.** Use only glendix for React bindings
- The Gleam compilation output path (`build/dev/javascript/{gleam.toml name}/`) must match the Rollup input path
- Mendix widget names allow only alphabetic characters (a-zA-Z)

## Code Style

- Format with `gleam format`
- Use English comments
- Do not manually edit compiled JS output (`build/`)

## Architecture

Widget entry point signature: `pub fn widget(props: JsProps) -> ReactElement` — identical to a React functional component.

- `src/mendix_doom.gleam` — Main widget entry point (calls `game.render()`)
- `src/editor_config.gleam` — Studio Pro property panel configuration
- `src/editor_preview.gleam` — Studio Pro design view preview (static DOOM placeholder)
- `src/components/game.gleam` — Core DOOM game component (js-dos integration, DOSBox emulation)
- `src/Doom.xml` — Widget property definitions. Adding `<property>` triggers automatic type generation by the build tool
- `src/package.xml` — Mendix package manifest
- `src/assets/doom.jsdos` — Embedded DOOM shareware bundle for js-dos
- `src/ui/Doom.css` — Widget styling
- `rollup.config.mjs` — Custom Rollup config (copies doom.jsdos asset to build output)
- `widgets/` — .mpk widget file bindings (used via `glendix/widget`)

## Build Pipeline

```
src/*.gleam → gleam build → build/dev/javascript/**/*.mjs → Bridge JS (auto-generated) → Rollup → dist/**/*.mpk
```

Rollup also copies `src/assets/doom.jsdos` into the output so the DOOM bundle is included in the `.mpk`.

## Mendix Widget Conventions

- Widget ID: `ggobp.doom.Doom`
- `packagePath: "ggobp"` in `package.json` determines the deployment path
- `needsEntityContext="false"` → Does not require Mendix data context
- `offlineCapable="false"` → Requires network (js-dos CDN)
- `.mpk` output: `dist/` directory
- Test project: `./tests/testProject`
- DOOM bundle served at: `/widgets/ggobp/doom/doom.jsdos`

## Key Concepts

- Mendix props (`JsProps`) are accessed via `mendix.get_prop`/`mendix.get_string_prop` etc.
- Mendix complex types (`EditableValue`, `ActionValue`, `ListValue`) are opaque types with FFI accessors
- JS `undefined` ↔ Gleam `Option` conversion is handled automatically at the FFI boundary
- HTML attributes use the Attribute list API: `[attribute.class("x"), event.on_click(handler)]`
- Gleam tuples `#(a, b)` = JS `[a, b]` — directly compatible with `useState` return values
- js-dos v8 is loaded dynamically from CDN (`https://v8.js-dos.com/latest/`)

## Reference Docs

For detailed glendix API and Gleam syntax, see:

- docs/glendix_guide.md — Complete React/Mendix bindings guide (elements, Hooks, events, Mendix types, practical patterns, troubleshooting)
- docs/gleam_language_tour.md — Gleam syntax reference (types, pattern matching, FFI, use keyword, etc.)

## Mendix Documentation Sources

docs.mendix.com is not accessible. Use GitHub raw sources:

- Pluggable Widgets API: `https://github.com/mendix/docs/blob/development/content/en/docs/apidocs-mxsdk/apidocs/pluggable-widgets/`
- Build tools source: `https://github.com/mendix/widgets-tools`
- Official widget examples: `https://github.com/mendix/web-widgets`
