class_name Gate
extends StaticBody2D

@onready var power_checks = [$PowerCheck, $PowerCheck2, $PowerCheck3, $PowerCheck4]
@onready var sprite = $Sprite2D

var powered = false

func power_up():
	powered = true
	sprite.region_rect.position.y = 17
	
func power_down():
	powered = false
	sprite.region_rect.position.y = 0
	
func update():
	for power in power_checks:
		if not power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if (connection is Wire or connection is Generator) and connection.powered:
				power_up()
				return
	power_down()
