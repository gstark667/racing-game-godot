extends RigidBody

var xpid
var ypid
var zpid

var xrpid
var yrpid
var zrpid

var pid

var target = Vector3(0, 0, 0)
var auxTarget = Vector3(0, 0, 0)
var targetUp = Vector3(0, 1, 0)

var lastContact = false

func _ready():
	var pid_class = preload("res://pid.gd")
	xpid = pid_class.new()
	xpid.set_params(4.0, 0.0, 0.0)
	ypid = pid_class.new()
	ypid.set_params(40.0, 0.0, 4.0)
	zpid = pid_class.new()
	zpid.set_params(4.0, 0.0, 0.0)
	
	xrpid = pid_class.new()
	xrpid.set_params(-200.0, 0.0, -10.0)
	yrpid = pid_class.new()
	yrpid.set_params(300.0, 0.0, 0.0)
	zrpid = pid_class.new()
	zrpid.set_params(100.0, 0.0, 10.0)
	
	pid = pid_class.new()
	pid.set_params(160.0, 0.0, 10.0)
	
func _input(event):
	target = Vector3(
		Input.get_action_strength("p1_left") - Input.get_action_strength("p1_right"),
		0.0, 
		Input.get_action_strength("p1_forward") - Input.get_action_strength("p1_back")
	)
	
	auxTarget = Vector3(
		Input.get_action_strength("p1_aux_left") - Input.get_action_strength("p1_aux_right"),
		0.0, 
		Input.get_action_strength("p1_aux_forward") - Input.get_action_strength("p1_aux_back")
	)

func _hover(delta):
	var space_state = get_world().direct_space_state
	var parent = get_parent()
	var parentTransform = parent.get_transform()
	var result = space_state.intersect_ray(global_transform.origin, global_transform.origin + (targetUp * -10))
	if result.has('position'):
		# set the target orientation to the ground normal
		targetUp = result.normal
		var distance = global_transform.origin.distance_to(result.position)
		var force = pid.process(delta, 4, distance)
		if lastContact:
			apply_impulse(Vector3(0, 0, 0), global_transform.basis.xform(Vector3(0, force, 0)))
		lastContact = true
	else:
		# reset the target orientation to our current orientation
		targetUp = global_transform.basis.xform(Vector3(0, 1, 0))
		lastContact = false

func _physics_process(delta):
	_hover(delta)
	
	var vel = transform.basis.inverse().xform(linear_velocity)
	var rotVel = transform.basis.inverse().xform(angular_velocity)
	var thrust = Vector3(
		xpid.process(delta, target.x * 10, vel.x),
		0,
		zpid.process(delta, target.z * 160, vel.z)
	)
	apply_impulse(transform.basis.xform(Vector3(0, 0, 0)), transform.basis.xform(thrust))
	
	var rotOut = Vector3(0, yrpid.process(delta, target.x * 2.5, rotVel.y), 0)
	if lastContact:
		var localNormalOff = transform.basis.inverse().xform(targetUp)
		localNormalOff.x += target.x * 0.15 + auxTarget.x * 0.25
		localNormalOff.z -= abs(target.x) * 0.15
		rotOut.x = zrpid.process(delta, localNormalOff.z, 0)
		rotOut.z = xrpid.process(delta, localNormalOff.x, 0)
	apply_torque_impulse(transform.basis.xform(rotOut))
	apply_torque_impulse(transform.basis.xform(Vector3(auxTarget.z, 0, -auxTarget.x)))