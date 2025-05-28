class_name Gate
extends StaticBody2D

@onready var power_checks = [$PowerCheck, $PowerCheck2, $PowerCheck3, $PowerCheck4]
@onready var sprite = $Sprite2D

var powered = false

func _ready():
	update()
	
func update_sprite():
	sprite.region_rect.position.y = int(powered) * 17
	
func update():
	for power in power_checks:
		if not power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if (connection is Wire or connection is Generator) and connection.powered:
				powered = true
				update_sprite()
				return

	powered = false
	update_sprite()
