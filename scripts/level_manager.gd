extends Node

@export var level = 1

var special_scenes = {"main_menu": 0,
					  "settings": 46}
var level_folder = "res://scenes/levels/"
var savestate_folder = "user://"
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

var tile_size = 16

var previous_moves : Array[Array]
var visited_levels = []


func _ready() -> void:
	level = 1
	player_dir = "move_left"
	await get_tree().create_timer(.05).timeout
	get_tree().current_scene.set_starts()
	
	visited_levels.append(1)
	
func _unhandled_input(event):
	if player.moving or TransitionScene.transitioning:
		return
	
	if event.is_action_pressed("undo"):
		if len(previous_moves) > 0:
			var prev = previous_moves.pop_back()
			var obj = prev[1]
			if prev[0] in inputs:
				var dir = inputs[prev[0]]
				if obj is Player:
					obj.point(prev[0])
					player_dir = prev[0]
					obj.move(-1 * dir)
					if len(previous_moves) > 0:
						if previous_moves.back()[0] == "collect_item":
							prev = previous_moves.pop_back()
							obj = prev[1]
							uncollect_item(obj[0], obj[1])
				elif obj is Wire:
					obj.push(-1 * dir)
			
			if prev[0] == "interact":
				if obj is Generator:
					obj.activate()
				elif obj is Wire and inventory["wrench"] == 1:
					obj.spin("counterclockwise")
				player.player_update.emit()
		
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			player.point(dir)
			var result = await player.move(inputs[dir])
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
			if item in inventory:
				UIScene.update_item(item, inventory[item])
				
		get_tree().reload_current_scene()
		await get_tree().create_timer(.05).timeout
		if "user" in get_tree().current_scene.scene_file_path:
			get_tree().current_scene.reset()
			await get_tree().create_timer(.05).timeout
			get_tree().current_scene._on_update()
	

func load_level(_level : int):
	var packed_scene = PackedScene.new()
	packed_scene.pack(player.get_parent())
	ResourceSaver.save(packed_scene,str(savestate_folder,"saved_",level,".tscn"))
	
	level = _level
	TransitionScene.transition()
	await TransitionScene.on_transition_finished
	
	if level in visited_levels:
		get_tree().change_scene_to_file(str(savestate_folder,"saved_", level, ".tscn"))
	else:
		get_tree().change_scene_to_file(str(level_folder, "level_", level, ".tscn"))
		await get_tree().create_timer(.05).timeout
		get_tree().current_scene.set_starts()
		visited_levels.append(level)
	
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
		
	UIScene.update_item(item_name, inventory[item_name])

func uncollect_item(item : Object, item_name : String):
	inventory[item_name] -= 1
	UIScene.update_item(item_name, inventory[item_name])
	item.visible = true
	
func has_item(item_name : String) -> bool:
	return item_name in inventory and inventory[item_name] > 0

func use_item(item_name : String) -> bool:
	if has_item(item_name):
		if item_name in consumables:
			inventory[item_name] -= 1
		UIScene.update_item(item_name, inventory[item_name])
		return true
		
	return false

#func disconnect_signals():
	#for node in get_children():
		#for sig in node.get_signal_list():
			#for connection in node.get_signal_connection_list(sig.name):
				#node.disconnect(connection.signal, connection.target)
