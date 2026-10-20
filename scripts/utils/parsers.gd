extends Node

func to_roman(num: int) -> String:
	var from = [1, 2, 3]
	var to = ["I", "II", "III"]
	return to[from.find(num)]
