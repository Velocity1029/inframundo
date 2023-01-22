extends Applicable

class_name Pot

var canDrench = true
@export var liquid : String
@export var amount = 0

func _ready():
	pass

func interact(player): 
	if !isHeld:
		player.pickup(self)
		

func apply(_player, item):
	print("Applied ", name," to ", item.name)
		
	if liquid != null and item.has_method("drench"):
		item.drench(liquid)
		
		use()


func fill(liquid, amount):
	self.liquid = liquid
	self.amount = amount

func drain():
	liquid = null
	amount = 0
