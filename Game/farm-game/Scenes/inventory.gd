extends Control

@export var slot_scene: PackedScene = preload("res://Scenes/UI/inventory_slot.tscn")
@onready var grid = $PanelContainer/Background/GridContainer

const TOTAL_SLOTS = 80
var slots = []

 

func _ready():
	if GameManager.has_signal("inventory_changed"):
		GameManager.inventory_changed.connect(refresh_ui)

	# 1. Create the empty grid
	for i in range(TOTAL_SLOTS):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slot.slot_index = i+1
		slots.append(slot)
		slot.update_slot(null) # Initxialize as empty
	
	refresh_ui()


func refresh_ui():
	for i in range(TOTAL_SLOTS):
		var slot_index = i + 1
		var slot_ui = slots[i]
		var data = GameManager.inventory.get(slot_index)
	
		if data:
			var item_resource = load("res://Items/Crops/Resources/" + data["type"] + ".tres")
			# Pass the dictionary {"type": "corn", "count": 999} to the slot
			slot_ui.update_slot(item_resource, data["count"])
		else:
			slot_ui.update_slot(null, 0)
func _input(event):
	# Toggle visibility with 'I' key
	if event.is_action_pressed("inventory"):
		visible = !visible
		if visible:
			refresh_ui()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and GameManager.held_item != null:
			# Small delay to see if a slot handled it first
			await get_tree().process_frame 
			
			# If the item is STILL held, it means we dropped it in the "void"
			if GameManager.held_item != null:
				return_item_to_inventory()

func return_item_to_inventory():
	# Logic to find the first empty slot and put the held_item back
	GameManager.add_item(GameManager.held_item["type"], GameManager.held_item["count"])
	GameManager.held_item = null
	GameManager.mouse_slot_updated.emit()
