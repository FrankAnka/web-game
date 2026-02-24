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

func set_growth_stage(stage: int):
	current_stage = stage
	# Update the sprite immediately
	if data and data.growth_stages.size() > current_stage:
		$Sprite2D.texture = data.growth_stages[current_stage]
		
func _update_visuals():
	$Sprite2D.texture = data.growth_stages[current_stage]


func _on_area_2d_input_event( event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed.index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var player = get_tree().get_first_node_in_group("player")
		if player:
			var dist = global_position.distance_to(player.global_position)
			if dist > 192: # Roughly 4 tiles if tiles are 16px
				return
		if current_stage>=data.growth_stages.size()-1:
			harvest()
			
			
func harvest():
	GameManager.add_item(data.plant_name,randi_range(data.min_harvest,data.max_harvest))
	queue_free()			
