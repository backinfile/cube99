class_name GameMap

var width = 1
var height = 1
var data = {}
var floor = {}

const FACTOR = 1000

func getElement(x:int, y: int) -> Element:
	return data.get(x * FACTOR + y)

func getElementFloor(x:int, y: int) -> Element:
	return floor.get(x * FACTOR + y)
	
func inMapArea(x: int, y: int) -> bool:
	return 0 <= x and x < width and 0 <= y and y < height

func is_stop(x: int, y: int):
	if not inMapArea(x, y): return true
	var e = getElement(x, y)
	if e == null: return false
	return e.type == Element.Type_Wall
	
func setElement(e: Element, x: int, y: int):
	data[x * FACTOR + y] = e
	
func setFloor(e: Element, x: int, y: int):
	floor[x * FACTOR + y] = e

func getElementPos(e: Element) -> Vector2:
	for i in data:
		if data[i] == e:
			return Vector2(i / FACTOR, i % FACTOR)
	for i in floor:
		if floor[i] == e:
			return Vector2(i / FACTOR, i % FACTOR)
	return Vector2(-1, -1)

func removeElement(e: Element):
	for i in data:
		if data[i] == e:
			data.erase(i)
			break
	for i in floor:
		if floor[i] == e:
			data.erase(i)
			break

func getPlayerElement() -> Element:
	for i in data:
		var e = data[i]
		if e.type == Element.Type_Player:
			return e
	return null
	
static func parseFile(path:String) -> GameMap:
	var json = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(json)
	var width = int(data['width'])
	var height = int(data['height'])
	var gameMap = GameMap.new()
	gameMap.width = width
	gameMap.height = height
	for i in range(data['data'].size()):
		var type = data['data'][i]
		if type != "  ":
			var e = Element.new()
			e.type = type
			gameMap.setElement(e, i % width, i / width)
	for i in range(data['floor'].size()):
		var type = data['floor'][i]
		if type != "  ":
			var e = Element.new()
			e.type = type
			gameMap.setFloor(e, i % width, i / width)
	return gameMap
	
func makeCopy() -> GameMap:
	var map = GameMap.new()
	map.width = width
	map.height = height
	for i in data:
		map.data[i] = data[i]
	for i in floor:
		map.floor[i] = floor[i]
	return map

func isGameOver() -> bool:
	for i in floor:
		if floor[i].type == Element.Type_Target:
			if data.get(i) == null or data[i].type != Element.Type_Box:
				return false
	return true
	
func applyStep(steps: Array[Step], reverse: bool = false):
	if reverse:
		for i in range(steps.size() - 1, -1, -1):
			var step = steps[i]
			var e = step.e
			removeElement(e)
			setElement(e, step.from.x, step.from.y)
	else:
		for step in steps:
			var e = step.e
			removeElement(e)
			setElement(e, step.to.x, step.to.y)
	pass

func getStateHash():
	const R = 131
	var hash = 0
	hash = hash * R + width
	hash = hash * R + height
	for x in range(width):
		for y in range(height):
			var i = x * FACTOR + y
			var e = data.get(i)
			if e != null:
				hash = hash * R + i
				hash = hash * R + hash(e)
			var f = floor.get(i)
			if f != null:
				hash = hash * R + i
				hash = hash * R + hash(e)
	return hash
	
const DIR = [0, 1, 0, -1, 1, 0, -1, 0]
	
func calcDeathPosList() -> Array:
	return []
	var result = []
	for tx in range(width):
		for ty in range(height):
			if is_stop(tx, ty): continue
			if checkIsDeathCornor(tx,ty) or checkIsDeathPos(tx, ty): 
				result.append(Vector2(tx, ty))
	return result
	
func checkIsDeathCornor(tx: int, ty: int) -> bool:
	var e = getElementFloor(tx, ty)
	if e != null:
		return false
	var upBlock = is_stop(tx, ty - 1)
	var leftBlock = is_stop(tx - 1, ty)
	var downBlock = is_stop(tx, ty + 1)
	var rightBlock = is_stop(tx + 1, ty)
	return (upBlock and leftBlock) or (leftBlock and downBlock) or (downBlock and rightBlock) or (rightBlock and upBlock)
	
func checkIsDeathPos(tx: int, ty:int) -> bool:
	for x in range(width):
		var e = getElementFloor(x, ty)
		if e != null && e.type == Element.Type_Target:
			return false
	for y in range(height):
		var e = getElementFloor(tx, y)
		if e != null && e.type == Element.Type_Target:
			return false

	var upBlock = true
	var downBlock = true
	var leftBlock = true
	var rightBlock = true
	for x in range(0, width):
		for y in range(0, ty):
			var e = getElement(x, y)
			if e == null or e.type != Element.Type_Wall:
				upBlock = false
				break
		for y in range(ty+1, height):
			var e = getElement(x, y)
			if e == null or e.type != Element.Type_Wall:
				downBlock = false
				break
	for y in range(0, height):
		for x in range(0, tx):
			var e = getElement(x, y)
			if e == null or e.type != Element.Type_Wall:
				leftBlock = false
				break
		for x in range(tx+1, width):
			var e = getElement(x, y)
			if e == null or e.type != Element.Type_Wall:
				rightBlock = false
				break
	return upBlock or downBlock or leftBlock or rightBlock
