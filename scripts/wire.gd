class_name Wire
extends StaticBody2D

@onready var ray = $RayCast2D
@onready var sprite = $Sprite2D
@onready var power_checks = [$PowerCheck, $PowerCheck2, $PowerCheck3, $PowerCheck4]
@export var animation_speed = 10
@export var powered : bool
@export var starting_position : Vector2
@export var starting_rotation_deg : float

signal wire_update

var moving = false
var spin_direction = {"clockwise" : 1, "counterclockwise" : -1}

################# Init functions #################
func _ready():
	wire_update.connect(get_parent()._on_update)
	ray.rotation = -1 * rotation
	update_sprite()
	starting_position = starting_position * 2
	starting_position = starting_position / 2
	starting_rotation_deg = starting_rotation_deg * 2
	starting_rotation_deg = starting_rotation_deg / 2
	
	
func set_starts():
	starting_position = position
	starting_rotation_deg = rotation_degrees
	
func reset():
	position = starting_position
	rotation_degrees = starting_rotation_deg
	update_sprite()

################# Moving functions #################
func spin(direction: String):
	var spin_val = spin_direction[direction]
	var target_rotation = rotation_degrees + (spin_val * 90)
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", target_rotation, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	
	if rotation_degrees == (spin_val * 360):
		rotation_degrees = 0
		
	ray.rotation = -1 * rotation
	wire_update.emit()

func push(dir: Vector2) -> bool:
	ray.target_position = dir * LevelManager.tile_size
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position", position + ray.target_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
		await get_tree().create_timer(.05).timeout
		wire_update.emit()
		return true
	
	return false


################# Update functions #################
func update_sprite():
	sprite.region_rect.position.y = int(powered) * 17

func update() -> bool:
	for power in power_checks:
		if !power.find_child("CollisionShape2D").disabled and power.has_overlapping_areas():
			var connection = power.get_overlapping_areas()[0].get_parent()
			if connection is Generator and connection.powered:
				powered = true
				update_sprite()
				return true
			elif connection is Wire:
				var result = connection.update_rec(self)
				if result:
					powered = true
					update_sprite()
					return true
				
	powered = false
	update_sprite()
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
