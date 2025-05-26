class_name Wire
extends StaticBody2D

@onready var ray = $RayCast2D
@onready var sprite = $Sprite2D
@onready var power_checks = [$PowerCheck, $PowerCheck2, $PowerCheck3, $PowerCheck4]
@export var animation_speed = 10

signal wire_update

var moving = false
var powered = false
var tile_size = 16		

func _ready():
	wire_update.connect(get_parent()._on_update)
	ray.rotation = -1 * rotation
	
func cwise():
	var target_rotation = rotation_degrees + 90
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", target_rotation, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	
	if rotation_degrees == 360:
		rotation_degrees = 0
	wire_update.emit()
	ray.rotation = -1 * rotation

func ccwise():
	var target_rotation = rotation_degrees - 90	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", target_rotation, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	
	if rotation_degrees == -360:
		rotation_degrees = 0
	wire_update.emit()
	ray.rotation = -1 * rotation

func push(dir: Vector2) -> bool:
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position", position + dir * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
		await get_tree().create_timer(.05).timeout
		wire_update.emit()
		return true
	
	return false

func power_up():
	powered = true
	sprite.region_rect.position.y = 17

func power_down():
	powered = false
	sprite.region_rect.position.y = 0

func update() -> bool:
	for power in power_checks:
		if !power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if connection is Generator and connection.powered:
				power_up() 
				return true
			elif connection is Wire:
				var result = connection.update_rec(self)
				if result:
					power_up()
					return true
				
	power_down()
	return false
	
func update_rec(prev : Wire) -> bool:
	for power in power_checks:
		if not power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if not connection == prev:
				if connection is Generator and connection.powered:
					return true
				elif connection is Wire:
					var result = connection.update_rec(self)
					if result:
						return true
	return false
