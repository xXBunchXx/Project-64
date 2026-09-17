extends CharacterBody3D

@onready var camera_mount: SpringArm3D = $SpringArmPivot/SpringArm3D
@onready var animation_player: AnimationPlayer = $Visuals/mixamo_base/AnimationPlayer
@onready var visuals: Node3D = $Visuals


var Speed = 2.4
const JUMP_VELOCITY = 4.5

var walkingSpeed = 2.4
var RunningSpeed = 5.0

var running = false

@export var sensHorizontal = 0.25
@export var sensVertical = 0.25

func _ready():
	pass

func _physics_process(delta: float) -> void:
	player_movement(delta)

func player_movement(delta):
	if Input.is_action_pressed("run"):
		Speed = RunningSpeed
		running = true
	else:
		Speed = walkingSpeed
		running = false
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if running:
			if animation_player.current_animation != "running":
				animation_player.play("running")
		else:
			if animation_player.current_animation != "walking":
				animation_player.play("walking")
		
		visuals.look_at(position + direction)
		
		velocity.x = direction.x * Speed
		velocity.z = direction.z * Speed
	else:
		if animation_player.current_animation != "idle":
			animation_player.play("idle")
		velocity.x = move_toward(velocity.x, 0, Speed)
		velocity.z = move_toward(velocity.z, 0, Speed)
	direction = direction.rotated(Vector3.UP, SpringArm3D.global_rotation.y) # !!! BROKEN - IS SUPOSED TO MAKE PLAYER TURN WITH MOUSE MOVEMENT/CAMERA MOVEMENT !!!

	move_and_slide()
