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
var current_node
var relative_position
var next_tile = null
var next_tile_len = INF

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("Shoot"):
		var data = processor.process_reference()
		print(data[1].neighbours)
		work(data)
		
func work(data):
	setup_superposition(data)
	var lips = output.get_used_cells()
	print(lips)
	
	for lip in lips:
		grid[lip.x][lip.z] = output.get_cell_item(to_map(lip))
		collapse(grid[lip.x][lip.z], lip.x, lip.z)
	

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

func collapse(node, x, z):
	for i in tile_size:
		for j in tile_size:
			if i == 0 and j == 0 or node is float: continue
			current_node = node
			relative_position = i * tile_size + j
			var neighbour = grid[x+i][z+j]
			#print(grid)
			print(neighbour)
			neighbour.filter(has_current_node)
			if len(neighbour) < next_tile_len:
				next_tile = neighbour
				next_tile_len = len(neighbour)

func has_current_node(node):
	print(node)
	if node.neighbours[relative_position] == current_node:
		return true
	#collapse(node, )
	return false

func to_map(v):
	return output.local_to_map(output.to_local(v))
