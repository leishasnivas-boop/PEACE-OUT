extends CharacterBody3D
## First-person player: WASD / arrow keys to move, mouse to look,
## hold SHIFT to sprint (uses stamina), ESC to free the mouse.

@export var walk_speed: float = 5.0
@export var sprint_speed: float = 7.5
@export var mouse_sensitivity: float = 0.0025
@export var gravity: float = 20.0
@export var max_stamina: float = 3.0   # seconds of sprinting

var stamina: float = max_stamina
var can_move: bool = true

@onready var camera: Camera3D = $Camera3D


func _ready() -> void:
	camera.position = Vector3(0.0, 0.7, 0.0)   # eye height ~1.6 m
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotation.x = clampf(
			camera.rotation.x - event.relative.y * mouse_sensitivity, -1.4, 1.4)

	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	if not can_move:
		velocity = Vector3.ZERO
		return

	# Read keyboard input (works without setting up an Input Map).
	var input_dir := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		input_dir.y -= 1.0
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		input_dir.y += 1.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		input_dir.x -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		input_dir.x += 1.0

	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	# Sprint drains stamina and recovers when not sprinting.
	var sprinting := Input.is_physical_key_pressed(KEY_SHIFT) \
		and stamina > 0.0 and input_dir != Vector2.ZERO
	var speed := walk_speed
	if sprinting:
		speed = sprint_speed
		stamina = maxf(stamina - delta, 0.0)
	else:
		stamina = minf(stamina + delta * 0.6, max_stamina)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	move_and_slide()
