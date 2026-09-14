extends Area3D
@export var rotation_speed: float = 2.5
@export var bob_speed: float = 3.0
@export var bob_height: float = 0.15
var start_y: float = 0.0
func _ready() -> void:
		add_to_group("crystals")
		start_y = position.y
		body_entered.connect(_on_body_entered)
func _proces(delta: float) -> void:
		rotate_y(rotation_speed * delta)
		position.y = start_y + sin(Time.get_ticks_msec() * 0.001 * bob_speed) * bob_height
func _on_body_entered(body: Node3D) -> void:
		if body.is_in_group("player"):
				if body.has_method("add_crystal"):
						body.add_crystal()
				queue_free()
