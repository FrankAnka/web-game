extends Control

@export var slot_scene: PackedScene = preload("res://Scenes/UI/inventory_slot.tscn")

@onready var hotbar_grid: GridContainer = $Hotbar/Background/GridContainer
@onready var grid: GridContainer = $PanelContainer/Background/GridContainer

const TOTAL_SLOTS = 80
const hotbar_slots = 9
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
	for i in range(hotbar_slots):
		var slot = slot_scene.instantiate()
		hotbar_grid.add_child(slot)
		slot.slot_index =80+i+1
		slots.append(slot)
		slot.update_slot(null)
	refresh_ui()


func refresh_ui():
	for i in range(TOTAL_SLOTS+hotbar_slots):
		var slot_index = i + 1
		var slot_ui = slots[i]
		var data = GameManager.inventory.get(slot_index)
	
		if data:
			if data["type"] != "watering can":
				var item_resource = load("res://Items/Crops/Resources/" + data["type"] + ".tres")
				# Pass the dictionary {"type": "corn", "count": 999} to the slot
				slot_ui.update_slot(item_resource, data["count"])
			else:
				var item_resource = load("res://Items/Tools/Resources/" + data["type"] + ".tres")
				slot_ui.update_slot(item_resource, data["count"])

		else:
			slot_ui.update_slot(null, 0)
			
func _input(event):
	if event.is_action_pressed("inventory"):
		$PanelContainer.visible = !$PanelContainer.visible
		$TabContainer.visible = !$TabContainer.visible
		GameManager.inv_active = !GameManager.inv_active
		if visible: refresh_ui()

	# If we release the mouse and still have a held_item, Godot's 
	# drag-and-drop 'failed' because it didn't land on a slot.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and GameManager.held_item != null:
			# Wait a tiny bit to see if _drop_data handled it
			await get_tree().process_frame
			if GameManager.held_item != null:
				print("Dropped in void, returning item...")
				return_item_to_inventory()

func return_item_to_inventory():
	print(GameManager.held_item)
	GameManager.add_item(GameManager.held_item["type"], GameManager.held_item["count"])
	GameManager.held_item = null
	# No need to manually emit, add_item does it!
