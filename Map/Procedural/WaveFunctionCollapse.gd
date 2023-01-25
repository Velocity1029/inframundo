extends Node3D

@export var processor : WFCProcessor
@export var output : GridMap
@export var originX = 0
@export var originY = 0
@export var xRange = 40
@export var zRange = 40
@export var tile_size = 3

var grid = []
# Used for recursive collapsing
var current_superposition
var relative_position
var next_tile = null
var next_tile_position = null
var next_tile_len = INF

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("Shoot"):
		var data = processor.process_reference()
		work(data)
		
func work(data):
	setup_superposition(data)
	var lips = output.get_used_cells()
	print(lips)
	
	# Analyze and setup initial constraint cells
	for cell in lips:
		# Getting data
		var mesh = output.get_cell_item(cell)
		var rot = output.get_cell_item_orientation(cell) / 6
		var proto = Prototype.new(mesh, rot)
		# Assigning itself in neighbour list
		#var neighbours = []
		#neighbours.append(mesh)
		#for i in tile_size-1:
		#	neighbours.append(-1)
		#proto.set_neighbours(neighbours)
		
		var start = grid[cell.x][cell.z]
		current_superposition = proto
		
		start = start.filter(has_matching_mesh)#?
		grid[cell.x][cell.z] = start
		print(start)
		
		next_tile = start
		next_tile_position = Vector3(cell.x,0,cell.z)
		next_tile_len = len(start)
		
		while(next_tile != null):
			collapse(next_tile, next_tile_position)
			pick_next_tile()
	

func setup_superposition(data):
	var superposition = []
	for p in data:
		superposition.append(p)
	print(superposition)
	for x in xRange:
		var a = []
		for z in zRange:
			a.append(superposition)
		grid.append(a)

func collapse(node, pos):
	var x = pos.x
	var z = pos.z
	# Positive Adjacency constraining
	for i in tile_size:
		for j in tile_size:
			if i == 0 and j == 0: continue

			current_superposition = node
			relative_position = i * tile_size + j
			
			if x+i < xRange and z+j < zRange:
				var positive_neighbour = grid[x+i][z+j]
				var new_positive_neighbour = positive_neighbour.filter(is_possible_neighbour)
				if len(new_positive_neighbour) == 0: printerr("No possible prototypes!")

			if x-i > -1 and z+j > -1:
				var negative_neighbour = grid[x-i][z-j]
				var new_negative_neighbour = negative_neighbour.filter(has_current_node)
			
			
			#if new_neighbour != positive_neighbour:
			#	grid[x+i][z+j] = new_neighbour
			#	
			#	if len(new_neighbour) < next_tile_len:
			#		next_tile = new_neighbour
			#		next_tile_len = len(new_neighbour)
			#		next_tile_position = pos
				#Likely inefficient ?
			#	collapse(new_neighbour, Vector3(x+i, 0, z+j))
				

func pick_next_tile():
	var prototype = next_tile.pick_random()
	prototype.print_self()
	grid[next_tile_position.x][next_tile_position.z] = [prototype]
	next_tile_len = INF
	collapse(next_tile, next_tile_position)

##### NEED TO FILTER THE PROTOTYPES WHICH DO NOT OCCUR IN POSSIBILITIES OF THE CURRENT SUPERPOSITIOn IN THAT NEIGHBOUR
# Relative is any of meshes in array of prototypes
func is_possible_neighbour(prototype: Prototype):
	for current_prototype in current_superposition:
		if equivalent_mesh(prototype, current_prototype):
			return true
	return false
	

func has_current_node(prototype : Prototype):
	for current_prototype in current_superposition:
		if prototype.neighbours[relative_position] == current_prototype:
			return true
	return false

func has_matching_mesh(prototype : Prototype):

	if equivalent_mesh(prototype, current_superposition):
		print(prototype.mesh, " :)")
		return true

	return false

func equivalent_mesh(p1, p2):
	return p1.mesh == p2.mesh and p1.rotation == p2.rotation

func to_map(v):
	return output.local_to_map(output.to_local(v))
