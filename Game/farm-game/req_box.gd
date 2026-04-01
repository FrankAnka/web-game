extends PanelContainer

@onready var item_icon = $MarginContainer/VBoxContainer/TextureRect
@onready var progress_text = $MarginContainer/VBoxContainer/Label
@onready var visual_bar = $MarginContainer/VBoxContainer/ProgressBar

var target_item_type: String = ""

# Call this when spawning the box at the start of a new tier
func setup_box(item_type: String, amount_needed: int, icon_texture: Texture2D):
	target_item_type = item_type
	item_icon.texture = icon_texture
	visual_bar.max_value = amount_needed
	
	# Initialize visuals to 0
	update_progress(0, amount_needed)

# Call this whenever an item is sold
func update_progress(current_amount: int, amount_needed: int):
	# Update the text label (e.g., "5 / 10")
	progress_text.text = str(current_amount) + " / " + str(amount_needed)
	
	# Animate the progress bar smoothly (optional but satisfying!)
	var tween = create_tween()
	tween.tween_property(visual_bar, "value", current_amount, 0.2).set_trans(Tween.TRANS_SINE)
	
	# Optional: Turn the box green if complete
	if current_amount >= amount_needed:
		modulate = Color(0.5, 1.0, 0.5) # A nice light green tint
