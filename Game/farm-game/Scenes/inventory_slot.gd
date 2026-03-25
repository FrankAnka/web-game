extends PanelContainer

@onready var icon = $Icon
@onready var count_label = $CountLabel
@onready var selection_border = $SelectionBorder

var slot_index: int = -1 

func update_slot(item_data = null, amount = 0):
	if item_data == null or amount <= 0:
		icon.visible = false
		count_label.visible = false
		tooltip_text = "" # Clear the tooltip
	else:
		icon.visible = true
		count_label.visible = true
		
		icon.texture = item_data.icon
		count_label.text = str(amount)
		
		# 1. Determine color based on rarity
		var rarity_color = "white"
		if "rarity" in item_data:
			match item_data.rarity:
				1: rarity_color = "white"
				2: rarity_color = "green"
				3: rarity_color = "dodgerblue" # A bright, readable blue
				4: rarity_color = "mediumpurple"
				5: rarity_color = "gold"
				6: rarity_color = "hotpink"
				
		# 2. Get the item's name
		var name_to_display = "Unknown Item"
		if "item_name" in item_data:
			name_to_display = str(item_data.item_name)
		elif "name" in item_data:
			name_to_display = str(item_data.name)
			
		# 3. Build the BBCode formatted tooltip string
		var hover_text = ""
		
		# Make the name bold and apply the dynamic rarity color
		hover_text += "[b][color=" + rarity_color + "]" + name_to_display + "[/color][/b]\n"
			
		# Add the description
		if "description" in item_data and item_data.description != "":
			hover_text += str(item_data.description) + "\n"
			
		# Add the item cost/value in a subtle grey color
		if "cost" in item_data:
			hover_text += "[color=darkgray]Value: " + str(item_data.cost) + " Gold[/color]"
			
		# strip_edges() removes any accidental trailing newlines if description/cost are missing
		tooltip_text = hover_text.strip_edges()
		
	if GameManager.selected_slot+80 == slot_index:
		modulate = Color(0.463, 0.463, 0.463, 1.0)
	else:
		modulate = Color(1, 1, 1)

# ---  SELL ---

func _gui_input(event: InputEvent) -> void:
	# Listen for the right mouse button while hovering this slot
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		var inventory_node = get_tree().get_first_node_in_group("Inventory")
		if inventory_node:
			# Pass the slot index, its screen position, and the item's picture
			inventory_node.attempt_sell(slot_index, global_position, icon.texture)
			
# --- THE BUILT-IN SYSTEM ---

func _get_drag_data(_at_position):
	if GameManager.inv_active:
		var slot_data = GameManager.inventory.get(slot_index)
		if slot_data == null: return null
		
		# Create the visual preview
		var preview = TextureRect.new()
		preview.texture = icon.texture
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.custom_minimum_size = Vector2(60, 60)
		preview.modulate.a = 0.7
		set_drag_preview(preview)
		
		# Tell logic we picked it up
		GameManager.pick_up_slot(slot_index)
		return slot_data # This "data" is passed to _can_drop and _drop

func _can_drop_data(_at_position, _data):
	if GameManager.inv_active:
		return true # Allowed to drop on any slot

func _drop_data(_at_position, _data):
	# This runs automatically when you release the mouse over this slot
	if GameManager.inv_active:
		print("Drop detected on slot: ", slot_index)
		GameManager.drop_into_slot(slot_index)


# --- HOVER VISUALS ---

func _on_mouse_entered():
	selection_border.visible = true
	modulate = Color(1.2, 1.2, 1.2) 

func _on_mouse_exited():
	selection_border.visible = false
	modulate = Color(1, 1, 1)
	

# --- CUSTOM TOOLTIP ---

func _make_custom_tooltip(for_text: String) -> Object:
	# Create a background panel for the tooltip
	var panel = PanelContainer.new()
	
	# Create a RichTextLabel to parse the BBCode
	var rich_text = RichTextLabel.new()
	rich_text.bbcode_enabled = true
	rich_text.text = for_text
	
	# Tell the RichTextLabel to resize itself to fit the text perfectly
	rich_text.fit_content = true
	rich_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	# Add a little margin so the text isn't touching the edge of the panel
	panel.add_theme_stylebox_override("panel", StyleBoxFlat.new())
	var style = panel.get_theme_stylebox("panel")
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9) # Dark grey background
	style.set_content_margin_all(8) # 8 pixels of padding on all sides
	
	# Put the text inside the panel
	panel.add_child(rich_text)
	
	return panel
