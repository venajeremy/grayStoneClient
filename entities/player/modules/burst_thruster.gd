extends shipModule

func _ready():
	useCount = 3
	regenTime = 0.15
	currentCharge = 1
	health = 1

func _use():
	print("burstThruster is used")
