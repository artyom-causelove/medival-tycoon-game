class_name Process
extends Resource

var status: Types.ProcStatus
var recipe: Recipe
var current: float
var funded: bool = false

func _init(
	_recipe: Recipe,
	_status: Types.ProcStatus = Types.ProcStatus.Play,
	_current: int = 0
):
	current = _current
	status = _status
	recipe = _recipe

func tick(delta: float = 1) -> bool:
	if is_running():
		var new_current = current + delta
		current = new_current
		return new_current >= recipe.needs
	return false

func is_running() -> bool:
	return status == Types.ProcStatus.Play

func stop():
	status = Types.ProcStatus.Pause

func resume() -> bool:
	if not fund():
		return false
	status = Types.ProcStatus.Play
	return true

func finish() -> Result:
	current = 0
	funded = false
	return Result.new(recipe.result, recipe.result_count)

func fund() -> bool:
	if funded:
		return true
	if not isEnoughResources():
		return false
	subResources()
	funded = true
	return true

func isEnoughResources() -> bool:
	var allow = true
	for ingridient in recipe.ingridients:
		var resource_count = MyResourceController.myget(ingridient.resource.type)
		if resource_count < ingridient.count:
			allow = false
	return allow

func subResources():
	for ingridient in recipe.ingridients:
		MyResourceController.add(ingridient.resource.type, ingridient.count * -1)



class Result:
	var resource: MyResource
	var count: int
	
	func _init(_resource: MyResource, _count: int):
		resource = _resource
		count = _count
