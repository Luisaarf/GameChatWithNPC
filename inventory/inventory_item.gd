extends Sprite2D

class_name InvItem

@export var nameItem: String = ''
@export var textureItem : Texture2D 

func _init(nameItem: String = "", textureItem: Texture = null):
	self.nameItem = nameItem
	self.textureItem = textureItem
