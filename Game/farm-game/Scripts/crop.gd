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
	var map = get_tree().get_first_node_in_group("map")
	var ground = map.get_child(0)
	var tile_pos=ground.local_to_map(global_position)
	if data.req_water==true:
		if ground.get_cell_tile_data(tile_pos).get_custom_data("is_watered"):
			days_planted += 1
			var atlas_coord = ground.get_cell_atlas_coords(tile_pos)
			ground.set_cell(tile_pos,0,atlas_coord-Vector2i(6,0))
	
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


			
func harvest():
	GameManager.add_item(data.plant_name,randi_range(data.min_harvest,data.max_harvest))
	queue_free()			
