extends Node3D


@export var character: CharacterBody3D

var camera_rotation: Vector2 = Vector2.ZERO
var mouse_sensitivity: float = 0.005 # Must be set very low
var max_y_rotation_rads: float = 1 # Limits up-down rotation


func _ready() -> void:
	Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )


func _input(event: InputEvent) -> void:
	# Show/Hide mouse when hitting "Esc" key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode( Input.MOUSE_MODE_VISIBLE )
		else:
			Input.set_mouse_mode( Input.MOUSE_MODE_CAPTURED )
	
	if event is InputEventMouseMotion:
		var mouse_event: Vector2 = event.screen_relative * mouse_sensitivity
		move_field_of_view(mouse_event)


func move_field_of_view(mouse_movement: Vector2) -> void:
	# Reset previous movement
	transform.basis = Basis()
	character.transform.basis = Basis()
	
	camera_rotation += mouse_movement
	camera_rotation.y = clamp(camera_rotation.y, -max_y_rotation_rads, max_y_rotation_rads)
	
	character.rotate_object_local( Vector3(0, 1, 0), -camera_rotation.x )
	rotate_object_local( Vector3(1, 0, 0), -camera_rotation.y )
