extends Node2D

# 1. Load the generic template and the specific crop data
var crop_scene = preload("res://Scenes/crop_preset.tscn")
var corn_resource = preload("res://Items/Crops/Resources/Corn.tres")

@onready var tile_map: Node2D = $"../Map/Ground"
@onready var crop_container: Node2D = $"../Crops" # A folder node to keep the scene tree clean

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

# Example usage (called when player clicks hoed ground)
func _input(event):
	if event.is_action_pressed("right_click"):
		var mouse_tile = tile_map.local_to_map(get_global_mouse_position())
		plant_crop(mouse_tile, corn_resource)
