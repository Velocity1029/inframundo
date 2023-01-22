extends Node3D

class_name Inventory

var items = []
var equipped = 0
var inventory_size
var inv_upgrades = 0
const BASE_SIZE = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory_size = BASE_SIZE + inv_upgrades


func addItem(item):
	items.append(item)
	print(items)
	
func equipItem(item):
	return item

func unequipItem(item):
	pass

func removeItem(item):
	items.remove_at(items.find(item))

func isFull():
	return items.size() >= inventory_size
	
func swapItem():
	if items.size <= 0:
		return
	equipped = (equipped + 1) % (items.size())
	print(equipped)
	return equipItem(items[equipped])
