extends Node3D

@export var hold_duration: float = 5.0

@onready var vent_model: Node3D = $VentModel
@onready var interact_zone: Area3D = $InteractZone

var player_in_range: Node3D = null
var hold_timer: float = 0.0
var is_open: bool = false

func _ready() -> void:
		interact_zone.body_entered.connect(_on_body_entered)
		interact_zone.body_exited.connect(_on_body_exited)

func _on_body_entered(body:Node3D) -> void:
		if is_open:
				return
		if body.is_in_group("player"):
				player_in_range = body
				if body.get("has_screwdriver"):
						body.show_message("Hold [E] for to unscrew vent", 3.0)
				else:
						body.show_message("Locked. You need a screwdriver!", 3.0)
func _on_body_exited(body: Node3D) -> void:
		if body == player_in_range:
				player_in_range = null
				hold_timer= 0.0
func _process(delta: float) -> void:
		if is_open or not is_instance_valid(player_in_range):
				return
		if not player_in_range.get("has_screwdriver"):
				return
		if Input.is_key_pressed(KEY_E):
				hold_timer += delta
				var time_left: float = max(0.0, hold_duration - hold_timer)
				player_in_range.show_message("Unscrewing vent... Keep holding [E] (" + str(snapped(time_left, 0.1)) + "s)", 0.2)
				var hand_tool = player_in_range.get("hand_screwdriver")
				if is_instance_valid(hand_tool):
						hand_tool.rotate_z(10.0 * delta)
				if hold_timer >= hold_duration:
						open_vent()
		else:
				if hold_timer > 0.0:
						hold_timer = 0.0
						player_in_range.show_message("Keep holding [E] without letting go!", 2.0)
func open_vent() -> void:
		is_open = true
		if is_instance_valid(player_in_range):
				player_in_range.show_message("Vent Opened!", 2.5)
		for shape in vent_model.find_children("*", "CollisionShape3D", true, false):
				shape.set_deferred("disabled", true)
		var tween:= create_tween()
		tween.tween_property(vent_model, "position:y", vent_model.position.y + 1.5, 0.6)
		tween.tween_callback(func(): vent_model.visible = false)
