extends CanvasLayer
@onready var resume_button: Button = $VBoxContainer/ResumeButton
@onready var quit_button: Button = $VBoxContainer/QuitButton

func _ready() -> void:
		visible = false
		resume_button.pressed.connect(_on_resume_pressed)
		quit_button.pressed.connect(_on_quit_pressed)
func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.is_echo() and event.keycode == KEY_ESCAPE:
				toggle_pause()
func toggle_pause() -> void:
		var is_paused := not get_tree().paused
		get_tree().paused = is_paused
		visible = is_paused
		if is_paused:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _on_resume_pressed() -> void:
		toggle_pause()
func  _on_quit_pressed() -> void:
		get_tree().quit()
