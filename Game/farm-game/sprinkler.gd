extends Node2D

func _ready():
	# Connect to the global DayManager signal
	var day_manager = get_tree().get_first_node_in_group("day_manager")

	if day_manager:
		day_manager.day_changed.connect(_on_day_changed)
	
func _on_day_changed(_new_day_number):
	
	var map = get_tree().get_first_node_in_group("map")
	if not map: return
	
	# Assuming ground is the first child (TileMapLayer)
	var ground = map.get_child(0)
	
	# 1. Get the sprinkler's current tile position
	var center_tile = ground.local_to_map(ground.to_local(global_position))
	
	# 2. Loop through the 3x3 area
	# This covers x: -1, 0, 1 and y: -1, 0, 1
	for x in range(-1, 2):
		for y in range(-1, 2):
			var target_tile = center_tile + Vector2i(x, y)
			
			# 3. Call your map's water function
			# Note: We pass the target_tile (Vector2i)
	
			# Fallback if the method name is different or you want to do it manually:
			_manual_water(ground, target_tile)

func _manual_water(ground: TileMapLayer, tile_pos: Vector2i):
	var tile_data = ground.get_cell_tile_data(tile_pos)
	if tile_data and tile_data.get_custom_data("is_hoed") and not tile_data.get_custom_data("is_watered"):
		# Your logic for turning a dry hoed tile into a watered one
		var atlas_coord = ground.get_cell_atlas_coords(tile_pos)
		# Example: Move 6 tiles to the right in the atlas for the 'watered' version
		ground.set_cell(tile_pos, 0, atlas_coord + Vector2i(6, 0))
