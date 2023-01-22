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
		holder.throw()
		return false
	if !CONSUMABLE:
		return true
		
	uses -= 1
	if uses < 1:
		consume()
		holder.throw()
	return true
		
func consume():
	pass
