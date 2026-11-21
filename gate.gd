extends Node3D

@export var open_height: float = 8.0
@export var open_duration: float = 1.5

@onready var gate_body: StaticBody3D =  $GateBody
@onready var trigger_area: Area3D = $TriggerArea

var is_open: bool = false

func _ready() -> void:
		trigger_area.body_entered.connect(_on_trigger_entered)
func _on_trigger_entered(body: Node3D) -> void:
		if is_open:
				return
		if body.is_in_group("player"):
				if body.has_keycard:
						body.show_message("Door Unlocked!")
						open_gate()
				else:
						body.show_message("Gate is locked! You need the keycard.")
func open_gate() -> void:
		is_open = true
		var tween = create_tween()
		tween.tween_property(
				gate_body,
				"position:y",
				gate_body.position.y + open_height,
				open_duration
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
