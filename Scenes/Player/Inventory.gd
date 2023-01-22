extends Node3D

var items = []
var inventory_size
var inv_upgrades = 0
const BASE_SIZE = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_size = BASE_SIZE + inv_upgrades


func addItem(item):
	items.append(item)
	
func equipItem(item):
	pass

func unequipItem(item):
	pass

func removeItem():
	items.remove_at(0)

func isFull():
	return items.len >= inventory_size
	
