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
	e.x = x
	e.y = y
	data[e.x * FACTOR + e.y] = e
	
func setFloor(e: Element, x: int, y: int):
	e.x = x
	e.y = y
	floor[e.x * FACTOR + e.y] = e

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
	

