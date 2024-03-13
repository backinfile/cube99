extends Node
class_name Step

var e: Element
var from: Vector2
var to: Vector2

func _init(e: Element, from: Vector2, to: Vector2):
	self.e = e
	self.from = from
	self.to = to
