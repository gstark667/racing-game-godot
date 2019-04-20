extends Spatial

var pid
var lastContact = false

func _ready():
	pid = preload("res://pid.gd").new()
	pid.set_params(80.0, 0.0, 5.0)

func _physics_process(delta):
	var space_state = get_world().direct_space_state
	var parent = get_parent()
	var parentTransform = parent.get_transform()
	var result = space_state.intersect_ray(global_transform.origin, global_transform.xform(Vector3(0, -5, 0)))
	if result.has('position'):
		var distance = global_transform.origin.distance_to(result.position)
		var force = pid.process(delta, 2.0, distance)
		if lastContact:
			get_parent().apply_impulse(parentTransform.basis.xform(transform.origin), global_transform.basis.xform(Vector3(0, force, 0)))
		lastContact = true
	else:
		lastContact = false