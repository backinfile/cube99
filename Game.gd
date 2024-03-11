extends Node2D
class_name Game

static var instance
static var gameMap: GameMap

func _ready():
	instance = self
	loadLevel("res://mapResource/level1.json")


func loadLevel(path:String):
	$World.get_children().clear()
	GameLogic.init()
	
	gameMap = GameMap.parseFile(path)
	
	var startPosition = calcStartPosition(0,0)
	ElementNode.ui_offset_x = startPosition.x
	ElementNode.ui_offset_y = startPosition.y
	
	var background = ColorRect.new()
	background.color = Color.LIGHT_GRAY
	background.position.x = startPosition.x - ElementNode.Element_Size / 2.0
	background.position.y = startPosition.y - ElementNode.Element_Size / 2.0
	background.size[0] = gameMap.width * (ElementNode.Element_Size + ElementNode.Element_Gap)
	background.size[1] = gameMap.height * (ElementNode.Element_Size + ElementNode.Element_Gap)
	$World.add_child(background)
	for i in gameMap.data:
		var e = gameMap.data[i]
		if e.type == Element.Type_Box:
			var p = ElementNode.getUIPosition(e.x, e.y)
			e.node = ElementNode.createElementNode(e.type, p.x, p.y)
			$World.add_child(e.node)
	for i in gameMap.floor:
		var e = gameMap.floor[i]
		var p = ElementNode.getUIPosition(e.x, e.y)
		e.node = ElementNode.createElementNode(e.type, p.x, p.y)
		$World.add_child(e.node)
	for i in gameMap.data:
		var e = gameMap.data[i]
		if e.type != Element.Type_Box:
			var p = ElementNode.getUIPosition(e.x, e.y)
			e.node = ElementNode.createElementNode(e.type, p.x, p.y)
			$World.add_child(e.node)

func calcStartPosition(x: int, y:int) -> Vector2:
	var size = get_viewport_rect().size
	var startX = size[0] / 2.0 - gameMap.width / 2.0 * (ElementNode.Element_Size + ElementNode.Element_Gap)
	var startY = size[1] / 2.0 - gameMap.height / 2.0 * (ElementNode.Element_Size + ElementNode.Element_Gap)
	var fx = startX + x * (ElementNode.Element_Size + ElementNode.Element_Gap)
	var fy = startY + y * (ElementNode.Element_Size + ElementNode.Element_Gap)
	return Vector2(fx, fy)
	

func _process(delta):
	var dx = 0
	var dy = 0
	if Input.is_action_just_pressed("restart"):
		loadLevel("res://mapResource/level1.json")
		return
	if Input.is_action_just_pressed("back"):
		GameLogic.back()
		return
	if Input.is_action_just_pressed("ui_left"):
		dx = -1
	elif Input.is_action_just_pressed("ui_right"):
		dx = 1
	elif Input.is_action_just_pressed("ui_up"):
		dy = -1
	elif Input.is_action_just_pressed("ui_down"):
		dy = 1
	if dx != 0 or dy != 0:
		GameLogic.move(dx, dy)
		

