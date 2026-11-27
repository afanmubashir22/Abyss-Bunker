extends CharacterBody3D
@export var walk_speed: float = 4.5
@export var sprint_speed: float = 11
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.003
@export var fall_death_height: float = -25.0
@export var crouch_speed: float = 2.5
@export var crouch_depth: float = 2.0
@export var crouch_lerp_speed: float = 10.0
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var head: Node3D = $Head
@onready var flashlight: SpotLight3D = $Head/Camera3D/HandFlashlight/SpotLight3D
@onready var crystal_label: Label = %CrystalLabel
@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var hand_flashlight: Node3D = $Head/Camera3D/HandFlashlight
@onready var hand_screwdriver: Node3D = $Head/Camera3D/HandScrewdriver
@onready var hand_crowbar = $Head/Camera3D/HandCrowbar
@onready var jump_sound: AudioStreamPlayer = $JumpSoundPlayer
@onready var objectives: Array[String] = [
				"OBJECTIVE 1:\nLocate the screwdriver",
				"OBJECTIVE 2:\nFind the keycard",
				"OBJECTIVE 3:\nOpen the KEYCARD DOOR and go LEFT",
				"OBJECTIVE 4:\nEscape the drones and get the Void Core\n(WARNING: THE DRONES ARE ATTRACTED BY LIGHT)",
				"OBJECTIVE 5:\nMove to the Second side and acruire void core red",
				"OBJECTIVE 6:\nMove to another Side to complete the maze and acquire VOID CORE GREEN",
				"OBJECTIVE 7:\nESCAPE THROUGH THE MAIN GATE."
		]
var current_objective: int = 0
@onready var message_label: Label = %MessageLabel
@onready var objectives_label: Label = %ObjectivesLabel
var message_tween: Tween
var crystals_collected: int = 0
var is_hidden: bool = false
var has_flashlight: bool = false
var has_screwdriver: bool = false
var holding_screwdriver: bool = false
var has_crowbar: bool = false
var holding_crowbar: bool = false
var has_keycard: bool = false
var  is_crouching: bool = false
var stand_head_y: float = 0.0
var stand_height: float = 5.0
var stand_col_y: float = 1.0
func _ready() -> void:
		add_to_group("player")
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		update_hud()
		if is_instance_valid(hand_flashlight):
				hand_flashlight.visible = false
		if is_instance_valid(flashlight):
				flashlight.visible = false
		if is_instance_valid(message_label):
				message_label.visible = false
		if is_instance_valid(hand_screwdriver):
				hand_screwdriver.visible = false
		stand_head_y = head.position.y
		stand_col_y = collision_shape.position.y
		if is_instance_valid(hand_screwdriver):
						hand_screwdriver.visible = false
		if is_instance_valid(hand_crowbar):
						hand_crowbar.visible = false
		if collision_shape.shape is CapsuleShape3D:
				stand_height = collision_shape.shape.height
		update_objective()
		if is_instance_valid(bgm_player):
				bgm_player.finished.connect(bgm_player.play)
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				if not get_tree().paused:
						Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
				rotate_y(-event.relative.x * mouse_sensitivity)
				head.rotate_x(-event.relative.y * mouse_sensitivity)
				head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		if event is InputEventKey and event.pressed and not event.is_echo():
				if event.keycode == KEY_F:
						if has_flashlight:
								flashlight.visible = not flashlight.visible
				elif event.keycode == KEY_R:
						var victory_ui = get_node_or_null("%VictoryScreen")
						if is_instance_valid(victory_ui) and victory_ui.visible:
								get_tree().reload_current_scene()
				elif event.keycode == KEY_1:
						toggle_screwdriver()
				elif event.keycode == KEY_2:
						toggle_crowbar()
func _physics_process(delta: float) -> void:
		is_crouching = Input.is_key_pressed(KEY_CTRL) or Input.is_key_pressed(KEY_C)
		
		var target_head_y = stand_head_y - crouch_depth if is_crouching else stand_head_y
		head.position.y = lerp(head.position.y,target_head_y, crouch_lerp_speed * delta)
		
		if collision_shape.shape is CapsuleShape3D:
				var target_height = stand_height - crouch_depth if is_crouching else stand_height
				collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, crouch_lerp_speed * delta)
				
				var target_col_y = stand_col_y - (crouch_depth / 2.0) if is_crouching else stand_col_y
				collision_shape.position.y = lerp(collision_shape.position.y, target_col_y, crouch_lerp_speed * delta)
		if position.y < fall_death_height:
						get_tree().reload_current_scene()
						return
		if not is_on_floor():
				velocity.y -= 18.0 * delta
		if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
						velocity.y = jump_velocity
						if is_instance_valid(jump_sound):
										jump_sound.play()
		var speed = walk_speed
		if is_crouching:
				speed = crouch_speed
		elif Input.is_key_pressed(KEY_SHIFT):
				speed = sprint_speed
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
		if crystals_collected == 1:
				current_objective = 4
		elif crystals_collected == 2:
				current_objective = 5
		elif crystals_collected >= 3:
				current_objective = 6
		update_objective()
func update_hud() -> void:
		if is_instance_valid(crystal_label):
				crystal_label.text = "Crystals: " + str(crystals_collected) + " / 3"
func trigger_victory() -> void:
				var victory_ui = get_node_or_null("%VictoryScreen")
				if is_instance_valid(victory_ui):
								victory_ui.visible = true
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				set_physics_process(false)
func pickup_flashlight() -> void:
		has_flashlight = true
		hand_flashlight.visible = true
		flashlight.visible = true
func pickup_keycard() -> void:
		has_keycard = true
		print("Keycard acquired!")
		show_message("Keycard Acquired!")
		advance_objective(2)
func show_message(text: String, duration: float = 2.5) -> void:
		if not is_instance_valid(message_label):
				return
		message_label.text = text
		message_label.visible = true
		if message_tween:
				message_tween.kill()
		message_tween = create_tween()
		message_tween.tween_interval(duration)
		message_tween.tween_callback(func(): message_label.visible = false)
func update_objective() -> void:
		if is_instance_valid(objectives_label) and current_objective < objectives.size():
				objectives_label.text = objectives[current_objective]
func advance_objective(next_index: int) -> void:
		if current_objective < next_index:
				current_objective = next_index
				update_objective()
func pickup_screwdriver() -> void:
		has_screwdriver = true
		equip_screwdriver()
		show_message("Screwdriver Acquired!")
		advance_objective(1)
func pickup_crowbar() -> void:
		has_crowbar = true
		equip_crowbar()
		show_message("Crowbar Acquired!")
func toggle_screwdriver() -> void:
				if not has_screwdriver:
								return
				if holding_screwdriver:
								unequip_tools()
				else:
								equip_screwdriver()
func toggle_crowbar() -> void:
				if not has_crowbar:
								return
				if holding_crowbar:
								unequip_tools()
				else:
								equip_crowbar()
func equip_screwdriver() -> void:
				holding_screwdriver = true
				holding_crowbar = false
				if is_instance_valid(hand_screwdriver):
								hand_screwdriver.visible = true
				if is_instance_valid(hand_crowbar):
								hand_crowbar.visible = false
func equip_crowbar() -> void:
				holding_crowbar = true
				holding_screwdriver = false
				if is_instance_valid(hand_crowbar):
								hand_crowbar.visible = true
				if is_instance_valid(hand_screwdriver):
								hand_screwdriver.visible = false
func unequip_tools() -> void:
				holding_screwdriver = false
				holding_crowbar = false
				if is_instance_valid(hand_screwdriver):
								hand_screwdriver.visible = false
				if is_instance_valid(hand_crowbar):
								hand_crowbar.visible = false
