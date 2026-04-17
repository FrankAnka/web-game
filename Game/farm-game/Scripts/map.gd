extends Node2D

@onready var ground=$Ground
@onready var player=$"../Player"




func hoe_square():
	var mouse_pos = get_global_mouse_position()

	var local_mouse_pos = ground.to_local(mouse_pos)

	var tile_pos = ground.local_to_map(local_mouse_pos)

	var player_local_pos = ground.to_local(player.global_position)
	var player_tile = ground.local_to_map(player_local_pos)
		# Check if the tile can be hoed
	var tile_data = ground.get_cell_tile_data(tile_pos)
	
	# 1. Get player's tile position
	
	# 2. Calculate distance in tiles
	# .length() gives the Euclidean distance (a circle radius)
	var distance = (tile_pos - player_tile).length()
	
	if distance <= 3.0:
		
		if tile_data and tile_data.get_custom_data("can_hoe"):
				ground.set_cells_terrain_connect([tile_pos],0, 2,true)

func water_square():
	var mouse_pos = get_global_mouse_position()

	var local_mouse_pos = ground.to_local(mouse_pos)

	var tile_pos = ground.local_to_map(local_mouse_pos)
	var tile_data = ground.get_cell_tile_data(tile_pos)
	var player_local_pos = ground.to_local(player.global_position)
	var player_tile = ground.local_to_map(player_local_pos)

	var distance = (tile_pos - player_tile).length()
	
	if distance <= 3.0 and GameManager.selected_item["type"] == "watering can" and tile_data.get_custom_data("is_hoed")and tile_data.get_custom_data("is_watered")==false:
		if tile_data:
			ground.set_cell(tile_pos,0, ground.get_cell_atlas_coords(tile_pos)+Vector2i(6,0))
