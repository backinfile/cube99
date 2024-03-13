

extends Sprite2D
class_name ElementNode
var elementType: String

const Element_Size = 64
const Element_Border_Size = 5
const Element_Gap = 0


static var ui_offset_x = 0.0
static var ui_offset_y = 0.0

static var element_object = preload("res://element/ElementNode.tscn")

static func createElementNode(type:String, x: float = 0, y: float = 0) -> Node:
	var e = element_object.instantiate()
	e.elementType = type
	e.position.x = x
	e.position.y = y
	return e

func _ready():
	texture = createTexture(elementType)

static func getUIPosition(x: int, y: int) -> Vector2:
	var fx = ui_offset_x + x * (ElementNode.Element_Size + ElementNode.Element_Gap)
	var fy = ui_offset_y + y * (ElementNode.Element_Size + ElementNode.Element_Gap)
	return Vector2(fx, fy)

static func getUIPositionByPos(pos: Vector2) -> Vector2:
	return getUIPosition(pos.x, pos.y)

static var texture_cache = {}

static func createTexture(type: String):
	var tex = texture_cache.get(type)
	if tex != null:
		return tex
	var width = ElementNode.Element_Size
	var borderWidth = ElementNode.Element_Border_Size
	var img = Image.create(width, width, false, Image.FORMAT_RGBA8)
	match type:
		Element.Type_Wall: img.fill(Color.BLACK)
		Element.Type_Player: 
			img.fill(Color.RED)
			for x in range(width):
				for y in range(width):
					if (x - width / 2) * (x - width / 2) + (y - width / 2) * (y - width / 2) > width * width / 2.5:
						img.set_pixel(x, y, Color.TRANSPARENT)
		Element.Type_Target: 
			#img.fill(Color.LIGHT_GRAY)
			img.fill_rect(Rect2(0,0, width, borderWidth), Color.BLUE)
			img.fill_rect(Rect2(0,0, borderWidth, width), Color.BLUE)
			img.fill_rect(Rect2(width - borderWidth, 0, width, width), Color.BLUE)
			img.fill_rect(Rect2(0,width - borderWidth, width, width), Color.BLUE)
		Element.Type_Box: img.fill(Color.WHITE)
		_: img.fill(Color.LIGHT_GRAY)
	tex = ImageTexture.create_from_image(img)
	texture_cache[type] = tex
	print("create texture for " + type)
	return tex
