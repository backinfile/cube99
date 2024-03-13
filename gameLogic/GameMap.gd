class_name GameMap

var width = 1
var height = 1
var data = {}
var floor = {}

const FACTOR = 1000

func getElement(x:int, y: int) -> Element:
	return data.get(x * FACTOR + y)
	
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
		floor.data[i] = data[i]
	return map

func isGameOver() -> bool:
	for i in floor:
		if floor[i].type == Element.Type_Target:
			if data[i] == null or data[i].type != Element.Type_Box:
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
