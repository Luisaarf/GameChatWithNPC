extends CharacterBody2D

@onready var animation_npc = $AnimationNPC

func _ready():
	animation_npc.play("idle")
