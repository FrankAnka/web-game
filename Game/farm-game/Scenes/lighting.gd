extends CanvasModulate

# Define your colors
const DAY_COLOR = Color(1, 1, 1, 1)            # Normal bright light
const NIGHT_COLOR = Color(0.332, 0.338, 0.68, 1.0) # Dark blue/purple tint
const TRANSITION_TIME = 5.0                    # Seconds it takes to fade

func _ready():
	# Start at Day color
	color = DAY_COLOR
	
	# Connect to your DayManager
	var day_manager = get_tree().get_first_node_in_group("day_manager")
	if day_manager:
		# Assuming your DayManager has signals for these phases
		if day_manager.has_signal("nearing_night"):
			day_manager.nearing_night.connect(_transition_to_night)
		if day_manager.has_signal("nearing_day"):
			day_manager.nearing_day.connect(_transition_to_day)

func _transition_to_night():
	print("day")
	var tween = create_tween()
	tween.tween_property(self, "color", NIGHT_COLOR, TRANSITION_TIME).set_trans(Tween.TRANS_SINE)
	print("The sun is setting...")

func _transition_to_day():
	print("night")
	var tween = create_tween()
	tween.tween_property(self, "color", DAY_COLOR, TRANSITION_TIME).set_trans(Tween.TRANS_SINE)
	print("The sun is rising...")
