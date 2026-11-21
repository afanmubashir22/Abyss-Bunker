extends Area3D
@export var spin_speed: float = 2.0
@onready var pickup_sound: AudioStreamPlayer = $PickupSound

var picked_up: bool = false

func _ready() -> void:
		body_entered.connect(_on_body_entered)
		
func _process(delta: float) -> void:
		rotate_y(spin_speed * delta)
		
func _on_body_entered(body: Node3D) -> void:
		if picked_up:
				return
		if body.is_in_group("player"):
				picked_up = true
				body.pickup_keycard()
				visible = false
				set_deferred("monitoring", false)
				if is_instance_valid(pickup_sound) and pickup_sound.stream:
						pickup_sound.play()
						await pickup_sound.fininshed
				queue_free()
