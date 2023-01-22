extends Node3D

class_name Holder

var heldObject = null

func setHeldObject(obj):
	heldObject = obj
	
func thrown():
	heldObject = null

func getHeldObject():
	return heldObject
