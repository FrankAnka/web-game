extends PanelContainer

@onready var icon = $Icon
@onready var count_label = $CountLabel
@onready var selection_border = $SelectionBorder

var slot_index: int = -1 

func update_slot(item_data = null, amount = 0):
	if item_data == null or amount <= 0:
		icon.visible = false
		count_label.visible = false
	else:
		icon.visible = true
		count_label.visible = true
		icon.texture = item_data.icon
		count_label.text = str(amount)

# --- THE BUILT-IN SYSTEM ---

func _get_drag_data(_at_position):
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
	return true # Allowed to drop on any slot

func _drop_data(_at_position, _data):
	# This runs automatically when you release the mouse over this slot
	print("Drop detected on slot: ", slot_index)
	GameManager.drop_into_slot(slot_index)

# --- HOVER VISUALS ---

func _on_mouse_entered():
	selection_border.visible = true
	modulate = Color(1.2, 1.2, 1.2) 

func _on_mouse_exited():
	selection_border.visible = false
	modulate = Color(1, 1, 1)
