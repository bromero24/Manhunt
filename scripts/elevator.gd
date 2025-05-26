class_name Elevator
extends StaticBody2D

@onready var power_checks = [$PowerCheck, $PowerCheck2, $PowerCheck3, $PowerCheck4]
@onready var sprite = $Sprite2D

@export var destination_level : int

@export var desired_power : int

var powered = false
var powers

func _ready():
	sprite.region_rect.position.x = 680 + ((desired_power - 1) * 17)
	update()

func power_up():
	powered = true
	sprite.region_rect.position.y = 187
	
func power_down():
	powered = false
	sprite.region_rect.position.y = 306

func power_check():
	var power_num = min(powers, desired_power)
	sprite.region_rect.position.y = power_num * 17
	if desired_power == powers:
		powered = true
	else:
		powered = false

func update():
	powers = 0
	for power in power_checks:
		if not power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if (connection is Wire or connection is Generator) and connection.powered:
				powers += 1
	
	power_check()


func _on_elevator_entered(area):
	if area is Player and powered:
		LevelManager.load_level(destination_level)
