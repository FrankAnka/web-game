extends Node2D

# 1. Load the generic template and the specific crop data
var crop_scene = preload("res://Scenes/Presets/crop_preset.tscn")


@onready var tile_map: Node2D = $"../Map/Ground"
@onready var crop_container: Node2D = $"../Crops" # A folder node to keep the scene tree clean
@onready var player = $"../Player"
func plant_crop(tile_pos: Vector2i, crop_data: CropData):
	var new_crop = crop_scene.instantiate()
	new_crop.data = crop_data

	# 1. Get the local position inside the TileMap
	var local_pos = tile_map.map_to_local(tile_pos)

	# 2. Convert that local position to a GLOBAL position
	new_crop.global_position = tile_map.to_global(local_pos)

	crop_container.add_child(new_crop)
	return new_crop


func can_plant_here(mouse_tile):
	if tile_map.get_cell_tile_data(mouse_tile):
		if tile_map.get_cell_tile_data(mouse_tile).get_custom_data("is_hoed"):
			 #can be changed to look for customdata canplant if i add more plantable soilss
			for crop in crop_container.get_children():
				var crop_tile = tile_map.local_to_map(crop.global_position)
				if crop_tile == mouse_tile:
					return false
			return true
		else:
			return false
