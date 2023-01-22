extends Takeable

class_name Equippable

var isHeld = false
var holder = null
var hand = null
@onready var home = get_parent()

func interact(player):    
	player.equip(self)
	holder = player
	
func setHeld(Hand):
	hand = Hand
	isHeld = true
	position = Vector3()
	rotation = Vector3()
	
	get_parent().remove_child(self)
	hand.add_child(self)

func thrown():
	holder = null
	hand = null
	isHeld = false
	var gtransform = global_transform
	
	get_parent().remove_child(self)
	home.add_child(self)
	
	global_transform = gtransform
	
