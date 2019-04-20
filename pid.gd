var kp = 40.0
var ki = 0.0
var kd = 4.0

var totalError = 0.0
var lastError = 0.0

var target = 1.5

func set_params(p, i, d):
	kp = p
	ki = i
	kd = d

func process(delta, target, p):
	if delta == 0.0:
		return 0.0
	var error = target - p
	totalError += error * delta
	var errorDir = (error - lastError) / delta
	lastError = error
	return (error * kp + totalError * ki + errorDir * kd) * delta