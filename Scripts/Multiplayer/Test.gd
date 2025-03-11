extends Node

var url = 'https://api.jsonbin.io/v3/b/67cff6538960c979a56f6aaa/latest'
var url2 = 'https://api.jsonbin.io/v3/b/67cff6538960c979a56f6aaa/'

func get_stuff():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request(url,["X-Master-Key: $2a$10$LdepC4OqSmfPDRCSaG1nwOpcgC.y4Jaz7c8vSXgClYyBYOzwHKjbe"])

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	if response:
		var armies = response["record"]["armies"]
		print(armies)
	else:
		print(response_code)


var data = {"armies": [[4,3],[4,3]]}
var json2 = JSON.stringify(data)
func send():
	$HTTPRequest.request(url2, ["Content-Type: application/json", "X-Master-Key: $2a$10$LdepC4OqSmfPDRCSaG1nwOpcgC.y4Jaz7c8vSXgClYyBYOzwHKjbe"], HTTPClient.METHOD_PUT, json2)

func _on_button_pressed() -> void:
	send()


func _on_button_2_pressed() -> void:
	get_stuff()
