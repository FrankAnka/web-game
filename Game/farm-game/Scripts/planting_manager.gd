extends Node2D

# 1. Load the generic template and the specific crop data
var crop_scene = preload("res://Scenes/Presets/crop_preset.tscn")
var corn_resource = preload("res://Items/Crops/Resources/corn.tres")

@onready var tile_map: Node2D = $"../Map/Ground"
@onready var crop_container: Node2D = $"../Crops" # A folder node to keep the scene tree clean
@onready var player = $"../Player"
func plant_crop(tile_pos: Vector2i, crop_data: CropData):
	# 2. Create an instance of the template
	var new_crop = crop_scene.instantiate()
	# 3. Inject the specific data (Corn, Wheat, etc.)
	new_crop.data = crop_data
	
	# 4. Position it based on the TileMap grid
	# Centering it on the tile:
	var world_pos = tile_map.map_to_local(tile_pos)
	new_crop.global_position = world_pos
	
	# 5. Add it to the world
	crop_container.add_child(new_crop)
	return new_crop


func can_plant_here(mouse_tile):
	if tile_map.get_cell_source_id(mouse_tile)==2:
		print("asdasd	") #can be changed to look for customdata canplant if i add more plantable soilss
		for crop in crop_container.get_children():
			var crop_tile = tile_map.local_to_map(crop.global_position)
			if crop_tile == mouse_tile:
				return false
		return true
	else:
		return false
