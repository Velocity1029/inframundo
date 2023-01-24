extends Node3D

class_name WFCProcessor

@export var reference : GridMap
@export var ray : RayCast3D
@export var pointer : MeshInstance3D
@export var space : Area3D
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
var xRange = 20
var yRange = 20
var zRange = 20
var xOffset = 0
var yOffset = 0
var zOffset = 0
var currentRotation = 0

var neighbours = []
var prototypes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if centerX:
		xOffset = nodeSizeX / 2
	if centerY:
		yOffset = nodeSizeY / 2
	if centerZ:
		zOffset = nodeSizeZ / 2
	
	prototypes.append(Prototype.new())
	
	for i in xRange:
		var a = []
		for j in zRange:
			var b = []
			a.append(b)
		neighbours.append(a)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func process_reference():
	# If rotations are enabled scan the grid 4 times, for each rotation of the grid
	if rotations:
		for rots in 4:
			# CANNOT CURRENTLY DO MIRRORS EASILY
			#if mirrors:
			#	for mirror_scale in MIRRORS:
			#		reference.scale = mirror_scale
			#		assign_prototypes()
			#else:
				reference.rotate(Vector3(0, 1, 0), 1/2)
				currentRotation = rots
				assign_prototypes()
	else:
		assign_prototypes()
	
	
	
	return prototypes

func assign_prototypes():
	for x in xRange:
		for z in zRange:
			var pos = Vector3(x * nodeSizeX, 0, z * nodeSizeZ)
			pointer.position = pos
			var cell = to_map(pos)
			var node = reference.get_cell_item(cell)
			var rot = reference.get_cell_item_orientation(cell) / 6
			#print(node, " : ", rot, " ", currentRotation)
			#mark_neighbours(node, x, z)
			if node != -1:
				
				var prototype = Prototype.new(node, (rot+currentRotation)%4, 1, cell)
				prototype.set_neighbours(get_neighbours(x, z))
				
				#prototype.print_self()
				
				append_prototype(prototype)

func mark_neighbours(node, x, z):
	for i in tile_size:
		for j in tile_size:
			if x+i >= xRange or z+j >= zRange or (i == 0 and j == 0):
				continue
			neighbours[x+i][z+j].append(node)

func get_neighbours(x, z):
	var node_neighbours = []
	node_neighbours.resize(9)
	for i in tile_size:
		for j in tile_size:
			if x+i >= xRange or z+j >= zRange:
				continue
			node_neighbours[i*tile_size + j] = reference.get_cell_item(to_map(Vector3((x+i) * nodeSizeX, 0, (z+j) * nodeSizeZ)))
			
	return node_neighbours
	
func append_prototype(prototype):
	prototypes.append(prototype)
		

func rotate_prototype(prototype):
	pass

func to_map(v):
	return reference.local_to_map(reference.to_local(v))
