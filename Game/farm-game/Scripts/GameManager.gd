extends Node2D

var inventory = {1:{"type":"thorneye","count":21},81:{"type":"hoe","count":1},82:{"type":"watering can","count":1},84:{"type":"thorneye seeds","count":3},85:{"type":"shadevine seeds","count":3}}
var money = 100
var max_stack = 999
var held_item = null
var inv_active = true
var selected_slot:int = 1
var selected_item={}
var shop_ui: Control
var held_item_origin_slot: int = -1
@export var tier_req = {1:{1:{"type":"thorneye","count":10},2:{"type":"shadevine","count":8}},2:{1:{"type":"thorneye","count":999}},3:{}} # with the required items to be sold to advance to a higher tier, formatted as tier:{"itemname:"amount,}
var current_tier = 0
var cur_tier_sold = {}

signal inventory_changed
signal mouse_slot_updated
signal money_changed(new_amount)
	
	
func add_item(item_name: String, amount: int):
	item_name = item_name.to_lower()
	
	# Create an array of all valid slot IDs (1-80 for inventory, 81-89 for hotbar)
	var all_slots = []
	for i in range(1, 81):
		all_slots.append(i)
	for i in range(81, 90):
		all_slots.append(i)
		
	# STEP 1: Attempt to stack with existing items first
	for i in all_slots:
		var slot = inventory.get(i)
		if slot and slot["type"] == item_name and slot["count"] < max_stack:
			var can_add = min(amount, max_stack - slot["count"])
			inventory[i]["count"] += can_add
			amount -= can_add
			if amount <= 0: break
			
	# STEP 2: If we still have items left, find the first empty slot
	if amount > 0:
		for i in all_slots:
			if not inventory.has(i) or inventory[i] == null:
				var can_add = min(amount, max_stack)
				inventory[i] = {"type": item_name, "count": can_add}
				amount -= can_add
				if amount <= 0: break
				
	inventory_changed.emit()

func pick_up_slot(slot_index: int):
	if inventory.has(slot_index):
		held_item = inventory[slot_index]
		held_item_origin_slot = slot_index # Remember where it came from!
		inventory.erase(slot_index) # Remove it from the original slot
		inventory_changed.emit()
		mouse_slot_updated.emit()
		
func drop_into_slot(slot_index: int):
	if held_item == null: return
	
	var target_item = inventory.get(slot_index)
	
	# If the slot has an item of the SAME type, try to merge stacks
	if target_item != null and target_item["type"] == held_item["type"]:
		var space = max_stack - target_item["count"]
		var transfer = min(space, held_item["count"])
		
		inventory[slot_index]["count"] += transfer
		held_item["count"] -= transfer
		
		# If we have leftover items that couldn't fit, put them back where they came from
		if held_item["count"] > 0:
			inventory[held_item_origin_slot] = held_item
			
	# If the slot is empty OR has a DIFFERENT item type, perform the swap
	else:
		inventory[slot_index] = held_item # Put held item in new slot
		
		# If there was an item already there, throw it back to the original slot
		if target_item != null:
			inventory[held_item_origin_slot] = target_item
			
	# Clear the cursor completely since the interaction is finished
	held_item = null
	held_item_origin_slot = -1
	
	inventory_changed.emit()
	mouse_slot_updated.emit()		
		
func _input(event):
	if event is InputEventKey and event.key_label in range(49,58):
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
			selected_item={}
		inventory_changed.emit()


 
