extends Area3D

var triggered: bool = false

func _ready() -> void:
		body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node3D) -> void:
		if triggered:
				return
		if body.is_in_group("player"):
				triggered = true
				body.set_physics_process(false)
				if body.has_method("show_message"):
						body.show_message("Eliminated by laser!", 1.0)
				await get_tree().create_timer(1.0).timeout
				get_tree().reload_current_scene()
