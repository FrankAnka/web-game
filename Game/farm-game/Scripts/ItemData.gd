extends Resource
class_name ItemData

@export var item_name: String = "Unknown Item"
@export var cost: int = 10
@export var weight: int = 50 # Higher means more common
@export var min_stock: int = 1
@export var max_stock: int = 5
@export var icon: Texture2D
@export var is_seed:bool = false
@export var is_tool:bool=false
@export var plant_to_place:String
@export var description: String = ""
@export var rarity:int=1 #range of 1-6
