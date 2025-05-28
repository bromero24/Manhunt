extends Area2D

@export var item_name : String

func _ready():
	if not is_connected("area_entered", _on_area_entered):
		area_entered.connect(_on_area_entered)

func _on_area_entered(area : Area2D) -> void:
	if area is Player and visible:
		LevelManager.collect_item(self, item_name)
