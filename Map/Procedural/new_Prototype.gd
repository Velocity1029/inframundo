class_name new_Prototype

var mesh : int
var rotation : int
var weight : int
var neighbours = [
	#x  z -x -z  y -y
	[],[],[],[],[],[]
]
var position : Vector3

func _init(mesh:int = -1,
	rotation : int = 0,
	weight : int = 1,
	):
	
	self.mesh = mesh
	self.rotation = rotation
	self.weight = weight
	
func add_neighbour(socket:int, neighbour):
	if neighbour not in neighbours[socket]:
		neighbours[socket].append(neighbour)
	
func set_mesh(mesh:int, rotation:int = 0, weight:int = 1):
	self.mesh = mesh
	self.rotation = rotation
	self.weight = weight
	
func set_neighbours(n):
	neighbours = n
	
func print_self():
	print("Mesh: ", mesh,", Rotation: ", rotation, ", Weight: ", weight, ", Position: ", position)
	print("Neighbours: ", neighbours)

func duplicate():
	var duplicate = new_Prototype.new(self.mesh, self.rotation, self.weight)
	duplicate.set_neighbours(self.neighbours)
	
	return duplicate
