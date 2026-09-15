extends CharacterBody3D
@export var walk_speed: float = 4.5 
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.003

@onready var head: Node3D = $Head
@onready var flashlight: SpotLight3D = $Head/Camera3D/SpotLight3D
@onready var crystal_label: Label = %CrystalLabel

var crystals_collected: int = 0
var is_hidden: bool = false

func _ready() -> void:
		add_to_group("player")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		update_hud()
		
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if not get_tree().paused:
						Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				rotate_y(-event.relative.x * mouse_sensitivity)
				head.rotate_x(-event.relative.y * mouse_sensitivity)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_F:
				flashlight.visible = not flashlight.visible
		if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_R:
						var victory_ui = get_node_or_null("%VictoryScreen")
						if is_instance_valid(victory_ui) and victory_ui.visible:
										get_tree
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
func add_crystal() -> void:
		crystals_collected += 1
		print("Crystal collected! Total: ", crystals_collected)
		update_hud()
		var hud_panel = get_node_or_null("HUD/CrystalHUD")
		if is_instance_valid(hud_panel):
				var tween = create_tween()
				hud_panel.pivot_offset = hud_panel.size / 2.0
				hud_panel.scale = Vector2(1.15, 1.15)
				tween.tween_property(hud_panel, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
func update_hud() -> void:
		if is_instance_valid(crystal_label):
				crystal_label.text = "Crystals: " + str(crystals_collected) + " / 3"
