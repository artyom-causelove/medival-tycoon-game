extends Node

func isMouseLeftClick(event) -> bool:
	if not event is InputEventMouseButton:
		return false
	if not event.pressed:
		return false
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return false
	return true
