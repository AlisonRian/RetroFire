extends CharacterBody3D
var speed
const SPRINT_SPEED = 10.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENSE = 0.003

var direction

#const BOB_FREQ = 2.0
#const BOB_AMP = 0.08
#var t_bob = 0.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var animation_tree: AnimationTree = $Player/AnimationTree

enum States {
	IDLE,
	WALKING,
	RUNNING,
	SHOOTING,
	JUMPING
}
var current_state = States.IDLE

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * CAMERA_SENSE)
		head.rotate_x(event.relative.y * CAMERA_SENSE)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	var input_dir := Input.get_vector("move_left","move_right","move_up","move_down")
	direction = (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	#print(current_state)
	match current_state:
		States.IDLE:
			process_idle(delta)
		States.WALKING:
			process_walking(delta)
		States.RUNNING:
			pass
		States.JUMPING:
			process_jumping()
		States.SHOOTING:
			pass

	#
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = _headBob(t_bob)
	
	move_and_slide()

#func _headBob(time) -> Vector3:
	#var pos = Vector3.ZERO
	#pos.y = sin(time * BOB_FREQ) * BOB_AMP
	#pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	#return pos

func change_state(new_state):
	if current_state == new_state:
		return
	
	#Fazer algo antes de trocar de estado, tipo tocar algum som.
	#match current_state:
		#States.JUMPING:
		
	current_state = new_state
	match current_state:
		States.IDLE:
			animation_tree.set("parameters/Transition/transition_request", "idle")
		States.WALKING:
			animation_tree.set("parameters/Transition/transition_request","walk")
		States.RUNNING:
			animation_tree.set("parameters/Transition/transition_request", "run")
		States.JUMPING:
			animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		States.SHOOTING:
			pass

func process_idle(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		change_state(States.JUMPING)
		return
	if direction:
		change_state(States.WALKING)
		return
	velocity.x = lerp(velocity.x, 0.0, 5.0*delta)
	velocity.z = lerp(velocity.z, 0.0, 5.0*delta)

func process_jumping():
	if is_on_floor():
		change_state(States.IDLE)
		return
	

func process_walking(delta):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		change_state(States.JUMPING)
		return

	if not direction:
		change_state(States.IDLE)
		return
	
	velocity.x = lerp(velocity.x, 0.0, 5.0*delta)
	velocity.z = lerp(velocity.z, 0.0, 5.0*delta)
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED
		
		
		
