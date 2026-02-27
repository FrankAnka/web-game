@tool
extends Resource
class_name SeedData

@export var item_name: String
@export var plant_to_place:String
@export var icon:Texture2D
@export var sell_price:int

func _init():
	if resource_path != "":
		item_name = resource_path.get_file().get_basename().replace("_data", "").capitalize()
