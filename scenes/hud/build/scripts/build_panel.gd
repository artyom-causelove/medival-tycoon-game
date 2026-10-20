class_name BuildPanel
extends Control

signal building_chosen(id: StringName)
signal placement_cancelled()
signal rotate_pressed()

const SECTION_ORDER: Array[StringName] = [
	&"housing", &"farming", &"craft", &"storage", &"defense", &"community"
]
const SECTION_TITLES := {
	&"housing": "ЖИЛЬЁ",
	&"farming": "ПОЛЕ И СКОТ",
	&"craft": "РЕМЕСЛО",
	&"storage": "СКЛАДЫ И ТОРГОВЛЯ",
	&"defense": "ОБОРОНА",
	&"community": "ОБЩИНА",
}

var build_section_packed: PackedScene = preload("res://scenes/hud/build/build_section.tscn")
var build_tile_packed: PackedScene = preload("res://scenes/hud/build/build_tile.tscn")
var cost_font: FontFile = preload("res://fonts/Alegreya-Regular.woff")
var hammer_icon: Texture2D = preload("res://assets/textures/ui/icons/hammer.png")

var catalog: Array[BuildingDef] = []
var open: bool = false
var hovered: StringName = &""
var selected: StringName = &""

@onready var dim: ColorRect = $Dim
@onready var window: PanelContainer = $Window
@onready var close_button: Button = $Close
@onready var list: VBoxContainer = $Window/WindowMargin/Body/List

@onready var info_plate_icon: TextureRect = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/Plate/Icon
@onready var info_plate_thumbnail: ModelThumbnail = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/Plate/Thumbnail
@onready var info_no_model: Label = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/Plate/NoModel
@onready var info_hidden: Label = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/Plate/Hidden
@onready var info_title: Label = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/TitleBlock/Title
@onready var info_section: Label = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/TitleBlock/MetaRow/Section
@onready var info_new_tag: Control = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/TitleBlock/MetaRow/NewTag
@onready var info_desc: Label = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/Desc
@onready var info_price_row: HBoxContainer = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/PriceRow
@onready var info_price_items: HBoxContainer = $Window/WindowMargin/Body/InfoPanel/InfoMargin/InfoContent/PriceRow/PriceItems

@onready var build_button: Button = $Root/Bar/BarMargin/BarContent/BuildButton
@onready var placement_box: HBoxContainer = $Root/Bar/BarMargin/BarContent/Placement
@onready var placement_plate_icon: TextureRect = $Root/Bar/BarMargin/BarContent/Placement/Info/Plate/Icon
@onready var placement_plate_thumbnail: ModelThumbnail = $Root/Bar/BarMargin/BarContent/Placement/Info/Plate/Thumbnail
@onready var placement_name: Label = $Root/Bar/BarMargin/BarContent/Placement/Info/Text/Name
@onready var rotate_button: Button = $Root/Bar/BarMargin/BarContent/Placement/Buttons/RotateButton
@onready var cancel_button: Button = $Root/Bar/BarMargin/BarContent/Placement/Buttons/CancelButton

func _ready() -> void:
	build_button.toggled.connect(_on_build_toggled)
	close_button.pressed.connect(_close)
	dim.gui_input.connect(_on_dim_input)
	rotate_button.pressed.connect(func(): rotate_pressed.emit())
	cancel_button.pressed.connect(_cancel_placement)
	_refresh_bar()

func set_catalog(items: Array[BuildingDef]) -> void:
	catalog = items

func set_stock(_counts: Dictionary) -> void:
	pass # резерв API под будущую проверку ресурсов — в этой версии окно её не делает

func set_placing(id: StringName) -> void:
	selected = id
	_refresh_bar()

func _on_dim_input(event: InputEvent) -> void:
	if Events.isMouseLeftClick(event):
		_close()

func _on_build_toggled(is_open: bool) -> void:
	open = is_open
	if open:
		_rebuild_list()
		if hovered == &"" and not catalog.is_empty():
			_set_hovered(catalog[0].id)
	_refresh_bar()

func _close() -> void:
	if not open:
		return
	open = false
	build_button.set_pressed_no_signal(false)
	_refresh_bar()

func _refresh_bar() -> void:
	var placing := selected != &""
	var window_shown := open and not placing
	build_button.visible = not placing
	placement_box.visible = placing
	dim.visible = window_shown
	window.visible = window_shown
	close_button.visible = window_shown

func _rebuild_list() -> void:
	for child in list.get_children():
		child.queue_free()
	for section_id in SECTION_ORDER:
		var items: Array[BuildingDef] = []
		for def in catalog:
			if def.category == section_id:
				items.append(def)
		if items.is_empty():
			continue
		var section := build_section_packed.instantiate() as BuildSection
		list.add_child(section)
		section.set_title(SECTION_TITLES.get(section_id, ""))
		for def in items:
			var tile := build_tile_packed.instantiate() as BuildTile
			section.tiles.add_child(tile)
			tile.set_data(def)
			tile.hovered.connect(_set_hovered.bind(def.id))
			tile.mouse_exited.connect(tile.mark_seen)
			tile.pressed.connect(_select.bind(def))

func _set_hovered(id: StringName) -> void:
	hovered = id
	var def := _find_def(id)
	if def:
		_apply_info(def)

func _select(def: BuildingDef) -> void:
	if def.hidden:
		return
	selected = def.id
	placement_name.text = def.title
	if def.preview_scene:
		placement_plate_icon.visible = false
		placement_plate_thumbnail.visible = true
		placement_plate_thumbnail.set_model(def.preview_scene, def.preview_camera_direction)
	else:
		placement_plate_icon.visible = true
		placement_plate_thumbnail.visible = false
		placement_plate_icon.texture = def.icon if def.icon else hammer_icon
	_refresh_bar()
	building_chosen.emit(selected)

func _cancel_placement() -> void:
	if selected == &"":
		return
	selected = &""
	_refresh_bar()
	placement_cancelled.emit()

func _find_def(id: StringName) -> BuildingDef:
	for def in catalog:
		if def.id == id:
			return def
	return null

func _apply_info(def: BuildingDef) -> void:
	info_new_tag.visible = def.is_new and not def.hidden
	info_section.text = SECTION_TITLES.get(def.category, "")
	_apply_info_plate(def)
	if def.hidden:
		info_title.text = "Неизвестная постройка"
		info_desc.text = "Откроется по мере развития деревни."
		info_price_row.visible = false
	else:
		info_title.text = def.title
		info_desc.text = def.description
		info_price_row.visible = true
		_apply_price_items(def.price_lines)

func _apply_info_plate(def: BuildingDef) -> void:
	info_plate_icon.visible = false
	info_plate_thumbnail.visible = false
	info_no_model.visible = false
	info_hidden.visible = false
	if def.hidden:
		info_hidden.visible = true
	elif def.preview_scene:
		info_plate_thumbnail.visible = true
		info_plate_thumbnail.set_model(def.preview_scene, def.preview_camera_direction)
	elif def.icon:
		info_plate_icon.visible = true
		info_plate_icon.texture = def.icon
	else:
		info_no_model.visible = true

func _apply_price_items(lines: Array[String]) -> void:
	for child in info_price_items.get_children():
		child.queue_free()
	for line in lines:
		var label := Label.new()
		label.text = line
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", cost_font)
		label.add_theme_font_size_override("font_size", 17)
		label.add_theme_color_override("font_color", BuildColors.TEXT_3RD)
		info_price_items.add_child(label)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if selected != &"":
			_cancel_placement()
			get_viewport().set_input_as_handled()
		elif open:
			_close()
			get_viewport().set_input_as_handled()
	elif selected != &"" and event is InputEventKey and event.pressed and event.keycode == KEY_R:
		rotate_pressed.emit()
