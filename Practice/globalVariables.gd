extends Node

const BASIC_ROUTE_MODIFIER = 32

func _ready():
	pass

class routeClass:
	var points = []
	var currentPointIdx
	var looped = false
	func clearRoute ():
		points.clear ()
		currentPointIdx = 0
		looped = false
	func addPoint (newPoint):
		points.append (newPoint)
	func nextPoint ():
		if currentPointIdx + 1 < points.size ():
			currentPointIdx += 1
		else:
			if looped == true:
				currentPointIdx = 0
			else:
				return false
		return true
	func getTarget ():
		return points [currentPointIdx]
	func updateCurrentPoint (newPoint):
		points [currentPointIdx] = newPoint
	func modifyRoute (modifier):
		if currentPointIdx == 0:
			return
		else:
			#print ("route modified")
			if points [currentPointIdx - 1] <= points [currentPointIdx]:
				points [currentPointIdx] -= modifier
				if (currentPointIdx == points.size () - 1):
					return
				for i in range (currentPointIdx + 1, points.size ()):
					if points [currentPointIdx - 1] <= points [i]:
						points [i] = points [currentPointIdx]
			elif points [currentPointIdx - 1] >= points [currentPointIdx]:
				points [currentPointIdx] += modifier
				if (currentPointIdx == points.size () - 1):
					return
				for i in range (currentPointIdx + 1, points.size ()):
					if points [currentPointIdx - 1] >= points [i]:
						points [i] = points [currentPointIdx]

# # ITEMS
# # ...

var currentHP = 10
var currentMP = 10
var hasBottle = false

func save_wizzard (wizzard):
	currentHP = wizzard.currentHP
	currentMP = wizzard.currentMP
	hasBottle = wizzard.getBottleState ()












