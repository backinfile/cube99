class_name SolveLogic

const DIR = [0, 1, 0, -1, 1, 0, -1, 0]

static func solve(gameMap: GameMap) -> SolveResult:
	var result = SolveResult.new()
	var stateCache = {}
	var queue: Array[SolveNode] = [SolveNode.new(gameMap, [])]
	var curMaxStep = 0
	var deathPosList = gameMap.calcDeathPosList()
	print(deathPosList)
	while not queue.is_empty():
		var node: SolveNode = queue.pop_front()
		stateCache[node.gameMap.getStateHash()] = true
		if node.moves.size() > curMaxStep:
			curMaxStep = node.moves.size()
			print("solve step " + str(curMaxStep))
		if node.moves.size() >= 30:
			break
		for i in range(DIR.size() / 2):
			var steps = GameLogic.findMovePath(node.gameMap, DIR[i*2], DIR[i*2+1])
			if steps.is_empty():
				continue
			var copyMap = node.gameMap.makeCopy()
			copyMap.applyStep(steps)
			
			# check death pos
			var inDeathPos = false
			for step in steps:
				if step.e.type == Element.Type_Box:
					if step.to in deathPosList:
						inDeathPos = true
			if inDeathPos: continue
			
			var moves = node.moves.duplicate()
			moves.append(Vector2(DIR[i*2], DIR[i*2+1]))
			if copyMap.isGameOver():
				result.moves = moves
				print("solve success")
				return result
			if copyMap.getStateHash() in stateCache: continue
			queue.push_back(SolveNode.new(copyMap, moves))
			result.solveQueueStep += 1
	print("solve failed")
	return result

class SolveNode:
	var gameMap:GameMap
	var moves:Array
	func _init(gameMap:GameMap, moves:Array):
		self.moves = moves
		self.gameMap = gameMap
