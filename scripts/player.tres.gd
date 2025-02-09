extends CharacterBody3D

const mouse_sens = 0.2
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

#bob variables
const BOB_FREQ = 2.0
const BOB_AMP = 0.08
var t_bob = 0.0

@onready var head = $head
@onready var camera = $head/Camera3D
@onready var flashlight = $head/Camera3D/SpotLight3D

var toggle_flashlight = true

func _ready():
	#clears up the cursor on runtime.
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#camera_rotation
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	if Input.is_action_just_pressed("escape-debug"):
		get_tree().quit()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if toggle_flashlight: 
		if Input.is_action_just_pressed("ui_accept"):
			flashlight.visible = false
			toggle_flashlight = false
	elif !toggle_flashlight:
		if Input.is_action_just_pressed("ui_accept"):
			flashlight.visible = true
			toggle_flashlight = true

	# Handle jump. (INPUT NOT ASSIGNED)
	if Input.is_action_just_pressed("space_bar") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Head Bob
	t_bob += delta * velocity.length() * float(is_on_floor()) 
	camera.transform.origin = _headbob(t_bob)
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	return pos
