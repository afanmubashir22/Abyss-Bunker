extends Node3D

@onready var interact_zone: Area3D = $InteractZone
@onready var switch_sound: AudioStreamPlayer3D = get_node_or_null("SwitchSound")

var bulb_lights: 	Array[Node] = []
var player_in_range: Node3D = null
var is_on: bool = false

func _ready() -> void:
		bulb_lights = find_children("*", "Light3D", true, false)
		for light in bulb_lights:
				if light is Light3D:
						light.visible = false
		interact_zone.body_entered.connect(_on_body_entered)
		interact_zone.body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node3D) -> void:
		if is_on:
				return
		if body.is_in_group("player"):
				player_in_range = body
				body.show_message("Press [E] to turn ON light", 2.5)
func _on_body_exited(body: Node3D) -> void:
		if body == player_in_range:
				player_in_range = null
func _unhandled_input(event: InputEvent) -> void:
		if is_on or not is_instance_valid(player_in_range):
				return
		if event is InputEventKey and event.pressed and not event.is_echo():
				if event.keycode == KEY_E:
						turn_on_switch()
func turn_on_switch() -> void:
		is_on = true
		interact_zone.set_deferred("monitoring", false)
		for light in bulb_lights:
				if light is Light3D:
						light.visible = true
		if is_instance_valid(switch_sound) and switch_sound.stream:
				switch_sound.play()
		if is_instance_valid(player_in_range):
				player_in_range.show_message("Light Turned ON", 2.0)
	
