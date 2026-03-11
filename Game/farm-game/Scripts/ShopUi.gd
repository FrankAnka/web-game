extends Control

@export var shop_slot_scene: PackedScene = preload("res://Scenes/UI/inventory_slot.tscn")
@onready var grid = $PanelContainer/VBoxContainer/ShopGrid

func _ready():
	# The UI tunes into the GameManager's radio station
	GameManager.shop_requested.connect(open_shop_window)
	visible = false
	
func open_shop_window(items: Array):
	print("ShopUI: Received request! Opening now.")
	visible = true
	
	# 2. Clear old items
	for child in grid.get_children():
		child.queue_free()
		
	# 3. Populate new items
	for item_data in items:
		var slot = shop_slot_scene.instantiate()
		grid.add_child(slot)
		
		# Set up the slot with item name and price
		slot.setup_shop_item(item_data)

func close_shop():
	visible = false
