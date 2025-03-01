extends Control
class_name StatusBar

var money_label : Label

enum STATUS_TYPES { MONEY }

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	money_label = get_node("MainContainer/MoneyContainer/Label");

# Every UI element in this status bar will be accessed with a similar set method
func set_money(amount: int) -> void:
#	Setting label text to match the value passed
	money_label.text = str(amount);

# I'm thinking we may want to sometimes hide certain elements
# So this function will allow you to hide each section
func hide_status_type(status_type : STATUS_TYPES):
	match status_type:
		STATUS_TYPES.MONEY:
			get_node("MainContainer/MoneyContainer").hide()
			
# I'm thinking we may want to sometimes hide certain elements
# So this function will allow you to show each section
func show_status_type(status_type : STATUS_TYPES):
	match status_type:
		STATUS_TYPES.MONEY:
			get_node("MainContainer/MoneyContainer").show()
