extends Node

func find(array: Array, to_find: Variant, path: String = "") -> Variant:
	var index = array.find_custom(func(it: Variant):
		if path == "":
			return it == to_find
		return it.get_indexed(path) == to_find
	)
	if index == -1: return null
	return array[index]
