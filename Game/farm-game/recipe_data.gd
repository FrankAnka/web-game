extends Resource
class_name RecipeData


@export var result_item: Resource 
@export var result_amount: int = 1


@export_enum("Tools", "Seeds") var category: String = "Tools"


@export var ingredients: Dictionary = {}
	
