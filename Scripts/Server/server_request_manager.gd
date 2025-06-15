class_name ArmiesServerRequestManager
extends Node

var url_base : String
var request_handler : HTTPRequest
var user_request_handler : HTTPRequest

#Thinking these can just be stored in this class since it will be a AutoLoaded in anyway
var user_id : int
var user_name : String
var user_logged_in : bool

var _user_name_cache: String

signal login_complete
signal upload_complete
signal create_guest_complete

func _init():
	request_handler = HTTPRequest.new()
	user_request_handler = HTTPRequest.new()
	add_child(request_handler)
	add_child(user_request_handler)
	#TODO CONFIG INSTEAD OF HARDCODING
	url_base = "http://127.0.0.1:8000"
	self.user_logged_in = false
	self.user_name = ""
	self.user_id = 0
	self._user_name_cache = ""

func create_guest(username : String):
	var endpoint = "/api/user/guest/create"
	self._user_name_cache = username
	var _on_complete = func(result, response_code, headers, body):
		var body_content = body.get_string_from_utf8()
		if(body_content != ''):
			var json = JSON.parse_string(body.get_string_from_utf8())
			self.user_id = int(json["user_id"])
			self.user_name = json["user_name"]
			self.user_logged_in = true
		
			create_guest_complete.emit(json)
		else:
			create_guest_complete.emit({
				"error": true,
				"message": "No Response From Server",
				"code": "SERVER_NOT_FOUND"
			})

	self.user_request_handler.request_completed.connect(_on_complete)
	var request_body = {
		"user_name": username
	}
	var headers = ["Content-Type: application/json"]
	return self.user_request_handler.request(self.url_base + endpoint, headers, HTTPClient.METHOD_POST, str(request_body))

func retry_create_guest():
	if(self._user_name_cache):
		return self.create_guest(self._user_name_cache)
	else:
		return FAILED
		
#Running this fucntion effectly resets the user at the start of a new run.
func start_with_new_team(teamname : String):
	self._user_name_cache = teamname
	self.user_logged_in = false
	self.user_name = ""
	self.user_id = 0
		
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
	
	if !user_logged_in:
		return FAILED
	
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
	return self.request_handler.request(self.url_base + endpoint, headers, HTTPClient.METHOD_POST, str(request_body))
