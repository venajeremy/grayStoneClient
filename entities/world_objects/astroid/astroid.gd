extends CharacterBody3D

var syncPosition
var syncRotation

var movementSpeed = 100
var rotationSpeed
var rotationAxis

func _ready():
	if multiplayer.is_server():
		velocity = Vector3(0,0,-movementSpeed)
		rotationSpeed = randi()%50
		rotationAxis = Vector3(randi(),randi(),randi()).normalized()

func _process(delta):
	pass
	
func _physics_process(delta):
	rotate(rotationAxis, deg_to_rad(rotationSpeed)*delta)
	move_and_slide()
	if multiplayer.is_server():
		syncPosition = position
		syncRotation = transform.basis
	else:
		if abs(position.length()-syncPosition.length()) > 2: # Motion desync
			position = syncPosition
		if _beyond_rotation_desync_limit(0.1): # Rotation desync
			print("hit")
			transform.basis = syncRotation

func _beyond_rotation_desync_limit(desyncLimit):
	if(transform.basis.x.normalized().cross(syncRotation.x.normalized()).length() > desyncLimit):
		return true
	if(transform.basis.y.normalized().cross(syncRotation.y.normalized()).length() > desyncLimit):
		return true
	if(transform.basis.z.normalized().cross(syncRotation.z.normalized()).length() > desyncLimit):
		return true
	return false
