extends CharacterBody3D
@export var walk_speed: float  = 4.5 
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.003

@onready var head: Node3D = $Head
@onready var flashlight: SpotLight3D = $Head/Camera3D/SpotLight3D

var crystals_collected: int = 0
var is_hidden: bool = false

func _ready() -> void:
		add_to_group("player")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				rotate_y(-event.relative.x * mouse_sensitivity)
				head.rotate_x(-event.relative.y * mouse_sensitivity)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_F:
				flashlight.visible = not flashlight.visible
func _physics_process(delta: float) -> void:
		if not is_on_floor():
				velocity.y -= 18.0 * delta
		var speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed
		var input_dir := Vector2.ZERO
		if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
				input_dir.y -= 1
		if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
				input_dir.y += 1
		if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
				input_dir.x -= 1
		if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
				input_dir.x += 1
		input_dir = input_dir.normalized()
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
		else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()
	
