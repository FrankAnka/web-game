extends CanvasLayer

@export var shop_slot_scene: PackedScene = preload("res://Scenes/UI/shop_slot_ui.tscn")
@onready var slot_container = $Panel/ScrollContainer/VBoxContainer
@onready var panel = $Panel
@onready var close_button = $Panel/CloseButton # Grabs your new button

func _ready():
	panel.hide()
	# Connects the button's click signal directly to the close_shop function
	close_button.pressed.connect(close_shop)

func open_shop(inventory_data: Array):
	# Clear out old slots
	for child in slot_container.get_children():
		child.queue_free()
		
	# Populate new slots
	for data in inventory_data:
		var new_slot = shop_slot_scene.instantiate()
		slot_container.add_child(new_slot)
		new_slot.setup(data)
	
	panel.show()

func close_shop():
	panel.hide()
# This function listens for keyboard/mouse inputs
func _input(event):
	# Only listen for the Tab key if the shop is actually open
	if panel.visible:
		if event is InputEventKey and event.keycode == KEY_TAB and event.pressed:
			close_shop()
			
			# This line stops the Tab key input from traveling any further.
			# It prevents your player's inventory from accidentally opening
			# at the exact same time the shop closes!
			get_viewport().set_input_as_handled()
