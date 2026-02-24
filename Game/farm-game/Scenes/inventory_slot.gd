extends PanelContainer

@onready var icon = $Icon
@onready var count_label = $CountLabel
@onready var selection_border = $SelectionBorder

var slot_index: int = -1 # Default to -1 so we know if it's unassigned
	
func _ready():
	# Ensure the border is hidden at the start
	selection_border.visible = false
	
	# Connect the hover signals

func update_slot(item_data = null, amount = 0):
	
	if item_data == null or amount <= 0:
		icon.visible = false
		count_label.visible = false
	else:
		icon.visible = true
		count_label.visible = true
		icon.texture = item_data.icon
		count_label.text = str(amount)

# Connect the 'gui_input' signal from your PanelContainer
func _on_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print("pickup")
			# Start the drag
			GameManager.pick_up_slot(slot_index)
		else:
			# End the drag (Release)
			print("droptime")
			GameManager.drop_into_slot(slot_index)
			
func _on_mouse_entered():
	# Show the indicator
	print("hovering",slot_index)
	selection_border.visible = true
	# Optional: Slightly scale up or brighten the icon
	modulate = Color(1.2, 1.2, 1.2) 

func _on_mouse_exited():
	# Hide the indicator
	selection_border.visible = false
	modulate = Color(1, 1, 1) # Reset brightness


func _get_drag_data(_at_position):
	var slot_data = GameManager.inventory.get(slot_index)
	
	# 1. Only start dragging if there's an item in this slot
	if slot_data == null:
		return null
	
	# 2. Set the "Preview" (The icon that follows the mouse)
	var preview = TextureRect.new()
	preview.texture = icon.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(60, 60) # Size of the drag icon
	preview.modulate.a = 0.7 # Make it slightly see-through
	set_drag_preview(preview)
	
	# 3. Tell GameManager to "pick up" the item
	GameManager.pick_up_slot(slot_index)
	
	# 4. Return anything (not null) to confirm the drag has started
	return slot_data
	
func _can_drop_data(_at_position, _data):
	return true
	
func _drop_data(_at_position, _data):
	# Tell GameManager to "drop" what it's holding into this slot
	GameManager.drop_into_slot(slot_index)
	
