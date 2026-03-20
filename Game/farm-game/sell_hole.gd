extends Node2D


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		# Notice the 'self' at the end! This passes the hole's Node to the inventory.
		get_tree().call_group("Inventory", "openClose", "sell", self)
