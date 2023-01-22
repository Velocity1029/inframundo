extends Applicable

class_name Torch

var isOiled
var isLit
var canLight
@export var strength = 2
@export var start_lit = false
@export var lifetime = 5000

func _ready():
	if start_lit:
		light()
	else:
		snuff()

func interact(player): 
	if !isHeld:
		player.equip(self)
		

func apply(_player, item):
	print("Applied ", item.name," to ",name)
	
	#if !isOiled and item.canOil:
	#	isOiled = true
	#	item.use()
		
	if !isLit and item.canLight:
		light()
		item.use()


func light():
	print("Lighting up")
	isLit = true
	canLight = true
	
	get_node("OmniLight3D").light_energy = strength
	get_node("Fire/GPUParticles3D").emitting = true

func snuff():
	print("Snuffed")
	isLit = false
	canLight = false
	
	get_node("OmniLight3D").light_energy = 0
	get_node("Fire/GPUParticles3D").emitting = false
