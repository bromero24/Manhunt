class_name Generator
extends StaticBody2D

@onready var sprite = $Sprite2D
var powered = false

func activate():
	if not powered and LevelManager.has_item("fuel_cell"):
		LevelManager.use_item("fuel_cell")
		
	elif powered:
		LevelManager.collect_item(null, "fuel_cell")
	powered = not powered
	sprite.region_rect.position.y = int(powered) * 17
