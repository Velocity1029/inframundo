extends Applicable

class_name Torch

var isDrenchable
var isLit
var isLightable
var drenchedIn = null
@export var strength = 2
@export var start_lit = false
@export var lifetime = 60

func _ready():
	if start_lit:
		light()
	else:
		snuff()
		
func _process(delta):
	if isLit:
		lifetime = lifetime - delta
		
		if lifetime < 0:
			lifetime = 0
			snuff()

func interact(player): 
	if !isHeld:
		player.pickup(self)
		

func apply(_player, item):
	print("Applied ", name," to ", item.name)
		
	if isLit and item.has_method("light"):
		item.light()
		use()


func light():
	print("Lighting up")
	isLit = true
	
	get_node("OmniLight3D").light_energy = strength
	get_node("Fire/GPUParticles3D").emitting = true

func snuff():
	print("Snuffed")
	isLit = false
	
	get_node("OmniLight3D").light_energy = 0
	get_node("Fire/GPUParticles3D").emitting = false

func drench(liquid):
	if !drenchedIn:
		print(name, " drenched in ", liquid)
		if liquid == "oil":
			lifetime = lifetime * 10
