class_name Box
extends StaticBody2D

@onready var ray = $RayCast2D
@export var animation_speed = 10

var moving = false
var tile_size = 16		


func push(dir: Vector2) -> void:
	ray.target_position = dir * tile_size
	ray.force_raycast_update()
	
	if !ray.is_colliding():
		var tween = create_tween()
		tween.tween_property(self, "position", position + dir * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
