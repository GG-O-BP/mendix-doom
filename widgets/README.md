# widgets/

Mendix widget binding directory. Place `.mpk` files (Mendix widget build artifacts) in this directory to render existing Mendix widgets as React components from Gleam code.

## Usage

### 1. Place `.mpk` files

Copy built Mendix widget `.mpk` files into this directory:

```
widgets/
├── Switch.mpk
├── Badge.mpk
└── README.md
```

### 2. Generate bindings

```bash
gleam run -m glendix/install
```

This automatically:

- Extracts `.mjs` and `.css` from `.mpk` and generates `widget_ffi.mjs`
- Parses `<property>` definitions from `.mpk` XML and generates binding `.gleam` files in `src/widgets/` (existing files are skipped)

### 3. Review auto-generated bindings

For example, placing `Switch.mpk` generates `src/widgets/switch.gleam`:

```gleam
// src/widgets/switch.gleam (auto-generated)
import glendix/mendix
import glendix/react.{type JsProps, type ReactElement}
import glendix/react/attribute
import glendix/widget

/// Render Switch widget - reads properties from props and passes them to the widget
pub fn render(props: JsProps) -> ReactElement {
  let boolean_attribute = mendix.get_prop_required(props, "booleanAttribute")
  let action = mendix.get_prop_required(props, "action")

  let comp = widget.component("Switch")
  react.component_el(
    comp,
    [
      attribute.attribute("booleanAttribute", boolean_attribute),
      attribute.attribute("action", action),
    ],
    [],
  )
}
```

- Required/optional properties are distinguished automatically
- If optional properties exist, `optional_attr` helper and `gleam/option` import are added automatically
- Gleam reserved words (e.g. `type`) are automatically suffixed with `_`
- Generated files can be freely modified as needed

### 4. Use from Gleam

```gleam
import widgets/switch

// Inside a component
switch.render(props)
```

## How it works

- `glendix/widget` module's `widget.component("Name")` imports `.mpk` widgets as React components
- Props are passed via the generic `attribute.attribute(key, value)` function
- Widget names use the `<name>` value from the `.mpk`'s internal XML, and property keys use the original keys from the `.mpk` XML
- Unlike the `binding` module, 1 mpk = 1 component, so `widget.component("Name")` imports it in one call

## Notes

- After adding/removing `.mpk` files, you must run `gleam run -m glendix/install` again
- `widget_ffi.mjs` is auto-generated — do not edit it directly
- Do not write `.mjs` FFI files for `.mpk` widgets manually — use the `widgets/` directory + `glendix/widget`
