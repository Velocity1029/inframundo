class_name new_Slot

var original_prototypes : Array[new_Prototype]
var possible_prototypes : Array[new_Prototype]
var position : Vector3
var collapsed_mesh: int = 0
var collapsed_rot: int = 0
var collapsed : bool = false

func _init(prototypes:Array[new_Prototype], position:Vector3 = Vector3()):	
	self.original_prototypes = prototypes
	self.possible_prototypes = prototypes.duplicate()
	self.position = position
	
func restrict_prototypes(possibilities:Array[new_Prototype]):
	#var copy = self.prototypes.duplicate()
	for proto in original_prototypes: #range(prototypes.size() - 1, -1, -1):
		if proto not in possibilities:
			possible_prototypes.erase(proto)
	#prototypes = copy
	print(self.position,", ",possible_prototypes,", ", possibilities)
	#print("Restricted to: ", prototypes, " Out of: ", possibilities)
	
func pick_prototype():
	if self.collapsed: return
	if possible_prototypes.size() == 0:
		collapse(-1, 0)
	else:
		var pick : new_Prototype = possible_prototypes.pick_random()
		var pickle : Array[new_Prototype] = [pick]
		collapse(pick.mesh, pick.rotation)
		#!!!! Can just assign to prototypes
		restrict_prototypes(pickle)

func collapse(mesh:int, rot:int):
	collapsed_mesh = mesh
	collapsed_rot = rot
	collapsed = true
