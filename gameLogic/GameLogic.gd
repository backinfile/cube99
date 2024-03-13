extends Node
class_name GameLogic

static var random = RandomNumberGenerator.new()
static var history = []
const MOVE_INTERVAL = 0.13

static func init():
	history.clear()

static func move(dx: int, dy: int):
	var gameMap = Game.gameMap
	var steps = findMovePath(gameMap, dx, dy)
	var player = gameMap.getPlayerElement()
	if steps.is_empty():
		doShake(player, dx, dy)
	else:
		doMove(steps, false, true)
	
static func findMovePath(gameMap:GameMap, dx:int, dy:int) -> Array[Step]:
	var player = gameMap.getPlayerElement()
	var playerPos = gameMap.getElementPos(player)
	var x = playerPos.x + dx
	var y = playerPos.y + dy
	if not gameMap.inMapArea(x, y):
		return []
	var e = gameMap.getElement(x, y)
	if e == null:
		return [Step.new(player, Vector2(playerPos), Vector2(x, y))]
	if e.type == Element.Type_Box:
		var nextX = x + dx
		var nextY = y + dy
		var nextE = gameMap.getElement(nextX, nextY)
		if gameMap.inMapArea(nextX, nextY) and nextE == null:
			return [Step.new(e, Vector2(x, y), Vector2(nextX, nextY)), Step.new(player, Vector2(playerPos), Vector2(x, y))]
	return []
	
static func doMove(steps: Array[Step], reverse = false, record_history = true):
	# start move animation
	if true:
		Game.instance.set_process(false)
		var tween = Game.instance.create_tween()
		tween.tween_interval(MOVE_INTERVAL)
		tween.tween_callback(func ():Game.instance.set_process(true))
	# logic
	Game.gameMap.applyStep(steps, reverse)
	if record_history:
		history.append(steps)
	# animation
	if reverse:
		for i in range(steps.size() - 1, -1, -1):
			var step = steps[i]
	else:
		for step in steps:
			var p = ElementNode.getUIPosition(step.to.x, step.to.y)
			var tween = step.e.node.create_tween()
			tween.tween_property(step.e.node, "position", p, MOVE_INTERVAL)

static func back():
	if not history.is_empty():
		var steps = history.pop_back()
		doMove(steps, true, false)

static func doShake(e: Element, dx = 1, dy = 1):
	var p = ElementNode.getUIPositionByPos(Game.gameMap.getElementPos(e))
	var x = p.x
	var y = p.y
	var tween = e.node.create_tween()
	var randomSetPosition = func (value):
		e.node.position.x = x + random.randf_range(-4, 4) * dx
		e.node.position.y = y + random.randf_range(-4, 4) * dy
	tween.tween_method(randomSetPosition, 0, 100, 0.2)
	tween.tween_callback(func (): e.node.position = p)

	
