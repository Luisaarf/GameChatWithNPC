extends Resource

class_name Inv

@export var items: Array[InvItem]

func _init():
	items = []

func add_item(item: InvItem) -> void:
	items.append(item)
	
