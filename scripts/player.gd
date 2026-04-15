extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var anim = $GodotCharacterSprite/AnimationPlayer

var is_moving: bool = false

@export var shooting_range: float = 100.0
@export var shooting_delay: float = 0.1
var _shoot_time_gone: float = 0.0
var bullet = load("res://scenes/bullet.tscn")
@onready var camera = $CameraSystem/SideSpringArm/BackSpringArm/Camera3D
@onready var gun_position = $GunPosition

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
	
	# Shooting Mechanic, starting from here
	if Input.is_action_pressed("shoot"):
		_shoot(delta)

func _shoot(delta: float):
	
	_shoot_time_gone += delta
	
	if _shoot_time_gone >= shooting_delay:
		var instance = bullet.instantiate()
		instance.position = gun_position.global_position
		get_parent().add_child(instance)

		var screen_center = get_viewport().get_visible_rect().size / 2
		var ray_start = camera.project_ray_origin(screen_center)
		var ray_direction = camera.project_ray_normal(screen_center)
		var ray_end = ray_start + ray_direction * 1000.0

		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
		query.exclude = [self]
		var hit = space_state.intersect_ray(query)
		var target_point = hit["position"] if hit else ray_end

		var direction = (target_point - gun_position.global_position).normalized()
		
		var result: Dictionary = space_state.intersect_ray(query)
		
		print(result)	# Debug

		instance.velocity = direction * instance.SPEED
		
		var timer := Timer.new()
		timer.wait_time = 5.0		# 5 seconds before removing bullets from scene.
		timer.one_shot = true
		timer.connect("timeout", Callable(instance, "queue_free"))
		instance.add_child(timer)
		timer.start()
		_shoot_time_gone = 0.0
