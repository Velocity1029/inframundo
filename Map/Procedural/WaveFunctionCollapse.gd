extends Node3D

@export var processor : WFCProcessor
@export var output : GridMap
@export var originX = 0
@export var originY = 0
@export var xRange = 40
@export var zRange = 40
@export var tile_size = 3

var grid = []
var collapsed = []
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
		pass
		#var data = processor.process_reference()
		#work(data)
		
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
		
		var start = grid[cell.x+cell.z]
		current_superposition = proto
		
		start = start.filter(has_matching_mesh)#?
		grid[cell.x+cell.z] = start
		print(start)
		
		next_tile = start
		next_tile_position = (cell.x * tile_size) + cell.z
		next_tile_len = len(start)
		for a in 300:
		#while(next_tile != null):
			next_tile_len = INF
			collapse(next_tile, next_tile_position)
			pick_next_tile()
	

func setup_superposition(data):
	var superposition = []
	for p in data:
		superposition.append(p)
	print(superposition)
	for x in xRange:
		for z in zRange:
			grid.append(superposition)
			collapsed.append(false)

func collapse(node, pos):
	print("Collapse", pos)
	var x = pos/tile_size
	var z = pos%tile_size
	# Positive Adjacency constraining
	for i in tile_size:
		for j in tile_size:
			if i == 0 and j == 0: continue
			else: 
				current_superposition = node
				relative_position = i * tile_size + j
				
				if x+i < xRange and z+j < zRange:
					var index = x+i+z+j
					var old_neighbour = grid[index].duplicate()
					var new_neighbour = restrict_neighbour(old_neighbour)
					if !collapsed[index]: #old_neighbour != new_neighbour and len(old_neighbour) != 1 and 
						#collapsed[index] = true
						grid[index] = new_neighbour
						
						print(index, " - ", len(new_neighbour), " : ", next_tile_len)
						if len(new_neighbour) < next_tile_len and len(new_neighbour) > 0:
							next_tile = new_neighbour
							next_tile_len = len(new_neighbour)
							next_tile_position = index
							print("NEW NEXT: ",next_tile," ",next_tile_position)
							
						collapse(grid[index], index)

				if x-i > -1 and z-j > -1:
					var index = x-i+z-j
					var old_neighbour = grid[index].duplicate()
					var new_neighbour = restrict_neighbour(old_neighbour)
					if !collapsed[index]: #old_neighbour != new_neighbour and len(old_neighbour) != 1 and 
						#collapsed[index] = true
						grid[index] = new_neighbour
						
						print(index, " - ", len(new_neighbour), " : ", next_tile_len)
						if len(new_neighbour) < next_tile_len and len(new_neighbour) > 0:
							next_tile = new_neighbour
							next_tile_len = len(new_neighbour)
							next_tile_position = index
							print("NEW NEXT: ",next_tile," ",next_tile_position)
						
						if old_neighbour != new_neighbour:
							collapse(grid[index], index)
			
			#if new_positive_neighbour != positive_neighbour:
			#	grid[x+i][z+j] = new_neighbour
			#	
			#	if len(new_neighbour) < next_tile_len:
			#		next_tile = new_neighbour
			#		next_tile_len = len(new_neighbour)
			#		next_tile_position = pos
				#Likely inefficient ?
			#	collapse(new_neighbour, Vector3(x+i, 0, z+j))
				

func restrict_neighbour(neighbour):
	print("RESTRICT NEIGHBOUR")
	var new_neighbour = neighbour.filter(is_possible_neighbour)
	if len(new_neighbour) == 0: 
		printerr("No possible prototypes!")
		new_neighbour = [Prototype.new()]
	return new_neighbour


func pick_next_tile():
	if next_tile == null:
		return
	var prototype = next_tile.pick_random()
	print("PICK NEXT TILE: ", next_tile_position, " ", prototype)
	if prototype == null:
		next_tile = null
		return
	prototype.print_self()
	grid[next_tile_position] = [prototype]
	collapsed[next_tile_position] = true
	output.set_cell_item(Vector3(next_tile_position/tile_size, 0, next_tile_position%tile_size),prototype.mesh,prototype.rotation)
	collapse(next_tile, next_tile_position)

##### NEED TO FILTER THE PROTOTYPES WHICH DO NOT OCCUR IN POSSIBILITIES OF THE CURRENT SUPERPOSITIOn IN THAT NEIGHBOUR
# Relative is any of meshes in array of prototypes
func is_possible_neighbour(prototype: Prototype):
	for current_prototype in current_superposition:
		# Need to have comparison of mesh AND rotation, just doing mesh for now...
		if current_prototype.neighbours[relative_position] == prototype.mesh:
		#if equivalent_mesh(prototype, current_prototype):
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
