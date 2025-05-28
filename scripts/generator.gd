class_name Generator
extends StaticBody2D

@onready var sprite = $Sprite2D
@export var powered = false

func _ready():
	update_sprite()
	
func update_sprite():
	sprite.region_rect.position.y = int(powered) * 17

func activate():
	if not powered and LevelManager.has_item("fuel_cell"):
		powered = true
		LevelManager.use_item("fuel_cell")
	elif powered:
		powered = false
		LevelManager.collect_item(null, "fuel_cell")
	else:
		pass
		
	update_sprite()
