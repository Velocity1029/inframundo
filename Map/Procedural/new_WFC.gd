extends GridMap

class_name new_WFC

@export var output : Node3D
@export var pointer : MeshInstance3D
@export var rotations = true
@export var mirrors = true
@export var centerX = true
@export var centerY = true
@export var centerZ = true
@export var nodeSizeX = 1
@export var nodeSizeY = 1
@export var nodeSizeZ = 1
@export var tile_size = 3
const OFFSET = 0.5
const MIRRORS = [Vector3(1,1,1),Vector3(-1,1,1),Vector3(1,1,-1),Vector3(-1,1,-1)]
const DIRECTIONS = [Vector3(1,0,0),Vector3(0,0,1),Vector3(-1,0,0),Vector3(0,0,-1)]
var xRange = 20
var yRange = 20
var zRange = 20
var xOffset = 0
var yOffset = 0
var zOffset = 0
var currentRotation = 0

const weirdRotationTranslator = {-1:0, 0:0, 10:2, 16:3, 22:1}

var neighbours = []
var prototypes : Array[new_Prototype]
var timer := Timer.new()
@export var wait = 0.2
var timed_iteration = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	if centerX:
		xOffset = nodeSizeX / 2
	if centerY:
		yOffset = nodeSizeY / 2
	if centerZ:
		zOffset = nodeSizeZ / 2
	
	for i in mesh_library.get_item_list().size():
		prototypes.append(new_Prototype.new())
		prototypes.append(new_Prototype.new())
		prototypes.append(new_Prototype.new())
		prototypes.append(new_Prototype.new())
	
	# EMPTY PROTOTYPE ( will take -1 mesh cells )
	prototypes.append(new_Prototype.new())
		
	add_child(timer)
	timer.wait_time = wait
	timer.one_shot = true


func process_self():
	# If rotations are enabled scan the grid 4 times, for each rotation of the grid
	#if rotations:
	#	for rots in 4:
			# CANNOT CURRENTLY DO MIRRORS EASILY
			#if mirrors:
			#	for mirror_scale in MIRRORS:
			#		scale = mirror_scale
			#		assign_prototypes()
			#else:
	#			rotate(Vector3(0, 1, 0), 1/2)
	#			currentRotation = rots
	#			assign_prototypes()
	#	return prototypes
	#else:
		assign_prototypes_delayed()
	
	
	

#func assign_prototypes():
#	for x in xRange:
#		for z in zRange:
#			var pos = Vector3(x * nodeSizeX, 0, z * nodeSizeZ)
#			pointer.position = pos
#			var cell = to_map(pos)
#			var node = get_cell_item(cell)
#			var rot = weirdRotationTranslator[get_cell_item_orientation(cell)]
#
#			if node != -1:
#				#if prototypes[node].mesh != -1:
#
#
#				# Set up four rotations
#				prototypes[(node*4)+0].set_mesh(node, 0)#(rot+currentRotation)%4)
#				prototypes[(node*4)+1].set_mesh(node, 1)
#				prototypes[(node*4)+2].set_mesh(node, 2)
#				prototypes[(node*4)+3].set_mesh(node, 3)
#
#				add_neighbours(pos, node, rot)
#			else:
#
#				#prototypes[prototypes.size()].set_mesh(node, 0)#(rot+currentRotation)%4)
#				# If empty, add the neighbours to the last entry in prototypes, an extra entry for this purpose
#				add_neighbours(pos, prototypes.size()-1, rot)

func assign_prototypes_delayed():
	timer.connect("timeout", _on_timer_timeout)
	assign_prototype_callback(0, 0)

	
func assign_prototype_callback(x, z):
	var pos = Vector3(x * nodeSizeX, 0, z * nodeSizeZ)
	pointer.position = pos
	var cell = to_map(pos)
	var node = get_cell_item(cell)
	var rot = weirdRotationTranslator[get_cell_item_orientation(cell)]
	
	#print(node, ", ", get_cell_item_orientation(cell))

	if node != -1:
		#if prototypes[node].mesh != -1:
		var mat = pointer.get_surface_override_material(0)
		mat.albedo_color = Color(0,1,0.2,1)
		pointer.set_surface_override_material(0, mat)
		
		# Set up four rotations
		prototypes[(node*4)+0].set_mesh(node, 0)#(rot+currentRotation)%4)
		prototypes[(node*4)+1].set_mesh(node, 1)
		prototypes[(node*4)+2].set_mesh(node, 2)
		prototypes[(node*4)+3].set_mesh(node, 3)

		#print(pos,", ", node,", ", rot)
		add_neighbours(pos, node*4, rot)
	else:
		var mat = pointer.get_surface_override_material(0)
		mat.albedo_color = Color(1,1,1,1)
		pointer.set_surface_override_material(0, mat)
		
		add_neighbours(pos, prototypes.size()-1, 0)
	timer.start()


func _on_timer_timeout():
	timed_iteration += 1
	if timed_iteration < zRange * xRange:
		assign_prototype_callback(timed_iteration / zRange, timed_iteration % zRange)
	else:
		finished_scan()



func add_neighbours(pos, node, rot):
	# For each of the cardinal directions
	for i in DIRECTIONS.size():
		# Normalize direction with resident's rotation
		var direction = DIRECTIONS[(i+rot)%DIRECTIONS.size()]
		# Get the neighbour in that direction
		var neighbour_position = pos + (direction * 2)#!!!!Vector3(nodeSizeX,nodeSizeY,nodeSizeZ))
		var neighbour_node = get_cell_item(to_map(neighbour_position))
		var neighbour_rot = weirdRotationTranslator[get_cell_item_orientation(to_map(neighbour_position))]
		
		#if node== 32*4: print("Node:",neighbour_node," d:",(i+rot)%DIRECTIONS.size()," i:",i,", rot:",rot,", OGRotation:",get_cell_item_orientation(to_map(pos)))
		# Normalize it to a zero rotation resident node (posmod allows for negative modulus operations)
		var _normalized_rotation = (abs(neighbour_rot - rot) % 4)
		
		#if node == 41: print(posmod(i - rot, 4)," - i:",i,", rot:",rot)
		# Add it as a neighbour to the zero rotation prototype of the resident node
		prototypes[node].add_neighbour(i, neighbour_node)#{"node": neighbour_node, "rotation": neighbour_rot})
		#(posmod(i - rot, 4), {"node": neighbour_node, "rotation": normalized_rotation})
		

func finished_scan():
	if rotations:
		for prototype in int((prototypes.size()-1)/4):
			var neighbours_copy = prototypes[prototype*4].neighbours
			for i in range(1, 4):
				# Rotate the neighbours around once for each loop
				neighbours_copy = [neighbours_copy[3],neighbours_copy[0],neighbours_copy[1],neighbours_copy[2]]
				# Set the neighbours of prototype to the rotated set
				prototypes[prototype*4+i].set_neighbours(neighbours_copy)
	
	output.work(prototypes)

func rotate_prototype(prototype):
	pass

func to_map(v):
	return local_to_map(to_local(v))
