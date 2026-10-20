extends CanvasLayer

const SUN_RADIUS := 83.0
const DIAL_CENTER := Vector2(96, 96)

enum Season { SUMMER, AUTUMN, WINTER, SPRING }

@export var current_season: Season = Season.SUMMER

@onready var sun_icon: TextureRect = $DialRoot/SunIcon
@onready var pointer_brass: TextureRect = $DialRoot/PointerBrass
@onready var time_label: Label = $DialRoot/TimeLabel
@onready var day_label: Label = $DialRoot/DayLabel
@onready var debug_resources_label: Label = $DebugResourcesLabel
@onready var build_panel: BuildPanel = $BuildPanel

var day_night: DayNightCycle

func _ready() -> void:
	day_night = get_tree().get_first_node_in_group("day_night_cycle") as DayNightCycle
	var season_angle_deg := float(current_season) * 90.0
	pointer_brass.rotation_degrees = season_angle_deg
	_place_on_ring(sun_icon, season_angle_deg)
	build_panel.set_catalog(_build_catalog())

func _process(_delta: float) -> void:
	if day_night == null:
		day_night = get_tree().get_first_node_in_group("day_night_cycle") as DayNightCycle
		return

	var hour := 6.0 + (day_night.angle / TAU) * 24.0
	hour = fmod(hour, 24.0)
	var hour_int := int(hour)
	var minute_int := int((hour - float(hour_int)) * 60.0)
	time_label.text = "%02d:%02d" % [hour_int, minute_int]
	day_label.text = "ДЕНЬ %d" % day_night.day_number
	_update_debug_resources()

func _update_debug_resources() -> void:
	var lines: Array[String] = []
	for type in MyResourceController.available:
		lines.append("%s - %d" % [MyResources.myget(type).title, MyResourceController.available[type]])
	debug_resources_label.text = "\n".join(lines)

func _place_on_ring(icon: TextureRect, angle_deg: float) -> void:
	var angle_rad := deg_to_rad(angle_deg)
	var icon_pos := DIAL_CENTER + Vector2(sin(angle_rad), -cos(angle_rad)) * SUN_RADIUS
	icon.position = icon_pos - icon.size / 2.0

## Полный каталог из RULES.md/README.md (40 построек, 6 разделов). Строится из
## плоской таблицы, а не 40 вызовов BuildingDef.new(...) — так легче сверять
## с исходной markdown-таблицей и не запутаться в позиционных аргументах.
## Только 4 постройки (hut/mill/lumber/beds) имеют иконку/модель — у остальных
## 36 на плитке будет первая буква названия (см. build_tile.gd).
func _build_catalog() -> Array[BuildingDef]:
	var rows := [
		# --- Жильё ---
		{"id": &"hut", "title": "Хижина", "section": &"housing", "wood": 20, "stone": 4, "plot": 3.0,
			"desc": "Жильё для одной семьи. Даёт двух жителей и место под запасы.",
			"icon": "build_hut.png", "model": "houses/house_1.glb", "cam": Vector3(1, 0.8, 1)},
		{"id": &"izba", "title": "Изба", "section": &"housing", "wood": 34, "stone": 8, "plot": 3.2,
			"desc": "Дом на три семьи с печью и двором."},
		{"id": &"master", "title": "Дом мастера", "section": &"housing", "wood": 40, "stone": 14, "plot": 3.2,
			"desc": "Жильё ремесленника. Мастер работает в соседней мастерской."},
		{"id": &"manor", "title": "Усадьба", "section": &"housing", "wood": 70, "stone": 40, "plot": 4.4,
			"desc": "Дом старосты с подворьем. Поднимает порядок в деревне.", "hidden": true},
		{"id": &"dugout", "title": "Землянка", "section": &"housing", "wood": 6, "stone": 0, "plot": 2.2,
			"desc": "Временное жильё на одну семью. Дёшево, но холодно зимой."},
		# --- Поле и скот ---
		{"id": &"beds", "title": "Грядка", "section": &"farming", "wood": 4, "stone": 0, "plot": 6.6,
			"desc": "Пять гряд под одну культуру. Сажать можно только в её сезон.",
			"icon": "build_beds.png", "model": "plot/beds_plot5.glb", "cam": Vector3(0.6, 1.4, 0.6)},
		{"id": &"orchard", "title": "Сад", "section": &"farming", "wood": 12, "stone": 0, "plot": 4.0,
			"desc": "Яблони и груши. Первый урожай на третий год."},
		{"id": &"apiary", "title": "Пасека", "section": &"farming", "wood": 10, "stone": 0, "plot": 2.6,
			"desc": "Ульи дают мёд и воск. Ставится рядом с садом или полем."},
		{"id": &"cowshed", "title": "Хлев", "section": &"farming", "wood": 28, "stone": 4, "plot": 3.8,
			"desc": "Коровы дают молоко. Нужен выпас рядом."},
		{"id": &"coop", "title": "Курятник", "section": &"farming", "wood": 8, "stone": 0, "plot": 2.2,
			"desc": "Куры несут яйца каждый день."},
		{"id": &"pigsty", "title": "Свинарник", "section": &"farming", "wood": 14, "stone": 2, "plot": 3.0,
			"desc": "Свиньи едят остатки и дают мясо к зиме."},
		{"id": &"fisher", "title": "Рыбацкая хижина", "section": &"farming", "wood": 14, "stone": 2, "plot": 2.8,
			"desc": "Рыбак ловит рыбу. Ставится на берегу."},
		{"id": &"hunter", "title": "Охотничий домик", "section": &"farming", "wood": 16, "stone": 2, "plot": 2.8,
			"desc": "Охотник добывает дичь и шкуры в лесу."},
		# --- Ремесло ---
		{"id": &"mill", "title": "Мельница", "section": &"craft", "wood": 30, "stone": 12, "plot": 3.6,
			"desc": "Мелет зерно в муку. Ставится на открытом месте рядом с полями.",
			"icon": "build_mill.png", "model": "windmill/windmill_1.glb", "cam": Vector3(1, 0.8, 1)},
		{"id": &"lumber", "title": "Лесопилка", "section": &"craft", "wood": 16, "stone": 6, "plot": 9.6,
			"desc": "Распиливает брёвна на доски. Работает быстрее рядом с лесом.",
			"icon": "build_lumber.png"}, # модели лесопилки в проекте нет — остаётся плоская иконка
		{"id": &"bakery", "title": "Пекарня", "section": &"craft", "wood": 24, "stone": 16, "plot": 3.0,
			"desc": "Печёт хлеб из муки. Хлеб сытнее зерна.", "new": true},
		{"id": &"smithy", "title": "Кузница", "section": &"craft", "wood": 20, "stone": 24, "plot": 3.0,
			"desc": "Куёт инструменты из железа."},
		{"id": &"pottery", "title": "Гончарня", "section": &"craft", "wood": 18, "stone": 10, "plot": 2.8,
			"desc": "Лепит и обжигает посуду из глины."},
		{"id": &"weaver", "title": "Ткацкая", "section": &"craft", "wood": 26, "stone": 4, "plot": 3.0,
			"desc": "Ткёт полотно из льна и шерсти."},
		{"id": &"tannery", "title": "Дубильня", "section": &"craft", "wood": 18, "stone": 6, "plot": 3.0,
			"desc": "Выделывает кожу из шкур. Ставится подальше от домов."},
		{"id": &"quarry", "title": "Каменоломня", "section": &"craft", "wood": 20, "stone": 0, "plot": 3.8,
			"desc": "Добывает камень. Ставится у скал."},
		{"id": &"charcoal", "title": "Угольная яма", "section": &"craft", "wood": 6, "stone": 4, "plot": 2.4,
			"desc": "Пережигает дрова в уголь для кузницы."},
		{"id": &"brewery", "title": "Пивоварня", "section": &"craft", "wood": 26, "stone": 12, "plot": 3.2,
			"desc": "Варит пиво из ячменя.", "hidden": true},
		# --- Склады и торговля ---
		{"id": &"granary", "title": "Амбар", "section": &"storage", "wood": 30, "stone": 6, "plot": 3.4,
			"desc": "Хранит зерно и муку. Защищает от сырости и мышей.", "new": true},
		{"id": &"warehouse", "title": "Склад", "section": &"storage", "wood": 36, "stone": 8, "plot": 3.8,
			"desc": "Хранит брёвна, камень и инструменты."},
		{"id": &"cellar", "title": "Погреб", "section": &"storage", "wood": 10, "stone": 12, "plot": 2.4,
			"desc": "Хранит овощи, молоко и пиво в холоде."},
		{"id": &"market", "title": "Рынок", "section": &"storage", "wood": 30, "stone": 10, "plot": 4.4,
			"desc": "Жители берут здесь еду и товары, не заходя на склад."},
		{"id": &"stable", "title": "Конюшня", "section": &"storage", "wood": 34, "stone": 6, "plot": 4.0,
			"desc": "Лошади ускоряют перевозку грузов."},
		{"id": &"pier", "title": "Пристань", "section": &"storage", "wood": 30, "stone": 4, "plot": 3.6,
			"desc": "Принимает торговые лодки. Ставится на берегу.", "hidden": true},
		# --- Оборона ---
		{"id": &"palisade", "title": "Частокол", "section": &"defense", "wood": 6, "stone": 0, "plot": 2.4,
			"desc": "Секция стены из заострённых брёвен."},
		{"id": &"gate", "title": "Ворота", "section": &"defense", "wood": 16, "stone": 6, "plot": 2.6,
			"desc": "Проход в частоколе. Закрываются на ночь."},
		{"id": &"tower", "title": "Сторожевая башня", "section": &"defense", "wood": 28, "stone": 12, "plot": 2.6,
			"desc": "Дозорный замечает врагов издалека."},
		{"id": &"barracks", "title": "Казарма", "section": &"defense", "wood": 40, "stone": 20, "plot": 4.0,
			"desc": "Обучает ополченцев.", "hidden": true},
		{"id": &"archery", "title": "Стрельбище", "section": &"defense", "wood": 18, "stone": 0, "plot": 3.6,
			"desc": "Лучники тренируются и становятся метче."},
		# --- Община ---
		{"id": &"well", "title": "Колодец", "section": &"community", "wood": 4, "stone": 10, "plot": 2.0,
			"desc": "Даёт воду домам вокруг. Снижает риск пожара.", "new": true},
		{"id": &"chapel", "title": "Часовня", "section": &"community", "wood": 30, "stone": 30, "plot": 3.2,
			"desc": "Место для молитвы и праздников.", "hidden": true},
		{"id": &"tavern", "title": "Таверна", "section": &"community", "wood": 34, "stone": 10, "plot": 3.6,
			"desc": "Жители отдыхают и пьют пиво."},
		{"id": &"bath", "title": "Баня", "section": &"community", "wood": 22, "stone": 8, "plot": 2.8,
			"desc": "Жители моются раз в неделю и реже болеют."},
		{"id": &"townhall", "title": "Ратуша", "section": &"community", "wood": 60, "stone": 40, "plot": 4.4,
			"desc": "Сердце деревни. Открывает новые постройки.", "hidden": true},
		{"id": &"square", "title": "Площадь", "section": &"community", "wood": 0, "stone": 20, "plot": 4.4,
			"desc": "Место для ярмарок и сборов."},
	]
	var items: Array[BuildingDef] = []
	for row in rows:
		var def := BuildingDef.new()
		def.id = row["id"]
		def.title = row["title"]
		def.category = row["section"]
		def.description = row["desc"]
		def.price_lines = _cost_lines(row.get("wood", 0), row.get("stone", 0))
		def.footprint = row["plot"]
		def.hidden = row.get("hidden", false)
		def.is_new = row.get("new", false)
		if row.has("icon"):
			def.icon = load("res://assets/textures/ui/icons/%s" % row["icon"])
		if row.has("model"):
			def.preview_scene = load("res://assets/models/%s" % row["model"])
			def.preview_camera_direction = row["cam"]
		items.append(def)
	return items

func _cost_lines(wood: int, stone: int) -> Array[String]:
	var lines: Array[String] = []
	if wood > 0:
		lines.append("%d брёвен" % wood)
	if stone > 0:
		lines.append("%d камней" % stone)
	return lines
