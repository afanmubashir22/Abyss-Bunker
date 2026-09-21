extends Area3D
var player_in_range: bool = false
func _ready() -> void:
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node3D) -> void:
		if body.is_in_group("player"):
				player_in_range = true
func _on_body_exited(body: Node3D) -> void:
		if body.is_in_group("player"):
				player_in_range = false
func _unhandled_input(event: InputEvent) -> void:
		if player_in_range and event is InputEventKey and event.pressed and event.keycode == KEY_E:
				var player = get_tree().get_first_node_in_group("player")
				if player and player.has_method("pickup_flashlight"):
						player.pickup_flashlight()
						queue_free()
