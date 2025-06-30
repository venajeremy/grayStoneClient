extends RigidBody3D

var syncPosition
var syncRotation

var movementSpeed = 5000
var rotationSpeed
var rotationVector

func _ready():
	
	if multiplayer.is_server():
		rotationSpeed = randi()%500
		rotationVector = Vector3(randi(),randi(),randi()).normalized() * rotationSpeed
		apply_force(Vector3(0,0,-movementSpeed))
		apply_torque(rotationVector)

func _physics_process(delta):
	if multiplayer.is_server():
		syncPosition = position
		syncRotation = transform.basis
	else:
		if abs((position-syncPosition).length()) > 2: # Motion desync
			position = syncPosition
		if _beyond_rotation_desync_limit(0.1, transform.basis, syncRotation): # Rotation desync
			transform.basis = syncRotation

func _beyond_rotation_desync_limit(desyncLimit, local, remote):
	if(local.x.normalized().cross(remote.x.normalized()).length() > desyncLimit):
		return true
	if(local.y.normalized().cross(remote.y.normalized()).length() > desyncLimit):
		return true
	if(local.z.normalized().cross(remote.z.normalized()).length() > desyncLimit):
		return true
	return false
