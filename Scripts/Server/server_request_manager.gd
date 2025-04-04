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
	#TODO ENV VARS
	url_base = "http://127.0.0.1:8000"
	self.user_logged_in = false

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
	
func _login(username : String, password : String):
	var user_info = await _login_request(username, password)
	if(user_info == null):
		assert(false, "ERROR WITH LOGIN")
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
## grid_string - the grid as a stringified JSON object [br]
## turn - the turn number, [br]
## response_handler - the function which will recieve the JSON response object. Should take in a single parameter which is a dictionary [br][br]
##
## grid_string is going to be the grid data as a stringified JSON object like we save in the grid_manager.gd
## save_layout and load_layout functions
## They will be associated with the user logged in at startup.
## Function assumes user is already logged in currently
## [br]
## 
## RETURNS a response dictionary with keys "map" being the opponents map as a string, "username" being the name of the opponent
func upload(grid_string : String, turn : int):
	
#	TEMP UNTIL PROPER LOGIN
	if !user_logged_in:
		await _login("","")
	
	print("ENTER upload_and_retrieve")
	var endpoint = "/api/upload"
	
	var _on_upload_and_retrieve = func(result, response_code, headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		upload_complete.emit(json)
	
	self.request_handler.request_completed.connect(_on_upload_and_retrieve)
	var request_body = {
		"game_state": grid_string,
		"turn" : turn,
		"user" : self.user_id
	}
	
	var headers = ["Content-Type: application/json"]
	print(self.url_base + endpoint)
	var error = self.request_handler.request(self.url_base + endpoint, headers, HTTPClient.METHOD_POST, str(request_body))
	print(error)
		
	return error
