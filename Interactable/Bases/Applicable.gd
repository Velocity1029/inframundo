extends Equippable

class_name Applicable

var uses = STARTING_USES
const STARTING_USES = 3
const CONSUMABLE = true

func _ready():
	uses = STARTING_USES

func use():
	if uses < 1:
		consume()
		return false
	if !CONSUMABLE:
		return true
		
	uses -= 1
	if uses < 1:
		consume()
	return true

func apply(_player, item):
	print("Applied ", name," to ", item.name)

func consume():
	#Broken ? Nil holder holder.throw()
	pass
