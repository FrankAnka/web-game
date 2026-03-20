extends CharacterBody2D

@export var possible_items: Array[ItemData]
@export var shop_slots: int = 5

var current_inventory: Array[Dictionary] = []

func _ready():
	generate_inventory()

func generate_inventory():
	var total_weight: int = 0
	for item in possible_items:
		total_weight += item.weight
		
	for i in range(shop_slots):
		var roll = randi_range(1, total_weight)
		var picked_item: ItemData = null
		
		# Weighted random pick
		for item in possible_items:
			roll -= item.weight
			if roll <= 0:
				picked_item = item
				break
				
		# Generate random stock and save it
		var stock_amount = randi_range(picked_item.min_stock, picked_item.max_stock)
		
		# Check if we already picked this item to avoid duplicates (optional, but good practice)
		var already_has = false
		for slot in current_inventory:
			if slot["item"] == picked_item:
				slot["stock"] += stock_amount
				already_has = true
				break
				
		if not already_has:
			current_inventory.append({"item": picked_item, "stock": stock_amount})

# Connect the Area2D's input_event signal to this function
func _on_interact_area_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		get_tree().call_group("ShopUI", "open_shop", current_inventory)
