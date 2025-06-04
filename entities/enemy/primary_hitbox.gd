extends Area3D

signal damaged

func hit():
	damaged.emit()
