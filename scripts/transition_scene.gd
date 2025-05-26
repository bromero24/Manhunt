extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

signal on_transition_finished

var transitioning

func _ready():
	color_rect.visible = false
	animation_player.play("fade_to_normal")
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		on_transition_finished.emit()
		await get_tree().create_timer(.25).timeout
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		color_rect.visible = false
		transitioning = false
		
func transition():
	color_rect.visible = true
	transitioning = true
	await get_tree().create_timer(.25).timeout
	animation_player.play("fade_to_black")
