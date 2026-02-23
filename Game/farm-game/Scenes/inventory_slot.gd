extends PanelContainer

@onready var icon = $Icon
@onready var count_label = $CountLabel

func update_slot(item_data = null, amount = 0):
	
	if item_data == null or amount <= 0:
		icon.visible = false
		count_label.visible = false
	else:
		icon.visible = true
		count_label.visible = true
		icon.texture = item_data.icon
		count_label.text = str(amount)
