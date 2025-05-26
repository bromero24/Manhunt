class_name Level
extends Node2D

var generators : Array[Generator] = []
var wires : Array[Wire] = []
var gates : Array[Gate] = []
var upElevator : Elevator = null
var downElevator : Elevator = null

var inventory = {}

func _ready():
	for wire in find_children("Wire*"):
		wires.append(wire)
	for generator in find_children("Generator*"):
		generators.append(generator)
	for gate in find_children("Gate*"):
		gates.append(gate)
	downElevator = find_child("DownElevator")
	
	LevelManager.player = find_child("Player")
	
func _on_update():
	for wire in wires:
		wire.update()
	for gate in gates:
		gate.update()
	if downElevator:
		downElevator.update()
