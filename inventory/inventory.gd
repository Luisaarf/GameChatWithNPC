extends Control

class_name Inv

var items: Array[Button]

func _ready() -> void:
	items = []
	for child in get_children():
		if child is Button:
			items.append(child)
	print(items)

			
func add_item(item: Sprite2D) -> void:
	var button_index :int = -1
	print(items.size(), 'here')
	var i = 0
	while i < items.size():
		print(range(items.size()))
		var button = items[i]
		for child in button.get_children():
			if child is Sprite2D:
				print(child.texture)
				if child.texture == null:
					button_index = i  
					break
	if button_index == -1:
		print("Nenhum botão livre encontrado.")
		return
	
	var free_button = items[button_index]
	free_button.add_child(item)
				
	items.append(item)
	print(items)
