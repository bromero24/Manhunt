extends CanvasLayer

@onready var Inventory = $Inventory


func _ready():
	for item in Inventory.get_children():
		item.visible = false
	
	
func update_consumable(item_name : String, count : int):
	var item = Inventory.find_child(item_name)
	if item:
		if count == 0:
			item.visible = false
		else:
			item.find_child("count").region_rect.position.x = 595 + (count * 17)
			item.visible = true

func update_item(item_name : String, collected : bool):
	var item = Inventory.find_child(item_name)
	if item:
		if collected:
			item.visible = true
		else:
			item.visible = false
