extends HBoxContainer

@onready var icon_rect = $TextureRect
@onready var info_label = $Label
@onready var buy_button = $Button

var slot_data: Dictionary

func setup(data: Dictionary):
	slot_data = data
	var item: ItemData = slot_data["item"]

	icon_rect.texture = item.icon
	update_text()

func update_text():
	var item: ItemData = slot_data["item"]
	var stock = slot_data["stock"]

	info_label.text = "%s | Cost: %s | Stock: %s" % [item.item_name, item.cost, stock]

	# Check both stock AND the player's money from GameManager
	if stock <= 0:
		buy_button.disabled = true
		buy_button.text = "Sold Out"
	elif GameManager.money < item.cost:
		buy_button.disabled = true
		buy_button.text = "Too Expensive"
	else:
		buy_button.disabled = false
		buy_button.text = "Buy"

func _on_button_pressed():
	var item: ItemData = slot_data["item"]
	var stock = slot_data["stock"]
	# Double-check they still have enough money and stock before processing
	if stock > 0 and GameManager.money >= item.cost:
		# 1. Deduct the gold
		GameManager.money -= item.cost
		GameManager.money_changed.emit(GameManager.money)
		# 2. Give the item using your GameManager's built-in function
		# We pass 1 as the amount since they are clicking "Buy" once
		GameManager.add_item(item.item_name, 1)

		# 3. Reduce the shopkeeper's stock
		slot_data["stock"] -= 1

		# 4. Refresh this slot's UI text and button state
		update_text()

		# Tell the rest of the shop to update in case buying this 
		# made the player too poor to buy other items!
		get_tree().call_group("ShopSlot", "update_text")
