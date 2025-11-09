extends CharacterBody3D
var speed
const SPRINT_SPEED = 10.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CAMERA_SENSE = 0.003

#const BOB_FREQ = 2.0
#const BOB_AMP = 0.08
#var t_bob = 0.0
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var animation_player = get_node("male_casual/AnimationPlayer") as AnimationPlayer

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
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	var input_dir := Input.get_vector("move_left","move_right","move_up","move_down")
	var direction := (transform.basis * Vector3(-input_dir.x, 0, -input_dir.y)).normalized()
	
	#if Input.is_action_pressed("sprint"):
		#speed = SPRINT_SPEED
	#else: 
		#speed = SPEED
	
	if direction:
		animation_player.play("Animations/walking")
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		animation_player.play("Animations/idle")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	#
	#t_bob += delta * velocity.length() * float(is_on_floor())
	#camera.transform.origin = _headBob(t_bob)
	
	move_and_slide()

#func _headBob(time) -> Vector3:
	#var pos = Vector3.ZERO
	#pos.y = sin(time * BOB_FREQ) * BOB_AMP
	#pos.x = cos(time * BOB_FREQ/2) * BOB_AMP
	#return pos
