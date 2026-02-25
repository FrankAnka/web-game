@tool
extends Resource
class_name ToolData

@export var name: String

@export var sell_price:int = 50

@export var icon:Texture2D

func _init():
	if resource_path != "":
		name = resource_path.get_file().get_basename().replace("_data", "").capitalize()
