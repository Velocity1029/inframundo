extends Interactable

class_name Grabable

func interact(player):
	print("Grabbed %s" % name)
	queue_free()
