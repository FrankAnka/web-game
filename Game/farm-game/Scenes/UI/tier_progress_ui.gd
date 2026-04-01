extends MarginContainer

# Load the box scene you just created
@export var box_scene: PackedScene = preload("res://Scenes/UI/req_box.tscn")

# Grab the HBoxContainer where the boxes will live
@onready var container = $HBoxContainer

func _ready():
	# Build the UI as soon as this scene enters the game
	build_ui()

func build_ui():
	# 1. Clear out any old boxes (essential for when the player levels up to a new tier)
	for child in container.get_children():
		child.queue_free()
		
	# 2. Determine what the next tier is
	var next_tier_index = GameManager.current_tier + 1
	
	# If there are no more tiers, hide the UI or do nothing
	if not GameManager.tier_req.has(next_tier_index):
		visible = false 
		return
		
	var current_requirements = GameManager.tier_req[next_tier_index]
	
	# 3. Loop through the requirements and spawn a box for each one
	for req_key in current_requirements:
		var req_data = current_requirements[req_key]
		var item_type = req_data["type"]
		var amount_needed = req_data["count"]
		
		# Load the item resource to grab its icon picture
		var resource = load("res://Items/Items/Resources/" + item_type + ".tres")
		var icon_texture = resource.icon
		
		# Create the box and add it to the screen
		var box = box_scene.instantiate()
		container.add_child(box)
		
		# Set up the box with its starting data
		box.setup_box(item_type, amount_needed, icon_texture)
		
		# Update the box to show current progress (defaults to 0 if not found)
		var amount_sold = GameManager.cur_tier_sold.get(item_type, 0)
		box.update_progress(amount_sold, amount_needed)

# Call this function from your GameManager or Inventory whenever an item is sold
func update_all_boxes():
	var next_tier_index = GameManager.current_tier + 1
	if not GameManager.tier_req.has(next_tier_index): return
	
	var current_requirements = GameManager.tier_req[next_tier_index]
	
	# Loop through all the boxes currently on screen
	for box in container.get_children():
		# Find the matching requirement data for this specific box
		for req_key in current_requirements:
			var req_data = current_requirements[req_key]
			
			if req_data["type"] == box.target_item_type:
				var amount_needed = req_data["count"]
				var amount_sold = GameManager.cur_tier_sold.get(box.target_item_type, 0)
				
				# Push the updated numbers to the box's UI
				box.update_progress(amount_sold, amount_needed)
