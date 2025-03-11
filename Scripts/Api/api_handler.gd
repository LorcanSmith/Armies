class_name ApiHandler
extends Node
## The class that will handle all requests bewteen the game and the API
##
## This class will be loaded with Godot Autoload

var url_base : String
var request_handler : HTTPRequest

#Thinking these can just be stored in this class since it will be a AutoLoaded in anyway
var user_id : int
var user_name : String

func _init():
	request_handler = HTTPRequest.new()
	add_child(request_handler)
#	TODO ENV VARS
	url_base = "http://127.0.0.1:8000"
	
#	TEMP - Don't want to deal with login atm
	login("User_1", 1)
	
	print("INFO - Logged in as USERNAME:%s USERID:%s" % [user_name, user_id])

## This function will make a request to the API login/guest endpoint 
##
## This will allow users to skip making a user
## TODO currently just returns the user with id 2
func login_guest():
	var endpoint = "/api/user/login/guest"
	self.user_id = 2
	self.user_name = "Guest_1"
	
	return get_user_info()

## This function will make a request to the API login endpoint 
##
## Password will not actually be used by the API initially
## TODO currently just returns the user with id 1
func login(username : String, password : int):
	var endpoint = "/api/user/login"
	self.user_id = 1
	self.user_name = "User_1"
	
	return get_user_info()

## This function will make a request to the API register endpoint 
##
## Password will not actually be used by the API initially
## TODO Unimplemented ATM
func register(username : String, password : int):
	var endpoint = "/api/user/register"
	pass

## Returns the cached username and user_id in a dictionary
##
## Has keys user_name and user_id
func get_user_info():
	return {
		"user_name": self.user_name,
		"user_id": self.user_id
	}


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
func upload_and_retrieve(grid_string : String, turn : int, response_handler : Callable):
	print("ENTER upload_and_retrieve")
	var endpoint = "/api/upload"
	
	var _on_upload_and_retrieve = func(result, response_code, headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		response_handler.call(json)
	
	self.request_handler.request_completed.connect(_on_upload_and_retrieve)
	var request_body = {
		"grid": grid_string,
		"turn" : turn,
		"user_id" : self.user_id
	}
	# TODO: Real headers if needed
	var request_headers = PackedStringArray(["hello", "world"])
	print(self.url_base + endpoint)
	var error = self.request_handler.request(self.url_base + endpoint)
	#var response = self.request_handler.request(self.url_base + endpoint, request_headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))
	print(error)
		
	return error
