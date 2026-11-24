extends Area3D
@export var required_crystals: int = 3
@onready var gate_light: OmniLight3D = $GateLight
@onready var status_label: Label3D = $StatusLabel
@onready var gate_mesh: MeshInstance3D = $GateMesh
var is_unlocked: bool = false
func _ready() -> void:
		body_entered.connect(_on_body_entered)
func _on_body_entered(body: Node3D):
		if not body.is_in_group("player"):
				return
		var collected: int = body.get("crystals_collected") if body.get("crystals_collected") != null else 0
		if collected >= required_crystals:
				if not is_unlocked:
						unlock_and_escape(body)
		else:
				status_label.text = "[LOCKED: " + str(collected) + "/" + str(required_crystals) + " CORES ]"
				status_label.modulate = Color(1.0, 0.15, 0.15)
				gate_light.light_color = Color(1.0, 0.15, 0.15)
func unlock_and_escape(player_node: Node3D) -> void:
		is_unlocked = true
		status_label.text = "[ACCESS GRANTED - ESCAPING...]"
		status_label.modulate = Color(0.1, 1.0, 0.4)
		gate_light.light_color = Color(0.1, 1.0, 0.4)
		var tween = create_tween()
		tween.tween_property(gate_mesh, "position:y", 4.0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		if player_node.has_method("trigger_victory"):
				player_node.trigger_victory()
