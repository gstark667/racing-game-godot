extends Camera

export(NodePath) var targetPath
var target
var pidx
var pidy
var pidz
var xvel = 0.0
var yvel = 0.0
var zvel = 0.0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetPath)
	var pid = preload("res://pid.gd")
	pidx = pid.new()
	pidx.set_params(0.005, 0.0, 0.0)
	pidy = pid.new()
	pidy.set_params(0.005, 0.0, 0.0)
	pidz = pid.new()
	pidz.set_params(0.005, 0.0, 0.0)

func _process(delta):
	var pos = get_transform()
	var targetPos = target.get_transform()
	var difference = targetPos.origin - pos.origin;
	xvel += pidx.process(delta, 1.0, difference.x)
	yvel += pidy.process(delta, 1.0, difference.y)
	zvel += pidz.process(delta, 1.0, difference.z)
	var offset = target.get_transform().basis.xform(Vector3(xvel * delta, 3 + yvel * delta, -8 + zvel * delta))
	pos.origin = target.get_transform().origin + offset
	set_transform(pos)
	look_at(target.get_transform().xform(Vector3(0, 2, 0)), Vector3(0, 1, 0))