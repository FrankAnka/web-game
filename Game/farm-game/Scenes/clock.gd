extends RichTextLabel

@onready var day_manager = get_tree().get_first_node_in_group("day_manager")

func _process(_delta):
	if day_manager:
		# 1. Get the current percentage of the day (0.0 to 1.0)
		var p = day_manager.time_percent 
		
		# 2. Calculate total minutes passed in the day
		var total_minutes = int(p * 1440)+360
		total_minutes = total_minutes % 1440
		# 3. Use integer division for hours and modulo for minutes
		var hours = total_minutes / 60
		var minutes = total_minutes % 60
		
		# 4. Format the string to always show two digits (e.g., 09:05)
		text = "%02d:%02d" % [hours, minutes]
