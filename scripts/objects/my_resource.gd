class_name MyResource
extends Resource

var icon: Texture2D
var title: String
var type: Types.MyResource

func _init(_title: String, _icon: Texture2D, _type: Types.MyResource):
	title = _title
	type = _type
	icon = _icon
