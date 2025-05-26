extends Node

@export var curScene = 0
@export var level = 1

var special_scenes = {"main_menu": 0,
					  "settings": 46}
var level_folder = "res://scenes/levels/"
var inventory = {"fuel_cell" : 0,
				 "wrench" : 0}
var savepoint_inventory = {}
var consumables = ["fuel_cell"]
var items = ["fuel_cell", "wrench"]

var inputs = {"move_right": Vector2.RIGHT,
			"move_left": Vector2.LEFT,
			"move_up": Vector2.UP,
			"move_down": Vector2.DOWN}
var player_dir
var player : Player

var previous_moves : Array[Array]


func _ready() -> void:
	level = 1
	curScene = level
	player_dir = "move_left"
	
func _unhandled_input(event):
	if player.moving or TransitionScene.transitioning:
		return
	
	if event.is_action_pressed("undo"):
		if len(previous_moves) > 0:
			var prev = previous_moves.pop_back()
			var obj = prev[1]
			
			for dir in inputs.keys():
				if dir == prev[0]:
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
					
					if obj is Player:
						obj.unmove(dir)
						if len(previous_moves) > 0:
							if previous_moves.back()[0] == "collect_item":
								prev = previous_moves.pop_back()
								obj = prev[1]
								uncollect_item(obj[0], obj[1])
					elif obj is Wire:
						obj.push(inputs[new_dir])
			
			if prev[0] == "interact":
				if obj is Generator:
					obj.activate()
				elif obj is Wire and inventory["wrench"] == 1:
					obj.ccwise()
				player.player_update.emit()
		
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			var result = await player.move(dir)
			if result:
				previous_moves.push_back([dir,result])
			
	if event.is_action_pressed("interact"):
		var result = player.interact()
		if result:
			previous_moves.push_back(["interact",result])
		
	
	if event.is_action_pressed("reset"):
		inventory = savepoint_inventory.duplicate()
		TransitionScene.transition()
		await TransitionScene.on_transition_finished
		for item in items:
			if item in consumables:
				if item in inventory:
					UIScene.update_consumable(item, inventory[item])
				else:
					UIScene.update_consumable(item, 0)
			else:
				if item in inventory:
					UIScene.update_item(item, inventory[item] == 1)
				else:
					UIScene.update_item(item, false)
		get_tree().reload_current_scene()
		player = get_tree().root.find_child("Player")
	
func load_level(_level : int):
	level = _level
	TransitionScene.transition()
	await TransitionScene.on_transition_finished
	get_tree().change_scene_to_file(str(level_folder, "level_", level, ".tscn"))
	savepoint_inventory = inventory.duplicate()
	previous_moves = []
	
func collect_item(item : Object, item_name : String):
	if item:
		item.visible = false
		previous_moves.push_back(["collect_item", [item, item_name]])
	if item_name in inventory:
		inventory[item_name] += 1
	else:
		inventory[item_name] = 1
	if item_name in consumables:
		UIScene.update_consumable(item_name, inventory[item_name])
	else:
		UIScene.update_item(item_name, true)

func uncollect_item(item : Object, item_name : String):
	inventory[item_name] -= 1
	if item_name in consumables:
		UIScene.update_consumable(item_name, inventory[item_name])
	else:
		UIScene.update_item(item_name, false)
	
	item.visible = true
	
	
func has_item(item_name : String) -> bool:
	if item_name in inventory and inventory[item_name] > 0:
		return true
	return false

func use_item(item_name : String) -> bool:
	if item_name in inventory:
		if item_name in consumables and inventory[item_name] > 0:
			inventory[item_name] -= 1
			UIScene.update_consumable(item_name, inventory[item_name])
			return true
		elif not item_name in consumables and inventory[item_name] == 1:
			return true
			
	return false
