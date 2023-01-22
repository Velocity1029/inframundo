extends CharacterBody3D

@onready var gunRay = $Head/Camera3d/RayCast3d as RayCast3D
@onready var Cam = $Head/Camera3d as Camera3D
@onready var Collider = $CollisionShape3d as CollisionShape3D
@export var _bullet_scene : PackedScene
@export var Hand : Holder
@export var Inv : Inventory
var mouseSensibility = 200
var mouse_relative_x = 0
var mouse_relative_y = 0
var speed
var crouching = false
var sprinting = false
var walking = false
const SPEED = 3.0
const SPRINT_MULT = 2
const WALK_MULT = 0.3
const CROUCH_MULT = 0.6
const JUMP_VELOCITY = 4.5
const THROW_STRENGTH = 5
const STANDING_HEIGHT = 2
const CROUCH_HEIGHT = 1
const REACH = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#Captures mouse and stops rgun from hitting yourself
	gunRay.add_exception(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	speed = SPEED
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# DETACH.
	if Input.is_action_just_pressed("Detach"):
		Cam.position.z = 2
		Cam.position.y = 1

	# Handle Jump.
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Handle Shooting
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	# Handle Throwing
	if Input.is_action_just_pressed("Throw"):
		throw()
	# Handle Crouch
	if Input.is_action_just_pressed("Crouch") and is_on_floor() and !crouching:
		crouch()
	if Input.is_action_just_released("Crouch"):
		stop_crouch()
	# Handle Sprint
	if Input.is_action_just_pressed("Sprint") and !crouching:
		sprint()
	if Input.is_action_just_released("Sprint"):
		stop_sprint()
	# Handle Walk
	if Input.is_action_just_pressed("Walk"):
		walk()
	if Input.is_action_just_released("Walk"):
		stop_walk()
	if Input.is_action_just_released("Swap"):
		swap_item()
		
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():
	if not gunRay.is_colliding():
		return
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_parent().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point()+gunRay.get_collision_normal()),Vector3.BACK)

func crouch():
	stop_sprint()
	crouching = true
	speed *= CROUCH_MULT
	Collider.shape.height = CROUCH_HEIGHT
	
func stop_crouch():
	crouching = false
	speed = SPEED
	Collider.shape.height = STANDING_HEIGHT
	
func sprint():
	sprinting = true
	speed *= SPRINT_MULT
	
func stop_sprint():
	sprinting = false
	speed = SPEED
	
func walk():
	stop_sprint()
	walking = true
	speed *= WALK_MULT
	
func stop_walk():
	walking = false
	speed = SPEED


# ITEM HANDLING

func pickup(item):
	if Inv.isFull():
		return false
	Inv.addItem(item)
	item.hide()
	
	equip(item)
	
func drop(item):
	Inv.removeItem(item)

func equip(item):
	if Hand.getHeldObject() == null:
		print("Equipping %s" % item)
		
		item.set_freeze_enabled(true)
		
		item.setHeld(Hand)
		Hand.setHeldObject(item)
		
		item.show()
		return true
	return false

func throw():
	var item = Hand.getHeldObject()
	if item != null:
		print("Throwing %s" % item)
		
		item.set_freeze_enabled(false)
		
		item.thrown()
		Hand.thrown()
		item.apply_impulse(-1 * Cam.global_transform.basis.z * THROW_STRENGTH)
		
		drop(item)
		
		return true
	return false
	
func swap_item():
	print("Swapping")
	var item = Inv.swapItem()
	
	if item != null:
		Hand.getHeldObject().hide()
		item.setHeld(Hand)
	
		item.show()
		
	Hand.setHeldObject(item)



