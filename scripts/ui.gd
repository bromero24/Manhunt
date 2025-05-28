extends CanvasLayer

@onready var Inventory = $Inventory


func _ready():
	for item in Inventory.get_children():
		item.visible = false
	
func update_item(item_name: String, count: int):
	var item = Inventory.find_child(item_name)
	if item:
		item.visible = count > 0
		if item.find_child("count"):
			item.find_child("count").region_rect.position.x = 595 + (count * 17)
