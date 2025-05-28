class_name Elevator
extends StaticBody2D

@onready var power_checks = [$PowerCheck, $PowerCheck2, $PowerCheck3, $PowerCheck4]
@onready var sprite = $Sprite2D

@export var destination_level : int
@export var direction : String
@export var desired_power : int
@export var powered : bool
var powers

func _ready():
	if direction == "down":
		sprite.region_rect.position.x = 680 + ((desired_power - 1) * 17)
		update()

func power_check():
	sprite.region_rect.position.y = min(powers, desired_power) * 17
	powered = desired_power == powers

func update():
	powers = 0
	for power in power_checks:
		if not power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if (connection is Wire or connection is Generator) and connection.powered:
				powers += 1
	power_check()
