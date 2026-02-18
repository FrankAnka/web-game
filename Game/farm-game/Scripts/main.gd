extends Node2D
@onready var player = $Player
@onready var main: Node2D = $"."
@onready var day_manager: DayManager = $DayManager
@onready var planting_manager: Node2D = $PlantingManager
@onready var ground_layer = $Map.ground
@onready var crop_container = $Crops

@export var crop_library: Dictionary = {
	"corn": preload("res://Items/Crops/Resources/corn.tres"),
	
}

#Creating data
func get_full_gamestate() -> Dictionary:
	var state = {
		"time": {
			"current_day": day_manager.current_day,
		},
		"map_data": [],
		"plants": []
	}

	# 1. Save Modified Map Tiles (e.g., Hoed Ground)
	# We only save tiles that are NOT the default (Source ID 0)
	var used_cells = ground_layer.get_used_cells()
	for cell_pos in used_cells:
		var source_id = ground_layer.get_cell_source_id(cell_pos)
		var atlas_coords = ground_layer.get_cell_atlas_coords(cell_pos)
		
		if source_id != 0: # Only save if it's been hoed (Source ID 1+)
			state["map_data"].append({
				"x": cell_pos.x,
				"y": cell_pos.y,
				"id": source_id,
				"atlas": [atlas_coords.x, atlas_coords.y]
			})

	# 2. Save Each Plant
	for crop in $Crops.get_children():
		var crop_pos = ground_layer.local_to_map(crop.global_position)
		state["plants"].append({
			"type": crop.data.plant_name,
			"stage": crop.current_stage,
			"x": crop_pos.x,
			"y": crop_pos.y
		})

	return state

#Sending data

func save_to_database():
	print("Saving to db")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var origin = JavaScriptBridge.eval("window.location.origin") if OS.has_feature("web") else "http://localhost:5173"
	var url = origin + "/api/save-data"
	
	var payload = get_full_gamestate()
	var json_data = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	print("Saving game state...")
	
func _on_request_completed(result, response_code, headers, body):
	print("request completed")
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		print("Data saved successfully: ", response)
	else:
		print("Save failed with code: ", response_code)

func _on_button_button_down() -> void:
	print("save pressed")
	save_to_database()
################################
####Getting Data from web#######'

var farm_data = {}
var is_loading = false

func fetch_game_data():
	print("fething data")
	if is_loading: return # Prevent double-clicking the fetch button
	
	is_loading = true
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_data_received)

	var origin = JavaScriptBridge.eval("window.location.origin") if OS.has_feature("web") else "http://localhost:5173"
	var url = origin + "/api/get-game-state"

	var error = http_request.request(url, [], HTTPClient.METHOD_GET)
	if error != OK:
		is_loading = false
		push_error("HTTP Request failed to initiate.")

func _on_data_received(result, response_code, headers, body):
	print("data recieved")
	is_loading = false
	
	if response_code == 200:
		var json = JSON.new()
		var parse_err = json.parse(body.get_string_from_utf8())
		
		if parse_err == OK:
			var data = json.data
			print("Data received! Rebuilding world...")
			_apply_game_state(data) # This is the function from the previous step
		else:
			print("Error parsing game state JSON.")
	elif response_code == 404:
		print("No save file found. Initializing new game.")
		queue_free()
	else:
		print("Server error: ", response_code)

#applying data
		
func _apply_game_state(data: Dictionary):
	print("apply state")
	# 1. Restore Time
	if data.has("time"):
		day_manager.current_day = data.time.current_day
	# 2. Restore Map
	for tile in data.get("map_data", []):
		var pos = Vector2i(tile.x, tile.y)
		var atlas = Vector2i(tile.atlas[0], tile.atlas[1])
		ground_layer.set_cell(pos, tile.id, atlas)

	# 3. Restore Plantsx
	# First, clear existing plants to avoid duplicates
	for child in $Crops.get_children():
		child.queue_free()

	for p_data in data.get("plants", []):
		var pos = Vector2i(p_data.x, p_data.y)
		var type_key = p_data.type.to_lower() # "corn"
	
		if crop_library.has(type_key):
			var resource = crop_library[type_key]
			var new_crop = planting_manager.plant_crop(pos, resource)
		
			if new_crop:
				new_crop.set_growth_stage(int(p_data.stage))
			else:
				print("Error: Crop type '", type_key, "' not found in crop_library!")

func _on_button_2_button_down() -> void:
	print("fetch pressed")
	fetch_game_data()

#Harvesting/interacting
func _input(event):
	if event.is_action_pressed("right_click"):
		var mouse_tile = ground_layer.local_to_map(get_global_mouse_position())
		
		# 1. Look for a plant at this tile FIRST
		var plant_to_harvest = null
		for crop in crop_container.get_children():
			if ground_layer.local_to_map(crop.global_position) == mouse_tile:
				plant_to_harvest = crop
				break
		
		# 2. Decide: Harvest or Plant?
		if plant_to_harvest:
			if plant_to_harvest.current_stage >= plant_to_harvest.data.growth_stages.size() - 1:
				plant_to_harvest.harvest()
			else:
				print("Plant is still growing!")
		else:
			# Only plant if no crop was found at this tile
			planting_manager.plant_crop(mouse_tile,crop_library["corn"])
		
	
