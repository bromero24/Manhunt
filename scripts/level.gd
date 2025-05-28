class_name Level
extends Node2D

var generators : Array[Generator] = []
var wires : Array[Wire] = []
var gates : Array[Gate] = []
var upElevator : Elevator = null
var downElevator : Elevator = null

func _ready():
	for generator in find_children("Generator*"):
		generators.append(generator)
	for wire in find_children("Wire*"):
		wires.append(wire)
	for gate in find_children("Gate*"):
		gates.append(gate)
	downElevator = find_child("DownElevator")
	upElevator = find_child("UpElevator")
	
	LevelManager.player = find_child("Player")
	await get_tree().create_timer(0.05).timeout
	_on_update()
	
func _on_update():
	for wire in wires:
		wire.update()
	for gate in gates:
		gate.update()
	if downElevator:
		downElevator.update()

func set_starts():
	for wire in wires:
		wire.set_starts()

func reset():
	for wire in wires:
		wire.reset()
