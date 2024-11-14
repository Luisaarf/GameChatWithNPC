extends Control

class_name Inventory

@export var inventorySlots: InventorySlots


func add_item(item: Sprite2D) -> void:
	var free_slot = inventorySlots.get_free_slot()
	var sprite = free_slot.get_child(0)
	sprite.texture = item.texture
	sprite.name = item.name
	free_slot.disabled = false
	print(item)
