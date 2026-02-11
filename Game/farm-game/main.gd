extends Node2D

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
