extends Node2D
@onready var player = $Player
@onready var main: Node2D = $"."
@onready var day_manager: DayManager = $DayManager
@onready var planting_manager: Node2D = $PlantingManager
@onready var ground_layer = $Map.ground
@onready var crop_container = $Crops
var tools = ["watering can", "hoe","sprinkler"]
var sprinkler_scene = preload("res://Items/Items/Resources/sprinkler.tscn")
@export var crop_library: Dictionary = {
	"thorneye": preload("res://Items/Items/Resources/thorneye.tres"),
	"shadevine":preload("res://Items/Items/Resources/shadevine.tres"),
	
}

#Creating data
func get_full_gamestate() -> Dictionary:
	var state = {
		"time": {
			"current_day": day_manager.current_day,
		},
		"map_data": [],
		"plants": [],
		"inventory": GameManager.inventory,
		"money": GameManager.money,
		"stage":GameManager.current_tier,
		"stage_prog":GameManager.cur_tier_sold
		
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
		var local_pos = ground_layer.to_local(crop.global_position)
		var crop_pos = ground_layer.local_to_map(local_pos)
		
		state["plants"].append({
			"type": crop.data.plant_name,
			"stage": crop.current_stage,
			"x": crop_pos.x,
			"y": crop_pos.y
		})
	print(state)
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
	print(payload)
	var json_data = JSON.stringify(payload)
	var headers = ["Content-Type: application/json"]
	
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_data)
	print("Saving game state...")
	
func _on_request_completed(result, response_code, headers, body):
	print("Request completed. Result code: ", result)
	
	# body is a PackedByteArray, so we convert it to a string to read it
	var response_text = body.get_string_from_utf8()
	var response = JSON.parse_string(response_text)
	
	if response_code == 200:
		print("Data saved successfully: ", response)
	else:
		print("Save failed with HTTP code: ", response_code)

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
	print("Data received. Result code: ", result)
	is_loading = false
	
	if response_code == 200:
		var json = JSON.new()
		var parse_err = json.parse(body.get_string_from_utf8())
		
		if parse_err == OK:
			var data = json.data
			print("Data received! Rebuilding world...")
			_apply_game_state(data)
		else:
			print("Error parsing game state JSON.")
	elif response_code == 404:
		print("No save file found. Initializing new game.")
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
	#tier
	GameManager.current_tier = int(data.get("stage", 0))
	GameManager.cur_tier_sold = data.get("stage_prog", {})
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
	# Restore Inventory and Money
	if data.has("inventory"):
		var raw_inv = data["inventory"]
		var clean_inv = {}
		
		for key in raw_inv.keys():
			# 1. Convert the Key (the slot number) to an int
			var slot_index = int(key)
			
			var slot_data = raw_inv[key]
			
			# 2. Check if the slot actually has data (isn't null)
			if slot_data != null and slot_data is Dictionary:
				# 3. Convert the 'count' inside the slot to an int
				var clean_slot = {
					"type": slot_data["type"],
					"count": int(slot_data["count"]) # Force float to int
				}
				clean_inv[slot_index] = clean_slot
			else:
				clean_inv[slot_index] = null
				
		GameManager.inventory = clean_inv
		
		

func _on_button_2_button_down() -> void:
	print("fetch pressed")
	fetch_game_data()

#Harvesting/interacting
func _unhandled_input(event: InputEvent) -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_tile = ground_layer.local_to_map(ground_layer.to_local(get_global_mouse_position()))

	if event.is_action_pressed("right_click"):
		# Ensure we aren't using the watering can
		if GameManager.selected_item.is_empty() or !tools.has( GameManager.selected_item["type"]):
			var plant_to_harvest = null    
			
			for crop in crop_container.get_children():
				var crop_local_pos = ground_layer.to_local(crop.global_position)
				var crop_tile = ground_layer.local_to_map(crop_local_pos)
				if crop_tile == mouse_tile:
					plant_to_harvest = crop
					break
		
			if plant_to_harvest:
				# Check if the crop is fully grown (last stage of growth)
				if plant_to_harvest.current_stage >= plant_to_harvest.data.growth_stages.size() - 1:
					plant_to_harvest.harvest()
					
			else:
				if planting_manager.can_plant_here(mouse_tile):
				# Only plant if no crop was found at this tile
					if GameManager.selected_item.is_empty() !=true:
						if GameManager.selected_item["type"].contains("seed"):
							var crop_to_plant = GameManager.selected_item["type"].replace("seeds","").replace(" ","")
							planting_manager.plant_crop(mouse_tile,crop_library[crop_to_plant])
							GameManager.selected_item["count"]-=1
							GameManager.inventory_changed.emit()
						else: print("not a seed")
		elif tools.has(GameManager.selected_item["type"]):
			var type=GameManager.selected_item["type"]
			print(type)
			if type == "watering can":
				$Map.water_square()
			if type == "sprinkler":
				# 1. Find the tile coordinates under the mouse
				var local_mouse = ground_layer.to_local(mouse_pos)
				var tile_pos = ground_layer.local_to_map(local_mouse)
				
				# 2. Convert that tile coordinate back to the CENTER of the square
				# map_to_local returns the center of the tile in Godot 4
				var tile_center_local = ground_layer.map_to_local(tile_pos)
				var tile_center_global = ground_layer.to_global(tile_center_local)
				
				# 3. Instantiate the sprinkler
				# (Ensure 'sprinkler_scene' is preloaded at the top of your script)
				var new_sprinkler = sprinkler_scene.instantiate()
				
				# 4. Set position and add to the scene
				new_sprinkler.global_position = tile_center_global
				add_child(new_sprinkler) 
				
				# 5. Update Inventory
				GameManager.selected_item["count"] -= 1
				if GameManager.selected_item["count"] <= 0:
					GameManager.selected_item = {} # Clear item if empty
				
				GameManager.inventory_changed.emit()

	if event.is_action_pressed(("left_click")):
		if GameManager.selected_item!={} and GameManager.selected_item["type"]=="hoe":
				$Map.hoe_square()
				


func _on_button_3_button_down() -> void:
	pass # Replace with function body.
