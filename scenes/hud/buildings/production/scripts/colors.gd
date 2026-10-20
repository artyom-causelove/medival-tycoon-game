class_name ProductionColors

## Shared palette for the production window's custom-draw scripts
## (header/footer gradient, frame decor, title cartouche, run button).
## Keep every color used by more than one of those scripts here instead
## of redeclaring it locally — that duplication is what this file replaces.

const DARK_BORDER := Color(0.290196, 0.239216, 0.172549, 1)
const PANEL_GRADIENT_TOP := Color(0.16862746, 0.19607843, 0.20392157, 1)
const PANEL_GRADIENT_BOTTOM := Color(0.14117648, 0.16862746, 0.1764706, 1)

const GOLD_ACCENT := Color(0.5411765, 0.45490196, 0.2509804, 1)
const GOLD_BRIGHT := Color(0.486, 0.396, 0.214, 1)
const RIVET_DARK := Color(0.41960785, 0.3372549, 0.1882353, 1)
const RIVET_LIGHT := Color(0.8784314, 0.79607844, 0.5764706, 1)

const RUN_BG := Color("#262d2f")
const RUN_RING_IDLE := Color("#3a423f")
const RUN_RING_DISABLED := Color("#333a37")
const RUN_RING_ACTIVE := Color("#b08d4f")
const RUN_ICON := Color("#e6c987")
const RUN_ICON_DISABLED := Color("#5c635a")
