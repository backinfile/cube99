extends Node
class_name GameLogic

static var random = RandomNumberGenerator.new()
static var history = []
const MOVE_INTERVAL = 0.13

static func init():
	history.clear()

static func move(dx: int, dy: int):
	var gameMap = Game.gameMap
	var player = gameMap.getPlayerElement()
	var x = player.x + dx
	var y = player.y + dy
	if not gameMap.inMapArea(x, y):
		doShake(player, dx, dy)
		return
	var e = gameMap.getElement(x, y)
	if e == null:
		print("move %d,%d to %d,%d" % [dx, dy, x, y])
		startMove()
		doMove(player, x, y, player.x, player.y)
		return
	if e.type == Element.Type_Box:
		var nextX = x + dx
		var nextY = y + dy
		var nextE = gameMap.getElement(nextX, nextY)
		if gameMap.inMapArea(nextX, nextY) and nextE == null:
			startMove()
			doMove(e, nextX, nextY, x, y)
			doMove(player, x, y, player.x, player.y)
			return
	doShake(player, dx, dy)

static func startMove():
	history.append([])
	Game.instance.set_process(false)
	var tween = Game.instance.create_tween()
	tween.tween_interval(MOVE_INTERVAL)
	tween.tween_callback(func ():Game.instance.set_process(true))
	
static func doMove(e: Element, x:int, y:int, oriX:int, oriY:int, record_history = true):
	var gameMap = Game.gameMap
	gameMap.removeElement(e)
	gameMap.setElement(e, x, y)
	var p = ElementNode.getUIPosition(x, y)
	if record_history:
		var tween = e.node.create_tween()
		tween.tween_property(e.node, "position", p, MOVE_INTERVAL)
		history[-1].append([e, oriX, oriY])
	else:
		e.node.position = p

static func back():
	if not history.is_empty():
		var h = history.pop_back()
		for action in h:
			doMove(action[0], action[1], action[2], 0, 0, false)
	
static func doShake(e: Element, dx = 1, dy = 1):
	var p = ElementNode.getUIPosition(e.x, e.y)
	var x = p.x
	var y = p.y
	var tween = e.node.create_tween()
	var randomSetPosition = func (value):
		e.node.position.x = x + random.randf_range(-4, 4) * dx
		e.node.position.y = y + random.randf_range(-4, 4) * dy
	tween.tween_method(randomSetPosition, 0, 100, 0.2)
	tween.tween_callback(func (): e.node.position = p)

	
