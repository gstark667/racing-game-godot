extends RigidBody


func _ready():
	pass

func _physics_process(delta):
	apply_impulse(transform.basis.xform(Vector3(0, 0, 1)), transform.basis.xform(Vector3(10 * delta, 0, 0)))