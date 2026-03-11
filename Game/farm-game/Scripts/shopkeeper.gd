extends Node2D
@export var shop_items: Array[Dictionary] = [
	{"type": "corn_seed", "price": 10},
	{"type": "watering_can", "price": 50}
]


func _on_click_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			print("Shopkeeper: Sending request to open shop.")
			# We don't care who is listening, we just emit the data
			GameManager.shop_requested.emit(shop_items)
