extends CharacterBody3D

# Ship Parameters
# Movement
const speed = 400
const accelerationDecayRate = 3
const velocityCap = 700
const accelerationCap = 100
const straifeMultiplier = 0.75
# BurstThruster
const thrusterBoostSpeed = 400
# Mouse
const sensitivity = -0.04
const rotationSensitivity = -5
const zoomSensitivity = 3
# Weapons
const basicLaserDamage = 20
# Health
const maxHealth = 100

# Server Input Array
var syncInput = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false]

# Server Sync Variables
var id
var syncPosition = Vector3()
var syncRotation = Vector3()
var timeSync = 0
var ping = 0

# Physics Variables 
var acceleration = Vector3()
var angularVelocity = Vector3()
var angularAcceleration = Vector3()

# Ship Utility Creation
var burstThruster = load("res://entities/player/modules/burst_thruster/burst_thruster.tscn").instantiate()

# Ship Utility Slots
var utilityBack = [null, null]
var utilityFront = [null, null]
var utilitySide = [null, null]
var utilityPositions = [utilityBack, utilityFront, utilitySide]

# Ship Components
@onready var aimRay = $AimRay
@onready var cam = $Camera3D
@onready var guns = $Guns.get_children()
var gunSelected = 0
@onready var gunCount = guns.size()

# Health
@onready var health = maxHealth

# UI
@onready var shipUI = $ShipUi

# Animations
@onready var gunAnim = $Animations/Gun
@onready var thrusterAnim = $Animations/Thruster
@onready var hitAnim = $Animations/Hit

# Sounds
@onready var shipAudio = $shipAudio

# Gun Sounds
const laser1 = preload("res://audio/wasp/gun/gun1.wav")
const laser2 = preload("res://audio/wasp/gun/gun2.wav")
const laser3 = preload("res://audio/wasp/gun/gun3.wav")
const laser4 = preload("res://audio/wasp/gun/gun4.wav")
# Movement Audio
const thruster = preload("res://audio/wasp/movement/thruster.wav")
const speedThruster = preload("res://audio/wasp/movement/thruster2.wav")
# Bullets
var bullet = load("res://entities/weapon_projectiles/basic_bullet/bullet.tscn")
var instance

func _enter_tree():
	id = name.to_int()
	$PeerInputSync.set_multiplayer_authority(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Setup Multiplayer Control - This doesn't seem competitively safe
	cam.current = $PeerInputSync.is_multiplayer_authority()
	shipUI.visible = $PeerInputSync.is_multiplayer_authority()
	shipUI.Health.max_value = maxHealth
	shipUI.Health.value = health
	
	# Window Mouse Mode
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Equipt Ship Utility
	utilityBack[0] = burstThruster

func _input(event):
	if !$PeerInputSync.is_multiplayer_authority():
		return
	
	if event is InputEventMouseMotion:
		rotate_object_local(Vector3(0,1,0),deg_to_rad(event.relative.x * sensitivity))
		rotate_object_local(Vector3(1,0,0),deg_to_rad(event.relative.y * sensitivity))


func _physics_process(delta):
	# Sends player input to the server
	if $PeerInputSync.is_multiplayer_authority():
		syncInput = [Input.is_action_pressed("w"),
		Input.is_action_pressed("s"),
		Input.is_action_pressed("d"),
		Input.is_action_pressed("a"),
		Input.is_action_pressed("space"),
		Input.is_action_pressed("ctrl"),
		Input.is_action_pressed("shift"),
		Input.is_action_pressed("q"),
		Input.is_action_pressed("e"),
		Input.is_action_pressed("lmb"),
		Input.is_action_pressed("esc"),
		Input.is_action_just_pressed("scrollup"),
		Input.is_action_just_pressed("scrolldown")]
	
	# Client will handle its own physics calculations which are updated if stray too far from server's calculation
	
	acceleration = Vector3(0,0,0)
	# Handle input
	if syncInput[0]:
		acceleration += -speed*transform.basis.z * delta
	if syncInput[1]:
		acceleration += speed*transform.basis.z * delta
	if syncInput[2]:
		acceleration += straifeMultiplier*speed*transform.basis.x * delta
	if syncInput[3]:
		acceleration += -straifeMultiplier*speed*transform.basis.x * delta
	if syncInput[4]:
		acceleration += straifeMultiplier*speed*transform.basis.y * delta
	if syncInput[5]:
		acceleration += -straifeMultiplier*speed*transform.basis.y * delta
	if syncInput[6]:
		_handle_utility(utilityBack[0])
	if syncInput[7]:
		rotate_object_local(Vector3(0,0,1),deg_to_rad(-rotationSensitivity))
	if syncInput[8]:
		rotate_object_local(Vector3(0,0,1),deg_to_rad(rotationSensitivity))
	if syncInput[9]:
		_fire_server.rpc(basicLaserDamage, id)
	if syncInput[10]:
		exit()
	if syncInput[11]:
		cam.fov -= zoomSensitivity
	if syncInput[12]:
		cam.fov += zoomSensitivity
	
	
	# Soft Acceleration cap (space friction)
	if(acceleration.length() > accelerationCap):
		acceleration = acceleration - (accelerationDecayRate*(acceleration/acceleration.length()));
	
	# Hard Velocity cap
	velocity += acceleration
	if(velocity.length() > velocityCap):
		velocity = (velocity/velocity.length())*velocityCap
	
	# Recharge Utility
	_recharge_all_utilities(delta)
	
	move_and_slide()
	
	_server_sync()

func _server_sync():
	ping = Time.get_ticks_msec() - timeSync
	timeSync = Time.get_ticks_msec()
	if(multiplayer.is_server()):
		syncPosition = position
		syncRotation = rotation
	else:
		if abs((position-syncPosition).length()) > 0.1*velocity.length(): # Motion desync
			print("Player Position Desync Correction Made!"+str(ping)+", "+str(velocity))
			#			V position on server + interpolatied position of seconds delay 2000 = ping(ms)*1000 = (s) /2 = time only from server
			position = syncPosition+(velocity*(ping/(2000)))

func exit():
	$"../".exit_game(name.to_int())
	get_tree().quit()

# Manages ship utility actions
func _handle_utility(utilityUsed):
	if utilityUsed==burstThruster:# Is burst thruster equipt?
		if !thrusterAnim.is_playing():
			if utilityUsed.currentCharge > 1.0/utilityUsed.useCount:# Do we have ammo?
				
				# Player thruster animation
				thrusterAnim.play("thruster")
				
				# Remove ammo
				utilityUsed.currentCharge -= 1.0/utilityUsed.useCount
				
				# Apply thruster boost
				acceleration = -1.0*thrusterBoostSpeed*transform.basis.z

# Manages recharging all ship utilities
func _recharge_all_utilities(delta):
	for utilityArea in utilityPositions:
		if utilityArea != null:
			for utility in utilityArea:
				_recharge_utility(utility, delta)
	_refresh_ui()

func _refresh_ui():
	shipUI.BottomLeftUtility.value = int(utilityBack[0].currentCharge * 100)

func _recharge_utility(utility, timePassed):
	if utility != null:
		if utility.currentCharge < 1.0:
			utility.currentCharge += utility.regenTime * timePassed

func _play_sound(sound):
	for player in shipAudio.get_children():
		if not player.playing:
			player.stream = sound
			player.play()
			break

@rpc("any_peer", "call_local", "reliable", 0)
func _fire_server(damage, shotBy):
	# Handle on all clients
	if !gunAnim.is_playing():
		# Play shoot sound for everyone
		gunAnim.play("shoot")
		
		# Validate hit on server
		if multiplayer.is_server():
			if aimRay.is_colliding():
				if aimRay.get_collider().is_in_group("target"):
					aimRay.get_collider().hit.rpc(damage, shotBy)
					shotConnected.rpc(shotBy)
					return true
				return false
			return false
		return false

@rpc("any_peer", "call_local", "reliable", 0)
func shotConnected(shotBy):
	if(multiplayer.get_unique_id() == shotBy):
		shipUI.hit_marker()
		hitAnim.play("strike")

@rpc("any_peer", "call_local", "reliable", 0)
func hit(damage, shotBy):
	health -= damage
	shipUI.Health.value = health
	if multiplayer.is_server():
		if(health <= 0):
			# Call the method in multiplayer to handle killing the player
			get_parent()._player_death(self, transform, velocity)

@rpc("any_peer", "call_local", "reliable", 0)
func _fire_bullet():
	if !gunAnim.is_playing():
			# Play Animation
			gunAnim.play("shoot")
			
			# Play Sound
			var rng = RandomNumberGenerator.new()
			if(rng.randi_range(0,1)==0):
				_play_sound(laser1)
			else:
				_play_sound(laser2)
			
			# Create Bullet
			instance = bullet.instantiate()
			instance.position = guns[gunSelected].global_position
			instance.transform.basis = guns[gunSelected].global_transform.basis
			
			# Cycle Which gun is firing
			gunSelected=gunSelected+1
			if(gunSelected>=gunCount):
				gunSelected=0;
			
			get_parent().add_child(instance, true)
