class_name Prototype

var mesh : int
var rotation : int
var sockets = {
	"posX" : "-1",
	"negX" : "-1",
	"posY" : "-1",
	"negY" : "-1",
	"posZ" : "-1",
	"negZ" : "-1"
}
var weight : int
var neighbours = [-1,-1,-1,-1,-1,-1,-1,-1,-1,]
var position : Vector3

func _init(mesh:int = -1,
	rotation : int = 0,
	weight : int = 1,
	position : Vector3 = Vector3(),
	):
	
	self.mesh = mesh
	self.rotation = rotation
	self.sockets = {}
	self.weight = weight
	self.position = position
	
func set_sockets(x:String = "-1", x2:String = "-1", y:String = "-1", y2:String = "-1", z:String = "-1", z2:String = "-1"):
	sockets.posX = x
	sockets.negX = x2
	sockets.posY = y
	sockets.negY = y2
	sockets.posZ = z
	sockets.negZ = z2
	
func set_neighbours(n):
	neighbours = n
	
func print_self():
	print("Mesh: ", mesh,", Rotation: ", rotation, ", Weight: ", weight)
	print("Sockets: ", sockets)
	print("Neighbours: ", neighbours)
