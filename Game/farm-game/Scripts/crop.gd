extends Node2D


@export var data: CropData
var current_stage: int = 0
var days_planted: int = 0

func _ready():
	# Connect to the global DayManager signal
	# Replace 'get_parent()' with the actual path to your DayManager
	var day_manager = get_tree().get_first_node_in_group("day_manager")
	if day_manager:
		day_manager.day_changed.connect(_on_day_changed)
	
	_update_visuals()

func _on_day_changed(_new_day_number):
	days_planted += 1
	
	# Logic: If the plant should grow every days_to_grow days
	if days_planted % data.days_to_grow == 0:
		if current_stage < data.growth_stages.size() - 1:
			current_stage += 1
			_update_visuals()

func _update_visuals():
	$Sprite2D.texture = data.growth_stages[current_stage]
