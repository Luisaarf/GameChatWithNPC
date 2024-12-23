extends Control

var settings_path = "res://settings.json"
var chat_button : Button
var chat_scene : Control
var red_crystal_texture = preload("res://assets/ForestDetails/06.png")
var red_crystal_item: Sprite2D
@export var inventory : Inventory

func _ready():
	_update_ui()
	chat_button = find_child("EnterChatButton")
	print('initialized')
	chat_button.connect("pressed", Callable(self, "_on_button_pressed").bind(chat_button))
	chat_button.visible = false
	chat_scene = $Chat
	chat_scene.visible = false
	inventory = $Inventory

func _on_button_pressed(button):
	chat_scene.visible = true


func _update_ui():
	if FileAccess.file_exists(settings_path):
		find_child("KeyContainer").visible = false
		find_child("ButtonContainer").visible = true
	else:
		find_child("KeyContainer").visible = true
		find_child("ButtonContainer").visible = false

func _on_set_api_button_pressed():
	var key = find_child("KeyEdit").text
	if key.is_empty():
		return
	var json_text = JSON.stringify({"api_key":key})
	var file = FileAccess.open(settings_path,FileAccess.WRITE)
	file.store_string(json_text)
	file.close()
	chat_scene.read_settings_file()
	_update_ui()

func _on_chat_area_body_entered(body):
	if body.name == 'baseCharacter':
		chat_button.visible = true
		print('collision ', body) # Replace with function body.


func _on_chat_area_body_exited(body):
	if body.name == 'baseCharacter':
		chat_button.visible = false
		print('collision ', body) # Replace with function body.

func add_red_crystal_to_inventory():
	inventory = $Inventory
	red_crystal_item = Sprite2D.new() 
	red_crystal_item.name ="Red Crystal"
	red_crystal_item.texture = red_crystal_texture
	inventory.add_item(red_crystal_item)
