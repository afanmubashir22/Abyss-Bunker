extends Area3D
@export var spin_speed: float = 2.0

func _ready() -> void:
		body_entered.connect(_on_body_entered)
		
func _process(delta: float) -> void:
		rotate_y(spin_speed * delta)
		
func _on_body_entered(body: Node3D) -> void:
		if body.is_in_group("player"):
				body.pickup_keycard()
				queue_free()
