extends Control

@export var slot_scene: PackedScene = preload("res://Scenes/UI/inventory_slot.tscn")
@onready var grid = $PanelContainer/Background/GridContainer
@onready var game_manager: Node2D = $"../../../GameManager"

const TOTAL_SLOTS = 80
var slots = []

func _ready():
	# 1. Create the empty grid
	for i in range(TOTAL_SLOTS):
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
		slots.append(slot)
		slot.update_slot(null) # Initialize as empty
	
	refresh_ui()

func refresh_ui():
	var inv = game_manager.inventory # {"corn": 12, "wheat": 5}
	var item_keys = inv.keys()
	
	for i in range(TOTAL_SLOTS):
		var slot_index = i + 1
		var slot_ui = slots[i]
		var data = game_manager.inventory.get(slot_index)
		

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
