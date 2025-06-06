extends Node3D
@export var vortex_center := Vector3.ZERO #Unit vector 0 magnitude
@export var strength := 5.0 #Arbitrary scalar
@export var inward_pull := 0.2  # Optional inward attraction (Arb scalar)
#Spiral With Height variation
func get_spiral_vector(position: Vector3) -> Vector3: 
#"postion:" specifies WHAT TYPE we can input, "->" signifies WHAT TYPE will be output

	var offset = position - vortex_center
	#Take the POSTION of an object in the vect field, subtract. This gives us
	#a vector that points FROM the object TO the center (UNIT VECTOR!!)

	var radial_distance = Vector2(offset.x, offset.z).length()
	#A variable that outputs the MAGNITUDE of a radius vector (THE RADIUS!!)
	# Base swirling in XZ plane
	
	var tangent = Vector3(-offset.z, 0, offset.x).normalized()
	# This is a shortcut for taking the cross-product! 
	#The TANGENT is the vector perpendicular to the radial vector
	
	var vertical = Vector3(0, 1, 0) * 0.5
	# A vertial vector pointing UP by *0.5 magnitude!
	
	return (tangent + vertical).normalized() * strength * radial_distance
	# This is our function output! Notice if we combine tangent + vertical
	# We get a vector that is pointing between up and the tangent
	#Imagine this as an orbital ring rotated its focal point
	
	
