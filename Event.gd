
extends Node

enum Event_Key {
	PLAYER_DEATH
}

func fire(key:Event_Key, node : Node, args):
	print('fire node')
	
	
func register(key: Event_Key, method):
	pass
	
