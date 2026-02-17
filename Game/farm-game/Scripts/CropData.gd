extends Resource

class_name CropData

@export var plant_name: String
@export var growth_stages:Array[Texture2D]#texture for each stage
@export var days_to_grow:int = 2 #days
@export var sell_price:int = 50
@export var req_water:bool
