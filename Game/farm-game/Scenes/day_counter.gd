extends RichTextLabel

@onready var day_manager = get_tree().get_first_node_in_group("day_manager")

func _process(delta: float) -> void:
	text = "Day"+" "+str(day_manager.current_day)
