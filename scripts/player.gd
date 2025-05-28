class_name Player
extends Area2D

@onready var ray = $RayCast2D
@onready var sprite = $Sprite2D

@export var animation_speed = 20

signal player_update

var moving = false

func _ready() -> void:
	point(LevelManager.player_dir)
	player_update.connect(get_parent()._on_update)
		
func point(direction):
	match direction:
		"move_up":
			sprite.region_rect.position.y = 34
		"move_right":
			sprite.region_rect.position.y = 51
		"move_down":
			sprite.region_rect.position.y = 0
		"move_left":
			sprite.region_rect.position.y = 17
	
func move(dir: Vector2) -> Object:
	ray.target_position = dir * LevelManager.tile_size
	ray.force_raycast_update()
	
	var collided = ray.get_collider()
	if collided:
		if collided is Wire:
			if await collided.push(dir):
				return collided
			else:
				return null
		elif (collided is Gate and collided.powered) or collided is Elevator:
			pass
		else:
			return null
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + ray.target_position, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	player_update.emit()
	
	if collided is Elevator and collided.powered:
		LevelManager.load_level(collided.destination_level)
		return null
	
	return self

func interact():
	var collided = ray.get_collider()
	if collided:
		if collided is Generator:
			collided.activate()
			player_update.emit()
			return collided
		elif collided is Wire and not collided.moving and LevelManager.has_item("wrench"):
			collided.spin("clockwise")
			return collided
	return null
