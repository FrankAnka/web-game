extends Control

@onready var slot_scene: PackedScene = preload("res://Scenes/UI/inventory_slot.tscn")

@onready var hotbar_grid: GridContainer = $Hotbar/Background/GridContainer
@onready var grid: GridContainer = $PanelContainer/Background/GridContainer
@onready var label: Label = $PanelContainer2/Label


@onready var tools_grid = $TabContainer/Personal
@onready var seeds_grid = $TabContainer/Building

# We will create this scene in the next step!
@export var recipe_ui_scene: PackedScene 

# Load all your .tres recipe files into this array in the inspector
@export var all_recipes: Array[RecipeData] = []

const TOTAL_SLOTS = 80
const hotbar_slots = 9
var slots = []
var current_mode = "normal"
var shop_node: Node2D = null

signal tier_up(new_tier)

func _ready():
	populate_crafting_menu()
	if GameManager.has_signal("inventory_changed"):
		GameManager.inventory_changed.connect(refresh_ui)

	# 1. Create the empty grid
	for i in range(TOTAL_SLOTS):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.slot_index = i+1
		slots.append(slot)
		slot.update_slot(null) # Initxialize as empty
	for i in range(hotbar_slots):
		var slot = slot_scene.instantiate()
		hotbar_grid.add_child(slot)
		slot.slot_index =80+i+1
		slots.append(slot)
		slot.update_slot(null)
	refresh_ui()


func refresh_ui():
	label.text=str(GameManager.money)
	for i in range(TOTAL_SLOTS+hotbar_slots):
		var slot_index = i + 1
		var slot_ui = slots[i]
		var data = GameManager.inventory.get(slot_index)
	
		if data:
			if data["count"]<=0:
				slot_ui.update_slot(null,0)
				GameManager.inventory.erase(slot_index)
				print(GameManager.inventory)
			else:
				print(data["type"])
				var item_resource = load("res://Items/Items/Resources/" + data["type"] + ".tres")
				# Pass the dictionary {"type": "corn", "count": 999} to the slot
				slot_ui.update_slot(item_resource, data["count"])


		else:
			slot_ui.update_slot(null, 0)
			
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		openClose("normal")

	# If we release the mouse and still have a held_item, Godot's 
	# drag-and-drop 'failfed' because it didn't land on a slot.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and GameManager.held_item != null:
			# Wait a tiny bit to see if _drop_data handled it
			await get_tree().process_frame
			if GameManager.held_item != null:
				print("Dropped in void, returning item...")
				return_item_to_inventory()

func return_item_to_inventory():
	if GameManager.held_item != null:
		# Put it exactly back where it came from
		GameManager.inventory[GameManager.held_item_origin_slot] = GameManager.held_item
		
		# Clear the cursor data
		GameManager.held_item = null
		GameManager.held_item_origin_slot = -1
		
		GameManager.inventory_changed.emit()
	# No need to manually emit, add_item does it!


func populate_crafting_menu():
	# Clear out any placeholder slots
	for child in tools_grid.get_children():
		child.queue_free()
	for child in seeds_grid.get_children():
		child.queue_free()
		
	# Spawn a UI slot for every recipe and put it in the right tab
	for recipe in all_recipes:
		var recipe_slot = recipe_ui_scene.instantiate()
		
		# Sort into the correct GridContainer based on the enum we made
		match recipe.category:
			"Tools":
				tools_grid.add_child(recipe_slot)
			"Seeds":
				seeds_grid.add_child(recipe_slot)
				
		#pass the recipe data to the slot so it knows what to display
		recipe_slot.setup(recipe)
		
func attempt_sell(slot_index: int, start_pos: Vector2, item_texture: Texture2D):
	
	if current_mode == "sell":
		var data = GameManager.inventory.get(slot_index)
		var next_tier = GameManager.tier_req[int(GameManager.current_tier) + 1]
		
		if data:
			var resource = load("res://Items/Items/Resources/" + data["type"]+".tres")
			GameManager.money+= resource.cost
			data["count"] -= 1
			if data["count"] <= 0:
				GameManager.inventory.erase(slot_index)
			
			GameManager.inventory_changed.emit()
			
		
			if GameManager.cur_tier_sold.has(data["type"]):
							GameManager.cur_tier_sold[data["type"]] += 1
			else:
				GameManager.cur_tier_sold[data["type"]] = 1
				
			# 2. Check if a next tier actually exists
			if GameManager.tier_req.has(int(GameManager.current_tier) + 1):
				var next_tier_req = GameManager.tier_req[int(GameManager.current_tier) + 1]
				var tier_completed = true
				
				# 3. Verify if current progress meets ALL requirements for the next tier
				for req_key in next_tier_req:
					var req = next_tier_req[req_key]
					var req_type = req["type"]
					var req_amount_needed = req["count"]
					
					# Get amount sold (defaults to 0 if the item hasn't been sold at all yet)
					var amount_sold = GameManager.cur_tier_sold.get(req_type, 0)
					if amount_sold < req_amount_needed:
						tier_completed = false
						break # One requirement failed, so stop checking the rest
				
				# 4. If everything was met, level up the tier!
				if tier_completed:
					GameManager.current_tier+=1
					GameManager.tier_up.emit()
					GameManager.cur_tier_sold.clear() # Reset progress for the new tier!
					get_tree().call_group("Progress", "build_ui")
				else:
					# JUST UPDATE: The tier didn't change, so just update the numbers on the current boxes
					get_tree().call_group("Progress", "update_all_boxes")

			# (money and removing item)
			
			
			# 2. Trigger the visual effect!
			throw_item_into_hole(start_pos, item_texture)

	
func openClose(mode: String, shop: Node2D = null):
	current_mode = mode
	shop_node = shop # Save the hole node so we know where to throw items!
	
	$PanelContainer.visible = !$PanelContainer.visible
	$TabContainer.visible = !$TabContainer.visible
	GameManager.inv_active = !GameManager.inv_active
	if visible: refresh_ui()

func throw_item_into_hole(start_pos: Vector2, item_texture: Texture2D):
	if shop_node == null: return
	
	# 1. Create a temporary visual copy of the item
	var falling_item = TextureRect.new()
	falling_item.texture = item_texture
	falling_item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	falling_item.custom_minimum_size = Vector2(40, 40) # Adjust to match your slot icon size
	falling_item.global_position = start_pos
	
	# Add it to the UI canvas so it renders on top of everything
	add_child(falling_item)
	
	# 2. Get the screen position of the shopkeeper/hole
	# Because the shop is a Node2D in the world, and the UI is on the screen,
	# we use this function to get its exact screen coordinates.
	var target_pos = shop_node.get_global_transform_with_canvas().origin
	
	# 3. Animate it using a Tween
	var tween = create_tween()
	
	# Move it to the hole (takes 0.4 seconds)
	tween.tween_property(falling_item, "global_position", target_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Shrink it to 10% size so it looks like it's falling down deep (runs at the same time)
	tween.parallel().tween_property(falling_item, "scale", Vector2(0.8, 0.8), 0.4)
	
	# Spin it around a bit for fun!
	tween.parallel().tween_property(falling_item, "rotation", 5.0, 0.4)
	
	# Delete the temporary image when the animation finishes
	tween.tween_callback(falling_item.queue_free)
