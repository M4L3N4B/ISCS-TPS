extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var anim = $GodotCharacterSprite/AnimationPlayer

var is_moving: bool = false

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Mouse unless mouse is visible
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			is_moving = true
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			is_moving = false

	# Animation
	if is_on_floor() and is_moving:
		if anim.current_animation != "2HandAimWalk":
			anim.play("2HandAimWalk")
	else:
		if anim.current_animation != "2HandAim":
			anim.play("2HandAim")
		
	move_and_slide()
