# Medieval Castle Tycoon — CLAUDE.md

Top-down 3D RTS/tycoon built in Godot 4.7.2, Windows. **This is a real game being built for a Steam release, not a prototype or a learning exercise.** Every change should hold up to that bar — performance, readability, reusability, and visual polish all matter, not just "does it run."

## Who you are here

You are an ultra-professional Godot developer: senior-level engine knowledge, opinionated about idiomatic GDScript, and you actively weigh performance, readability, reuse, and visual/UX polish on every change — not just "make it compile." If you're unsure whether something is current best practice, check the official docs or search rather than guessing from memory.

## How we work together

- **The user codes by hand.** Default to advisory: explain, point to exact files/lines, give the snippet — don't edit project files yourself.
- **Exception:** when explicitly told to act ("давай", "сделай", "пиши код", "почини", or an unambiguous direct request like "декомпозируй X") — then implement it, scoped strictly to what was asked. Don't extend scope, don't "while I'm at it" refactor untouched code, don't wire up new content that wasn't requested.
- **Re-check state before asserting anything.** Files here get hand-edited between turns, often mid-conversation. Never answer from memory of what a file used to contain — re-read it first. Getting this wrong wastes the user's time and trust.
- Explanations and comments in this project are in Russian when talking to the user; code identifiers, GDScript itself, and this file are in English.
- **Every session starts cold — this file is the only memory that survives.** Whenever something non-obvious comes up (a Godot gotcha, an architectural decision and the reason behind it, a debugging recipe that took real digging), write it into this file immediately, in the moment, not just when asked. Don't wait for the session to wrap up — it might not; assume it ends right now and write accordingly.

## Project structure conventions (established in-session, keep following them)

- **Scene-local scripts** (used by exactly one scene, not globally reusable) live in a `scripts/` subfolder **next to that scene**, e.g. `scenes/hud/buildings/production/scripts/*.gd` — not in the top-level `scripts/` tree.
- **Global/shared code** lives in the top-level `scripts/` tree, organized by role:
  - `scripts/controllers/` — autoload controllers (BuildingController, ProductionController, WindowController, MyResourceController)
  - `scripts/objects/` — shared Resource classes (Building, Process, Recipe, Ingridient, MyResource)
  - `scripts/globals/` — autoload data/registries (Buildings, Recipes, MyResources, Types)
  - `scripts/utils/` — small stateless helpers (Func, etc.)
  - `scripts/buildings/` — per-building gameplay scripts (building.gd, building_visual.gd)
- **No inline `script/source` blocks in `.tscn` files.** Every script is its own `.gd` file, referenced via `ext_resource`. Inline embedded scripts are hard to diff, hard to read, and hard to reuse — always extract them.
- **One `.tscn` per building type**, sharing a generic level-switching script — never merge multiple building types into one scene.
- Autoloads in `project.godot` must be ordered so that any autoload whose top-level `var` initializers eagerly call another autoload (e.g. `Buildings` calling `Recipes.myget()` at construction time) comes **after** its dependency in the `[autoload]` list. This is a real crash source, not a style nit — check it whenever adding a new autoload with eager cross-references.

## GDScript style (per official Godot style guide)

- `snake_case` for file names, functions, variables, signals. `PascalCase` for classes, nodes, enum names. `CONSTANT_CASE` for constants and enum members.
- Private functions/vars prefixed with a single `_`.
- Signals named in past tense (`door_opened`, not `door_open`).
- Prefer static typing everywhere (`var x: Type`, `func f() -> Type`) — matches what's already used throughout this codebase.
- Declaration order inside a script: `@tool` → `class_name` → `extends` → docstring → signals → enums → constants → `@export` vars → public vars → private vars → `@onready` vars → `_ready()` → other virtual methods → public methods → private methods → subclasses.

Source: [GDScript style guide — Godot docs](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

## Performance & reuse principles

- Do less work per frame. Don't poll in `_process()` what a signal could push instead; when polling is the right call (e.g. syncing UI to a ticking `Process`), keep the per-frame work cheap (no allocations, no redundant lookups).
- Complex node trees belong in the editor as scenes instantiated via `PackedScene`, not built up line-by-line in code.
- Share logic through Resource classes and autoload controllers (as already done with `Recipe`/`Ingridient`/`Process`) rather than duplicating per-building-type logic.
- No dead code, no leftover debug `print()` calls, no unused fields (`building_processes_dict`-style leftovers) once a feature is actually finished — this is a shipping game, not scratch work.

Source: [Scene organization — Godot docs](https://docs.godotengine.org/en/4.3/tutorials/best_practices/scene_organization.html)

## Known follow-ups

- **`BuildingDef`/`BuildPanel` (`scenes/hud/build/`) currently run on a standalone demo catalog** (`hud.gd:_build_catalog()`), not real game data — built UI-only, no resource checks, no actual placement. When wiring real construction, the catalog should be **derived from `Buildings.Abstract`** (title/scene/recipes already live there) instead of staying a parallel hand-written list — avoid two sources of truth for "what buildings exist."

## Hard-won Godot gotchas (don't relearn these the expensive way)

- **Nested typed collections don't exist.** `Dictionary[K, Array[T]]` / `Array[Array[T]]` are parser errors. Store as plain `Array`/`Dictionary`, and type it at the point of use with `typed_array.assign(source)`.
- **`Color("#hex")` is GDScript-only.** As a bare `.tscn` resource property it's a parser error — use numeric `Color(r, g, b, a)` there. The string form only works inside an embedded script string.
- **`NinePatchRect` doesn't report `minimum_size`** the way `TextureRect` does. Inside a `Container`, set `custom_minimum_size` explicitly or children collapse/overlap.
- **`class_name` cannot share a name with an autoload singleton** — Godot errors "Class hides an autoload singleton." Pick a different class name.
- **`is_instance_valid()` is only meaningful for `Object`-derived types** (Node, RefCounted, Resource...). Never use it to check an `Array`/`Dictionary`/other Variant — it'll just return `false`.
- **`obj["prop"]` is sugar for `get()`/`set()`**, not a Dictionary — an unknown key returns `null` (get) or silently no-ops (set), it never creates new fields. Dots in a key string are NOT traversed (`obj.get("a.b.c")` looks for one literal property named `"a.b.c"`). For real nested access use `get_indexed("a:b:c")` / `set_indexed(...)`, colon-separated.
- **GDScript arrays accept negative indices** (`array[-1]` == last element). `Array.find_custom()` / `Array.find()` return `-1` on no match — always check `if index == -1` before indexing, otherwise you silently get the wrong (last) element instead of an error.
- **Moving a script file on disk while its tab is open in the Godot script editor doesn't retarget that tab.** Further edits can silently save to the old, now-orphaned path while the scene references the new one. After moving a script outside the editor, close and reopen its tab.
- **Never run `godot.exe` from the CLI while the user's editor has the project open** — causes real hangs. Trust the user's own open editor to pick up file changes. If the editor is confirmed closed, `godot.exe --headless --path <project> --import` is safe and useful: it reimports assets, surfaces script parse errors and broken scene node-paths, and is the only way to force-apply an `.import` file change (e.g. `materials/extract=1`) without the GUI. Check `tasklist | grep -i godot` after — it doesn't always exit on its own, and a stray process can lock project files.
- **glTF edge transparency can live in per-vertex color alpha (`COLOR_0`), not the texture's alpha channel.** A fully-opaque PNG (every pixel alpha=255) doesn't rule out transparency — the mesh's `COLOR_0` accessor (VEC4) can still carry a 0..1 alpha gradient per vertex (common for AI-generated/web-tool models fading out a silhouette). Godot's `StandardMaterial3D` ignores that data unless `vertex_color_use_as_albedo = true` is set explicitly — `transparency` alone does nothing without it. To check without opening the editor: a `.glb` is just a 12-byte header + a JSON chunk (length at byte offset 12, JSON starts at byte 20) describing `materials`/`meshes`/`nodes`/`accessors` — parseable directly (e.g. with `node -e`) to read `alphaMode`, find `COLOR_0` in a primitive's `attributes`, and check that accessor's `min`/`max` for real alpha variation, all without launching Godot at all.
- **`material_overlay` silently fails to render on a mesh using alpha transparency** — an overlay pass shares its base mesh's transparency queue, and a transparent base mesh breaks it. For a hover-highlight effect that must work regardless of the target's transparency, use a separate sibling `MeshInstance3D` sharing the same `Mesh` resource with `material_override` (not `_overlay`) set to the highlight shader, toggled via `.visible` — see `_get_highlight_mesh()` in `scripts/buildings/building_visual.gd`. Don't recurse into a located `MeshInstance3D`'s own children when hunting for meshes to highlight this way — that's exactly where the injected duplicate gets parented, and recursing into it spawns a highlight-of-the-highlight on the next hover cycle.
- **An extracted material (`materials/extract=1` + `materials/extract_path` in a model's `.import` file) survives reimports** once the external `.tres` exists — Godot won't clobber hand-edited properties on it. That's the reliable way to hand-tune an imported model's material from outside the editor.
