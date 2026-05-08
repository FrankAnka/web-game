extends Node

class_name DayManager

signal day_changed(new_day: int)
signal nearing_night
signal nearing_day
var current_day: int = 1
@export var day_duration: float # Seconds per day
var time_elapsed: float = -0.5
var night =false
var time_percent = 0
func _process(delta):
	time_elapsed += delta
	time_percent = time_elapsed/day_duration
	if snapped(time_elapsed,0.1) == .6*day_duration and night != true:
		nearing_night.emit()
		night=true
	if snapped(time_elapsed,0.1) == 0*day_duration and night == true:
		nearing_day.emit()
		night=false
	if time_elapsed >= day_duration:
		_advance_day()

func _advance_day():
	time_elapsed = 0.0
	current_day += 1
	# Notify every plant in the game that the day has changed
	day_changed.emit(current_day)
