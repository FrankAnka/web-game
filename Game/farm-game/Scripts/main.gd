extends Node2D
@onready var player = $Player
func save_game_data( score: int):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	# 1. Get the origin (e.g., http://localhost:5173)
	var origin = ""
	if OS.has_feature("web"):
		# Get the actual URL of the browser window
		origin = JavaScriptBridge.eval("window.location.origin")
	else:
		# Fallback for local testing in the Godot Editor
		origin = "http://localhost:5173"

	# 2. Build the absolute URL
	var full_url = origin + "/api/save-data"

	# 3. Prepare data and headers
	var body = JSON.stringify({ "score": score})
	var headers = ["Content-Type: application/json"]

	# 4. Send the request
	var error = http_request.request(full_url, headers, HTTPClient.METHOD_POST, body)

	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _on_request_completed(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	if response_code == 200:
		print("Data saved successfully: ", response)
	else:
		print("Save failed with code: ", response_code)
		


func _on_button_button_down() -> void:
	save_game_data(get_child(0).money)
	

################################
####Getting Data from web#######'




var farm_data = {}


func fetch_game_data():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_data_received)

	# 1. Resolve URL
	var origin = ""
	if OS.has_feature("web"):
		origin = JavaScriptBridge.eval("window.location.origin")
	else:
		origin = "http://localhost:5173"

	# 2. Add query parameters if needed (e.g., ?user=Player1)
	var url = origin + "/api/get-game-state"

	# 3. Send GET request (Note: No body/payload for GET)
	var error = http_request.request(url, [], HTTPClient.METHOD_GET)

	if error != OK:
		push_error("Could not initialize GET request.")

func _on_data_received(result, response_code, headers, body):
	if response_code != 200:
		print("Failed to fetch data. Server returned: ", response_code)
		return

	# 4. Parse the large JSON block
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())

	if error == OK:
		farm_data = json.data
		_apply_game_state()
	else:
		print("JSON Parse Error: ", json.get_error_message())

func _apply_game_state():
	# Here you unpack your "large" data
	print("Loaded Score: ", farm_data.get("score", 0))
	player.money = farm_data.get("score",0)
	

####Todo:
#change upload to upload gamestate and not score
#Verify that upload/download work toghether
#understand the code


func _on_button_2_button_down() -> void:
	fetch_game_data()
