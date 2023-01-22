extends Interactable

class_name Takeable

func interact(player):
	print("Took %s" % name)
	triggers()
	
func triggers():
	
	queue_free()
