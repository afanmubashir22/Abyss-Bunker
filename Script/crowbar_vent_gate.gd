extends Area3D

var player_in_range: Node3D = null
var is_open: bool = false

func _ready() -> void:
		body_entered.connect(_on_body_entered) 
		body_exited.connect(_on_body_exited)
func _on_body_entered(body: Node3D) -> void:
		if is_open:
				return
		if body.is_in_group("player"):
				player_in_range = body
				if not body.holding_crowbar:
						body.show_message("You need a crowbar  to open this vent")
func _on_body_exited(body: Node3D) -> void:
		if body == player_in_range:
				player_in_range = null
func _process(_delta: float) -> void:
		if is_open or player_in_range == null:
				return
		if Input.is_action_just_pressed("interact"):
				if player_in_range.holding_crowbar:
						open_vent()
				else:
						player_in_range.show_message("You need a crowbar to open this vent")
func open_vent() -> void:
		is_open = true
		player_in_range.show_message("vent opened!")
		queue_free()
