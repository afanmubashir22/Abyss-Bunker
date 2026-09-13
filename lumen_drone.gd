extends CharacterBody3D
@export var petrol_spee: float = 2.0
@export var chase_speed: float = 5.5
@export var vision_range: float = 14.0
@export var close_detection_range: float = 2.5
@onready var vision_ray: RayCast3D = $VisionRay
@onready var eye_mesh: MeshInstance3D = $EyeMesh
@onready var eye_light: 	SpotLight3D = $EyeLight
var player: CharacterBody3D = null
var is_chasing: bool = false
var lost_timer: float = 0.0
const COLOR_CALM: Color = Color(1.0, 0.72, 0.0) #Yellow
const COLOR_ALERT: Color = Color(1.0, 0.05, 0.0)
func _ready() -> void:
		add_to_group("enemies")
		player = get_tree().get_first_node_in_group("player")
		set_eye_color(COLOR_CALM)
func _physics_process(delta: float)
		if not is_instance_valid(player):
				return
		var dist_to_player := global_position.distance_to(player.global_position)
		var can_see_player := check_line_of_sight()
		var player_light_on: bool = false
		if player.get("flashlight") and player.flashlight is SpotLight3D:
				player_light_on = player.flashlight.visible
		var spotted := can_see_player and ((dist_to_player <= vision_range and player_light_on) or (dist_to_player <= close_detection_range))
		if spotted:
				is_chasing == true
				lost_timer =2.0
				set_eye_color(COLOR_ALERT)
		else:
				if is_chasing:
						lost_timer -= delta
						if lost_timer <= 0.0:
								is_chasing = false
								set_eye_color(COLOR_CALM)
		if is_chasing:
				var look_target := Vector3(player.global_position.x, global_position.y player.global_position.z)
				look_at(look_target, Vector3.UP)
				var move_dir := (player.global_position - global_position).normailized()
				move_dir.y = 0.0
				velocity = move_dir * chase_speed
				if dist_to_player < 1.3:
						print("Caught by the Lumen Drone! Restarting...")
						get_tree().reload_current_scene()
		else:
				velocity = velocity.move_toward(Vector3.ZERO, petrol_speed * delta)
		move_and_slide()
func check_line_of_sight() -> bool:
		vision_ray.global_position = global_position
		var target_pos := player.global_position + Vector3(0, 1.0, 0)
		vision_ray.target_position = vision_ray.get_collider()
		
