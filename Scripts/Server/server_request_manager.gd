class_name ArmiesServerRequestManager
extends Node

var url_base : String
var request_handler : HTTPRequest

#Thinking these can just be stored in this class since it will be a AutoLoaded in anyway
var user_id : int
var user_name : String
var user_logged_in : bool

signal login_complete
signal upload_complete

func _init():
	request_handler = HTTPRequest.new()
	add_child(request_handler)
	#TODO CONFIG INSTEAD OF HARDCODING
	url_base = "http://127.0.0.1:8000"
	self.user_logged_in = false

# TODO Right now login is mostly being ignored
func login(username : String, password : String):
	var endpoint = "/api/user/login"
	
	var _on_complete = func(result, response_code, headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		login_complete.emit(json)
		
	self.request_handler.request_completed.connect(_on_complete)
	var headers = ["Content-Type: application/json"]
	var request_headers = PackedStringArray(["Content-Type", "application/json"])
	var error = self.request_handler.request(self.url_base + endpoint, headers, HTTPClient.METHOD_POST)
	return error
	
# THESE FOLLOING FUNCTIONS ARE FOR EASE OF
# EARLY WORK. GET USED FOR TEMP UPLOAD LOGIN
func _login(username : String, password : String):
	var user_info = await _login_request(username, password)
	if(user_info != null):
		self.user_id = user_info["id"]
		self.user_name = user_info["user_name"]
		self.user_logged_in = true
	
func _login_request(username : String, password : String):
	var endpoint = "/api/user/login"
	
	var _on_complete = func(result, response_code, headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		login_complete.emit(json)
		
	self.request_handler.request_completed.connect(_on_complete)
	var headers = ["Content-Type: application/json"]
	var error = self.request_handler.request(self.url_base + endpoint, headers, HTTPClient.METHOD_POST)
	
	if error == OK:
		return login_complete
	else:
		return null
		
## This function will upload the grid and the turn number to be stored in the database [br][br]
## 
## Parameters [br]
## grid - the users unit grid which will be stringified for request [br]
## turn - the turn number, [br]
## grid_string is going to be the grid data as a stringified JSON object like we save in the grid_manager.gd
## save_layout and load_layout functions
## They will be associated with the user logged in within method
## 
## RETURNS - See HTTPRequest error codes
func upload(grid : Array, turn : int):
	
#	TEMP UNTIL PROPER LOGIN
	if !user_logged_in:
		await _login("","")
	
	var endpoint = "/api/upload"
	
	var error
	var _on_upload_and_retrieve = func(result, response_code, headers, body):
		var body_content = body.get_string_from_utf8()
		if(body_content != ''):
			var json = JSON.parse_string(body_content)
			json["enemy_game_state"] = str_to_var(json["enemy_game_state"])
			upload_complete.emit(json)
		else:
			upload_complete.emit({
				"error": true,
				"message": "No Response From Server",
				"code": "SERVER_NOT_FOUND"
			})

	self.request_handler.request_completed.connect(_on_upload_and_retrieve)
	
	var grid_string = JSON.stringify(grid)
	var request_body = {
		"game_state": grid_string,
		"turn" : turn,
		"user" : self.user_id
	}
	
	var headers = ["Content-Type: application/json"]
	print(self.url_base + endpoint)
	error = self.request_handler.request(self.url_base + endpoint, headers, HTTPClient.METHOD_POST, str(request_body))
		
	return error
