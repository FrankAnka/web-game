extends PanelContainer

@onready var icon = $HBoxContainer/Icon

var recipe: RecipeData

func _ready():
	# This lets the mouse trigger the PanelContainer's custom tooltip while still allowing the button to be clicked
	icon.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Connect to GameManager inventory updates
	if GameManager.has_signal("inventory_changed"):
		GameManager.inventory_changed.connect(check_craftable)

func setup(recipe_data: RecipeData):
	recipe = recipe_data
	
	var item_name_text = "Unknown Item"
	var rarity_color = "white"
	
	if recipe.result_item:
		icon.texture_normal = recipe.result_item.icon
		
		# Get the name
		if "item_name" in recipe.result_item:
			item_name_text = recipe.result_item.item_name
		elif "name" in recipe.result_item:
			item_name_text = recipe.result_item.name
			
		# Get the rarity color
		if "rarity" in recipe.result_item:
			match recipe.result_item.rarity:
				1: rarity_color = "white"
				2: rarity_color = "green"
				3: rarity_color = "dodgerblue"
				4: rarity_color = "mediumpurple"
				5: rarity_color = "gold"
				6: rarity_color = "hotpink"
				
	# Build the BBCode hover text
	var hover_text = "[b][color=" + rarity_color + "]" + item_name_text + "[/color][/b]\n\n"
	hover_text += "[color=darkgray]Requires:[/color]\n"
	
	for item_name in recipe.ingredients:
		var amount = recipe.ingredients[item_name]
		hover_text += str(amount) + "x " + item_name.capitalize() + "\n"
	
	# Apply the text strictly to the PanelContainer now
	tooltip_text = hover_text.strip_edges()
	
	check_craftable()

func check_craftable():
	if recipe == null: return
	
	var can_craft = true
	
	for req_item in recipe.ingredients:
		var req_amount = recipe.ingredients[req_item]
		var player_amount = 0
		
		for slot_id in GameManager.inventory:
			var item = GameManager.inventory[slot_id]
			if item != null and item["type"] == req_item.to_lower():
				player_amount += item["count"]
				
		if player_amount < req_amount:
			can_craft = false
			break
			
	icon.disabled = !can_craft
	
	if can_craft:
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		icon.modulate = Color(0.3, 0.3, 0.3, 1.0)

func _on_icon_pressed():
	for req_item in recipe.ingredients:
		var req_amount = recipe.ingredients[req_item]
		remove_item_from_inventory(req_item.to_lower(), req_amount)
		
	var result_name = ""
	if "item_name" in recipe.result_item:
		result_name = recipe.result_item.item_name
	elif "name" in recipe.result_item:
		result_name = recipe.result_item.name
		
	GameManager.add_item(result_name, recipe.result_amount)
	GameManager.inventory_changed.emit()

func remove_item_from_inventory(item_name: String, amount_to_remove: int):
	var slots_to_erase = []
	for slot_id in GameManager.inventory:
		var item = GameManager.inventory[slot_id]
		
		if item != null and item["type"] == item_name:
			if item["count"] > amount_to_remove:
				item["count"] -= amount_to_remove
				amount_to_remove = 0
				break
			else:
				amount_to_remove -= item["count"]
				slots_to_erase.append(slot_id)
				
	for slot_id in slots_to_erase:
		GameManager.inventory.erase(slot_id)



func _make_custom_tooltip(for_text: String) -> Object:
	var panel = PanelContainer.new()
	
	var rich_text = RichTextLabel.new()
	rich_text.bbcode_enabled = true
	rich_text.text = for_text
	rich_text.fit_content = true
	rich_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	var style = panel.get_theme_stylebox("panel")
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.set_content_margin_all(8)
	
	panel.add_child(rich_text)
	
	return panel
