extends GridMap

class_name new_WaveFunctionCollapse

@export var processor : Node3D
@export var originX = 0
@export var originY = 0
@export var xRange = 40
@export var zRange = 40

const DIRECTIONS = [Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1)]
const weirdRotationTranslator = {0:0, 2:10, 10:2, 3:16, 16:3, 1:22, 22:1}

var output
var self_copy
var grid = []
var original_prototypes : Array[new_Prototype]
var prototypes : Array[new_Prototype]

# NEW STACK METHOD

var restraining_stack : Array[new_Slot]

# ### ##### ######

var timer := Timer.new()
@export var wait = 0.2
var timed_iteration = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self_copy = self.duplicate(11)
	output = self_copy
	
	add_child(timer)
	timer.wait_time = wait
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)

func _process(_delta):
	if Input.is_action_just_pressed("Shoot"):
		processor.process_self()
		#work(data)

func setup_superposition(protos):
	original_prototypes = protos
	for prototype in original_prototypes:
		prototypes.append(prototype.duplicate())
	
	
	
	#var superposition : Array[new_Prototype]
	#for p in prototypes:
	#	superposition.append(p)
	#var superposition : Array[new_Prototype] = prototypes.duplicate()
	#print(prototypes)
	for x in xRange:
		var row = []
		for z in zRange:
			row.append(new_Slot.new(prototypes, Vector3(x, 0, z)))
		grid.append(row)

func work(protos):
	setup_superposition(protos)
	
	var lips = output.get_used_cells()
	print(lips)
	
	# Analyze and setup initial constraint cells
	for cell in lips:
		# Getting data
		var mesh = output.get_cell_item(cell)
		var rot = weirdRotationTranslator[output.get_cell_item_orientation(cell)]
		
		var start = grid[cell.x][cell.z]
		
		if prototypes[mesh*4].mesh == -1:
			print("ERROR! Starting block in output does not exist in reference.")
		
		var start_prototype : Array[new_Prototype] = [prototypes[mesh*4+rot]]
		
		start.restrict_prototypes(start_prototype)
		
		#grid[cell.x][cell.z].collapse(mesh, rot)
		
	while true:
		var lowest_entropy_slot = get_lowest_entropy_slot()
		if lowest_entropy_slot == null: break
		collapse_slot(lowest_entropy_slot, prototypes)
			

func collapse_slot(slot:new_Slot, prototypes):
	if slot == null:
		return
		
	slot.pick_prototype()
	
	var mesh = slot.collapsed_mesh
	var rot = slot.collapsed_rot
	print("Next slot:",slot.position,", ",mesh,", ",rot)
	if mesh != -1:
		set_cell_item(slot.position,mesh,weirdRotationTranslator[rot])
	
	restraining_stack.append(slot)
	
	#while restraining_stack.size() > 0:
	#	restrain(restraining_stack.pop_front(), prototypes)
	restrain(restraining_stack.pop_front())


func restrain(slot: new_Slot):
	#print("Restraining: ",slot,", ", slot.position, ", ", slot.possible_prototypes.size())
	
	var n = 0
	for direction in DIRECTIONS:
		var x = slot.position.x + direction.x
		var z = slot.position.z + direction.z
		
		if x < 0 or z < 0 or x >= xRange or z >= zRange:
			continue
		
		var neighbour : new_Slot = grid[x][z]
		
		if neighbour.collapsed:
			continue
		
		var neighbour_meshes = slot.possible_prototypes[0].neighbours[n]
		
		var neighbour_prototypes: Array[new_Prototype]
		
		# Converting the neighbour meshes into the possible prototypes
		for mesh in neighbour_meshes:
			if mesh >= 0 and mesh < prototypes.size():
		# !!!!!!! Needs to append all rotations aka mesh, mesh + size, mesh + size*2 ... Got it :)
				for i in 4:
					var p: new_Prototype = prototypes[mesh*4+i]
					if slot.possible_prototypes[0].mesh in p.neighbours[(n+2)%4]:
						neighbour_prototypes.append(p)
				
				#neighbour_prototypes.append(prototypes[mesh*4+0])
				#neighbour_prototypes.append(prototypes[mesh*4+1])
				#neighbour_prototypes.append(prototypes[mesh*4+2])
				#neighbour_prototypes.append(prototypes[mesh*4+3])
			elif mesh == -1:
				neighbour_prototypes.append(prototypes[prototypes.size()-1])
			else:
				print("Nonexistent mesh outside of prototype range! ",mesh)
		
		var entropy_before = neighbour.possible_prototypes.size()
		
		neighbour.restrict_prototypes(neighbour_prototypes)
		
		var entropy_after = neighbour.possible_prototypes.size()
		
		#FOR TESTING
		#neighbour.possible_prototypes[0]
		
		if entropy_after == 0:
			print("uh oh!")
			retry()
		elif entropy_after < entropy_before:
			restraining_stack.append(neighbour) 
		
		n += 1
		
		timer.start()

func get_lowest_entropy_slot():
	var lowest_entropy = INF
	var lowest_entropy_slot = null
	for row in grid:
		for slot in row:
			if slot.possible_prototypes.size() < lowest_entropy and not slot.collapsed:
				lowest_entropy = slot.possible_prototypes.size()
				lowest_entropy_slot = slot
				#print("Lower entropy: ", lowest_entropy,", ",lowest_entropy_slot.position)
	return lowest_entropy_slot



func retry():
	clear()
	work(original_prototypes)

func clear():
	restraining_stack.clear()
	grid.clear()
	prototypes.clear()

func _on_timer_timeout():
	timed_iteration += 1
#	if timed_iteration < zRange * xRange:
#		collapse()
#	else:
#		finished_scan()
