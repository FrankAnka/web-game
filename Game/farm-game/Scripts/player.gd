extends CharacterBody2D

const SPEED = 500.0
func _ready() -> void:
	var day_manager = get_tree().get_first_node_in_group("day_manager")
	if day_manager:
		# Assuming your DayManager has signals for these phases
		if day_manager.has_signal("nearing_night"):
			day_manager.nearing_night.connect(_toggle_light)
		if day_manager.has_signal("nearing_day"):
			day_manager.nearing_day.connect(_toggle_light)
			
			
func _physics_process(_delta):
	var direction = Input.get_vector("Left", "Right", "Up", "Down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

@export var flicker_speed: float = 1.0
@export var energy_variance: float = 0.3  # How much the brightness changes
@export var scale_variance: float = 1.0    # How much the size changes
var target_energy: float = 0.0
var target_scale: float = 0.0

func _process(delta):
	if $PointLight2D.enabled:
		# 1. Create a smooth sine wave based on time
		var time = Time.get_ticks_msec() / 1000.0
		var pulse = sin(time * flicker_speed)
		
		# 2. Add a tiny bit of random jitter for that 'alien/organic' feel
		var jitter = randf_range(-0.05, 0.05)
		
		# 3. Apply fluctuation relative to the current target
		# This ensures that if the light is mid-fade, the flicker scales with it
		$PointLight2D.energy = target_energy + (pulse * energy_variance) + jitter
		$PointLight2D.texture_scale = target_scale + (pulse * scale_variance)

func _toggle_light():
	# Kill any existing tween to prevent conflicts if signals fire rapidly
	var tween = create_tween().set_parallel(true)
	
	# Determine if we are turning ON or OFF based on the current target
	if target_scale < 1.0:
		# Turning ON
		$PointLight2D.enabled = true
		
		# DO NOT set target_energy = 1.0 here manually! 
		# Just let the tween move it from 0.0 to 1.0
		tween.tween_property(self, "target_energy", 1.0, 5.0)
		tween.tween_property(self, "target_scale", 5.0, 5.0).set_trans(Tween.TRANS_SINE)
	else:
		# Turning OFF
		# Again, do NOT set target_energy = 0.0 here manually.
		# The tween will slide it from 1.0 down to 0.0 over 5 seconds.
		tween.tween_property(self, "target_energy", 0.0, 5.0)
		tween.tween_property(self, "target_scale", 0.0, 5.0).set_trans(Tween.TRANS_SINE)
		
		# Only disable the node AFTER the 5-second fade is done
		tween.set_parallel(false).tween_callback(func(): $PointLight2D.enabled = false)
