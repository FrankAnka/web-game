extends Node2D

@onready var ground=$Ground


func _input(event):
	if event.is_action_pressed("left_click"):
		var mouse_pos = get_global_mouse_position()
		var tile_pos = ground.local_to_map(mouse_pos)
		
		# Check if the tile can be hoed
		var tile_data = ground.get_cell_tile_data(tile_pos)
		if tile_data and tile_data.get_custom_data("can_hoe"):
			ground.set_cell(tile_pos,1, Vector2i(0, 0))
