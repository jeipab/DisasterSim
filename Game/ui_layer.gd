extends Control

# This will be our UI layer that handles all UI input priority
func _ready():
	# Ensure this control receives input first
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Get references to buttons
	var exit_button = get_node("ExitButton")
	var sound_toggle = get_node("SoundToggle")
	
	# Connect signals
	if exit_button:
		exit_button.gui_input.connect(_on_button_gui_input.bind(exit_button))
		
	if sound_toggle:
		sound_toggle.gui_input.connect(_on_button_gui_input.bind(sound_toggle))

func _on_button_gui_input(event: InputEvent, button: TextureButton) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if button.name == "ExitButton":
			_handle_exit_button()
		elif button.name == "SoundToggle":
			_handle_sound_toggle(button)
		get_viewport().set_input_as_handled()

func _handle_exit_button() -> void:
	var exit_button = get_node("ExitButton")
	var sfx = get_node("exit_click_sfx")
	
	if sfx:
		sfx.play()
	
	exit_button.disabled = true
	
	var tween = create_tween()
	tween.tween_property(exit_button, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(exit_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	get_tree().change_scene_to_file("res://Game/start.tscn")

func _handle_sound_toggle(button: TextureButton) -> void:
	var sfx = button.get_node("click_sfx")
	
	if sfx:
		sfx.play()
	
	button.disabled = true
	
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	
	# Toggle sound state
	var is_sound_on = button.texture_normal == button.sound_on_texture
	button.texture_normal = button.sound_off_texture if is_sound_on else button.sound_on_texture
	
	# Set global audio bus volume
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master_bus_idx, is_sound_on)
	
	button.disabled = false
