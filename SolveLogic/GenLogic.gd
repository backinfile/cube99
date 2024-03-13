class_name GenLogic

static var random = RandomNumberGenerator.new()

static func genMap(n: int) -> Array:
	var result = []
	for i in range(n):
		for loop in range(1000):
			var record = []
			var gameMap = GameMap.new()
			gameMap.width = random.randi_range(3,6)
			gameMap.height = random.randi_range(3,4)
			genPlayer(gameMap)
			genBox(gameMap)
			genWall(gameMap)
			for times in range(gameMap.width):
				if random.randf() <= 0.3:
					genBox(gameMap)
				else:
					genWall(gameMap)
			var r = SolveLogic.solve(gameMap)
			if r.moves.size() > 0:
				return [gameMap]
	return result

static func genPlayer(gameMap: GameMap):
	var p = randEmptyPosition(gameMap)
	var e = Element.new(Element.Type_Player)
	gameMap.setElement(e, p.x, p.y)

static func genBox(gameMap: GameMap):
	var p = randEmptyPosition(gameMap)
	var e = Element.new(Element.Type_Box)
	gameMap.setElement(e, p.x, p.y)
	var targetP = randEmptyPosition(gameMap, false)
	if targetP.x < 0:
		targetP = randEmptyPosition(gameMap, true)
	var targetE = Element.new(Element.Type_Target)
	gameMap.setFloor(targetE, targetP.x, targetP.y)
	
static func genWall(gameMap: GameMap):
	var p = randEmptyPosition(gameMap)
	var e = Element.new(Element.Type_Wall)
	gameMap.setElement(e, p.x, p.y)
	
static func countEmptyPosition(gameMap:GameMap, includeBoxP=false) -> int:
	var cnt = 0
	for x in range(gameMap.width):
		for y in range(gameMap.height):
			var e = gameMap.getElement(x, y)
			var f = gameMap.getElementFloor(x, y)
			if e == null && f == null:
				cnt += 1
			elif includeBoxP and f == null:
				if e != null and (e.type == Element.Type_Box or e.type == Element.Type_Player):
					cnt += 1
	return cnt

static func randEmptyPosition(gameMap:GameMap, includeBoxP=false) -> Vector2:
	var rand = random.randi_range(0, countEmptyPosition(gameMap, includeBoxP)) + 1
	var cnt = 0
	for x in range(gameMap.width):
		for y in range(gameMap.height):
			var e = gameMap.getElement(x, y)
			var f = gameMap.getElementFloor(x, y)
			if e == null && f == null:
				cnt += 1
			elif includeBoxP and f == null:
				if e != null and (e.type == Element.Type_Box or e.type == Element.Type_Player):
					cnt += 1
			if cnt >= rand:
				return Vector2(x, y)
	return Vector2(-1, -1)
