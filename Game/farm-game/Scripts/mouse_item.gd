extends Control

func _process(_delta):
	if GameManager.held_item:
		$".".visible = true
		$".".global_position = get_global_mouse_position()
		$Icon.texture = load("res://assets/icons/" + GameManager.held_item["type"] + ".png")
		$Label.text = str(GameManager.held_item["count"])
	else:
		$".".visible = false
