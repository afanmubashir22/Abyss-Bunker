extends Area3D

@onready var pickup_sound: AudioStreamPlayer = get_node_or_null("PickupSound")

var player_in_range: Node3D = null
var picked_up: bool = false

func _ready() -> void:
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node3D) -> void:
		if picked_up:
				return
		if body.is_in_group("player"):
				player_in_range = body
				body.show_message("Press E to pickup Crowbar")
func _on_body_exited(body: Node3D) -> void:
		if body == player_in_range: 
				player_in_range = null
func _process(_delta: float) -> void:
		if picked_up or player_in_range == null:
				return
		if Input.is_action_just_pressed("interact"):
				picked_up = true
				if player_in_range.has_method("pickup_crowbar"):
						player_in_range.pickup_crowbar()
				visible = false
				set_deferred("monitoring", false)
				if is_instance_valid(pickup_sound) and pickup_sound.stream:
						pickup_sound.play()
						await pickup_sound.finished
				queue_free()
