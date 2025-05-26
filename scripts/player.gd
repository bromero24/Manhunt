class_name Player
extends Area2D

@onready var ray = $RayCast2D
@onready var sprite = $Sprite2D

@export var animation_speed = 20

signal player_update

var moving = false
var tile_size = 16
var inputs = {"move_right": Vector2.RIGHT,
			"move_left": Vector2.LEFT,
			"move_up": Vector2.UP,
			"move_down": Vector2.DOWN}

func _ready() -> void:
	position -= Vector2(1,1)
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2
	point(LevelManager.player_dir)
	player_update.connect(get_parent()._on_update)
		
func point(dir):
	match dir:
		"move_up":
			sprite.region_rect.position.y = 34
		"move_right":
			sprite.region_rect.position.y = 51
		"move_down":
			sprite.region_rect.position.y = 0
		"move_left":
			sprite.region_rect.position.y = 17
	
func move(dir) -> Object:
	ray.target_position = inputs[dir] * tile_size
	ray.force_raycast_update()
	
	LevelManager.player_dir = dir
	point(dir)
	
	if ray.is_colliding():
		var collided = ray.get_collider()
		if collided is Wire:
			var success = await collided.push(inputs[dir])
			player_update.emit()
			if success:
				return collided
			else:
				return null
		elif collided is Gate and collided.powered:
			pass
		elif collided is Elevator:
			pass
		else:
			return null
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + inputs[dir] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	player_update.emit()
	return self
	
func unmove(dir):
	point(dir)
	var new_dir = ""
	match dir:
		"move_up":
			new_dir = "move_down"
		"move_right":
			new_dir = "move_left"
		"move_down":
			new_dir = "move_up"
		"move_left":
			new_dir = "move_right"
	
	var tween = create_tween()
	tween.tween_property(self, "position", position + inputs[new_dir] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
	moving = true
	await tween.finished
	moving = false
	player_update.emit()
	return self
			

func interact():
	if ray.is_colliding():
		var collided = ray.get_collider()
		if collided is Generator:
			collided.activate()
			player_update.emit()
			return collided
		elif collided is Wire and not collided.moving:
			collided.cwise()
			player_update.emit()
			return collided
	return null
	
	
