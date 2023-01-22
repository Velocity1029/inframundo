extends RayCast3D

@export var player : CharacterBody3D
var current_colider

func _process(_delta):
	var collider = get_collider()
	
	if is_colliding() and collider is Interactable:
		if current_colider != collider:
			current_colider = collider
		
		if Input.is_action_just_pressed("Interact") :
			collider.interact(player)
			
		if Input.is_action_just_pressed("Apply"):
			if  player.Hand.heldObject:
				collider.apply(player, player.Hand.heldObject)
			else:
				print("No held object!")
			
	elif current_colider:
		current_colider = null
