extends Area3D

@export  var spin_speed: float = 2.0
@onready var pickup_sound: AudioStreamPlayer =  get_node_or_null("PickupSound")

var player_in_range:Node3D = null
var picked_up: bool = false

func _ready() -> void:
		body_entered.connect(_on_body_entered)
		body_exited.connect(on_body_exited)
func _process(delta: float) -> void:
		rotate_y(spin_speed * delta)
		
		
