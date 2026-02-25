extends Node2D

var inventory = {82:{"type":"watering can","count":1}}
var money = 0
var inventory_slots = 20 # Total slots
var max_stack = 999
var held_item = null
var inv_active = true
var selected_slot:int = 1
var selected_item={}

signal inventory_changed
signal mouse_slot_updated

func add_item(item_name: String, amount: int):
	item_name = item_name.to_lower()
	# range(1, 21) will check slots 1 through 20
	for i in range(1, inventory_slots + 1):
		var slot = inventory.get(i)
		if slot and slot["type"] == item_name and slot["count"] < max_stack:
			var can_add = min(amount, max_stack - slot["count"])
			inventory[i]["count"] += can_add
			amount -= can_add
			if amount <= 0: break
			
	if amount > 0:
		for i in range(1, inventory_slots + 1):
			if inventory.get(i) == null:
				var can_add = min(amount, max_stack)
				inventory[i] = {"type": item_name, "count": can_add}
				amount -= can_add
				if amount <= 0: break
	inventory_changed.emit()

func pick_up_slot(slot_index: int):
	if inventory.has(slot_index):
		held_item = inventory[slot_index]
		inventory[slot_index] = null
		inventory_changed.emit()
		mouse_slot_updated.emit()

func drop_into_slot(slot_index: int):
	if held_item == null: return
	var slot_data = inventory.get(slot_index)
	
	if slot_data == null or slot_data["type"] != held_item["type"]:
		var temp = slot_data
		inventory[slot_index] = held_item
		held_item = temp # Swap
	else:
		var space = max_stack - slot_data["count"]
		var transfer = min(space, held_item["count"])
		inventory[slot_index]["count"] += transfer
		held_item["count"] -= transfer
		if held_item["count"] <= 0: held_item = null
		
	inventory_changed.emit()
	mouse_slot_updated.emit()
func _input(event):
	if event is InputEventKey and event.key_label in range(49,57):
		match event.key_label:
			49:
				selected_slot=1
			50:
				selected_slot=2
			51:
				selected_slot=3
			52:
				selected_slot=4
			53:
				selected_slot=5
			54:
				selected_slot=6
			55:
				selected_slot=7
			56:
				selected_slot=8
			57:
				selected_slot=9
		if inventory.get(80+selected_slot)!=null:
			selected_item = inventory[80+selected_slot]
		else:
			selected_item.clear()
		inventory_changed.emit()
