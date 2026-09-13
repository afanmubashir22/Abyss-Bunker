extends CharacterBody3D
@export var petrol_speed: float = 2.0
@export var chase_speed: float = 5.5
@export var vision_range: float = 14.0
@export var close_detection_range: float = 2.5
@export var kill_distance: float = 1.8
@onready var vision_ray: RayCast3D = $VisionRay
@onready var eye_mesh: MeshInstance3D = $EyeMesh
@onready var eye_light: SpotLight3D = $EyeLight
var player: CharacterBody3D = null
var is_chasing: bool = false
var lost_timer: float = 0.0
const COLOR_CALM: Color = Color(1.0, 0.72, 0.0) #Yellow
const COLOR_ALERT: Color = Color(1.0, 0.05, 0.0)
func _ready() -> void:
		add_to_group("enemies")
		player = get_tree().get_first_node_in_group("player")
		set_eye_color(COLOR_CALM)
func _physics_process(delta: float) -> void:
		if not is_instance_valid(player):
				player = get_tree().get_first_node_in_group("player")
				if not is_instance_valid(player):
						return
		var drone_flat := Vector2(global_position.x, global_position.z)
		var player_flat := Vector2(player.global_position.x, player.global_position.z)
		var horizontal_dist := drone_flat.distance_to(player_flat)
		var can_see_player := check_line_of_sight()
		var player_light_on: bool = false
		if player.get("flashlight") and player.flashlight is SpotLight3D:
				player_light_on = player.flashlight.visible
		var spotted := can_see_player and ((horizontal_dist <= vision_range and player_light_on) or (horizontal_dist <= close_detection_range))
		if spotted:
				is_chasing = true
				lost_timer =2.0
				set_eye_color(COLOR_ALERT)
		else:
				if is_chasing:
						lost_timer -= delta
						if lost_timer <= 0.0:
								is_chasing = false
								set_eye_color(COLOR_CALM)
		if is_chasing:
				var look_target := Vector3(player.global_position.x, global_position.y, player.global_position.z)
				if global_position.distance_to(look_target) > 0.1:
						look_at(look_target, Vector3.UP)
				var move_dir := (player.global_position - global_position).normalized()
				move_dir.y = 0.0
				velocity = move_dir * chase_speed
				if horizontal_dist <= kill_distance:
						kill_player()
		else:
				velocity = velocity.move_toward(Vector3.ZERO, petrol_speed * delta)
		move_and_slide()
		for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var collider = collision.get_collider()
				if collider == player or (collider and collider.is_in_group("player")):
						kill_player()
func kill_player() -> void:
		print("Caught by the Lumen Drone! Restarting...")
		get_tree().reload_current_scene()
func check_line_of_sight() -> bool:
		vision_ray.global_position = global_position
		var target_pos := player.global_position + Vector3(0, 1.0, 0)
		vision_ray.target_position = vision_ray.to_local(target_pos)
		vision_ray.force_raycast_update()
		if vision_ray.is_colliding():
				var hit = vision_ray.get_collider()
				return hit == player or (hit and hit.is_in_group("player"))
		return false
func set_eye_color(color: Color) -> void:
		eye_light.light_color = color
		var mat = eye_mesh.get_active_material(0)
		if mat is StandardMaterial3D:
			mat.emission_enabled = true
			mat.emission = color
