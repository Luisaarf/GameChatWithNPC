extends HBoxContainer

class_name InventorySlots

@export var slotOne: Button
@export var slotTwo: Button
@export var slotThree: Button

func get_free_slot():
	if slotOne.disabled:
		return slotOne
	if slotTwo.disabled:
		return slotTwo
	if slotThree.disabled:
		return slotThree
