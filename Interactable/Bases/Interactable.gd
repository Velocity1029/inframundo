extends RigidBody3D

class_name Interactable

func get_interaction_text():
	return "Interact"
	
func interact(_player):
	print("Interacted with %s" % name)
