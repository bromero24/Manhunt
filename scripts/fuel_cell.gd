extends Area2D

func _on_area_entered(area : Area2D) -> void:
	if area is Player and visible:
		LevelManager.collect_item(self, "fuel_cell")
