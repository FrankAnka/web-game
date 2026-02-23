extends Node
var inventory = {}
var money = 0
var inventory_slots = 20
var max_stack = 999
signal inventory_changed # Add this at the top

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


	inventory_changed.emit() # Tell the UI to refresh
	sync_to_web()
	
func sync_to_web():
	if OS.has_feature("web"):
		# Push the inventory and money directly to your Svelte stores
		var json_inv = JSON.stringify(inventory)
