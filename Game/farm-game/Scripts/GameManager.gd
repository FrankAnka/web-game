extends Node
var inventory = {}
var money = 0
var inventory_slots = 20
var max_stack = 999
var held_item = null
@onready var inventory_ui: Control = $"../CanvasLayer/UI/InventoryUI"

signal inventory_changed # Add this at the top
signal mouse_slot_updated
	
func add_item(item_name: String, amount: int):
	item_name=item_name.to_lower()
	for i in range(1,inventory_slots):#If it refuses to add items to the last slot add a +1 here
		var slot = inventory.get(i)
		if slot and slot["type"] == item_name and slot["count"] < max_stack:
			var can_add = min(amount,max_stack-slot["count"])
			inventory[i]["count"] += can_add
			amount-=can_add
			if amount<=0: break
	if amount > 0:
		for i in range(1,inventory_slots):	#If it refuses to add items to the last slot add a +1 here
			if inventory.get(i)==null:
				var can_add = min(amount,max_stack)
				inventory[i] = {"type":item_name,"count":can_add}
				amount -= can_add
				if amount <=0: break
	inventory_changed.emit() # Tell the UI to refreshfunc add_item(item_name:String, amount:int):


func pick_up_slot(slot_index: int):
	print("pickupslot")
	if inventory.get(slot_index) != null:
		held_item = inventory[slot_index]
		inventory[slot_index] = null
		inventory_changed.emit()
		mouse_slot_updated.emit()

func drop_into_slot(slot_index: int):
	if held_item == null: return
	var slot_data = inventory.get(slot_index)
	
	# If empty or different type, swap
	if slot_data == null or slot_data["type"] != held_item["type"]:
		print("dropping or swapping with",slot_index)
		var temp = slot_data
		inventory[slot_index] = held_item
		held_item = temp # This handles swapping if you drop on another item
	else:
		# Same type? Stack them
		print("stacking with",slot_index)
		var space = max_stack - slot_data["count"]
		var transfer = min(space, held_item["count"])
		inventory[slot_index]["count"] += transfer
		held_item["count"] -= transfer
		if held_item["count"] <= 0: held_item = null
		
	inventory_changed.emit()
	mouse_slot_updated.emit()

func cancel_drag():
	if held_item != null:
		# Put the item back in the first available slot
		add_item(held_item["type"], held_item["count"])
		held_item = null
		inventory_changed.emit()
