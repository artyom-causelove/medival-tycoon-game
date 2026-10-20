class_name Recipe
extends Resource

var title: String
var needs: float
var result_count: int
var result: MyResource
var ingridients: Array[Ingridient]

func _init(
	_title: String, _ingridients: Array[Ingridient], _result: MyResource, _needs: float,
	_result_count: int = 1
):
	title = _title
	needs = _needs
	result = _result
	ingridients = _ingridients
	result_count = _result_count
