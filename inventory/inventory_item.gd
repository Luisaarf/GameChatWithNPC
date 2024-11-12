extends Resource

class_name InvItem

@export var name: String = ''
@export var texture : Texture2D 

func _init(nome: String = "", texture: Texture = null):
	self.nome = nome
	self.texture = texture
	Inventory.push(self)
