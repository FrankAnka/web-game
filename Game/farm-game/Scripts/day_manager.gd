extends Node

class_name DayManager

signal day_changed(new_day: int)

var current_day: int = 1
@export var day_duration: float = 10.0 # Seconds per day
var time_elapsed: float = 0.0

func _process(delta):
	time_elapsed += delta
	if time_elapsed >= day_duration:
		_advance_day()

func _advance_day():
	time_elapsed = 0.0
	current_day += 1
	# Notify every plant in the game that the day has changed
	day_changed.emit(current_day)
