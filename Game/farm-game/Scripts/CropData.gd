@tool
extends Resource
class_name CropData

@export var plant_name: String
@export var growth_stages:Array[Texture2D]#texture for each stage
@export var days_to_grow:int = 2 #days
@export var sell_price:int = 50
@export var max_harvest:int =1
@export var min_harvest:int= 10
@export var req_water:bool
@export var icon:Texture2D

func _init():
	if resource_path != "":
		plant_name = resource_path.get_file().get_basename().replace("_data", "").capitalize()
