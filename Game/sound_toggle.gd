extends TextureButton

signal sound_state_changed(is_on: bool)

@onready var click_sfx = $click_sfx

var sound_on_texture = preload("res://Art/Button_Sounds.png")
var sound_off_texture = preload("res://Art/Button_No-Sounds.png")
var is_sound_on = true
var audio_bus_name = "Master" # Default to master bus

func initialize(bus_name: String):
	audio_bus_name = bus_name

func _ready():
	texture_normal = sound_on_texture
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pressed.connect(_on_pressed)
	
	# Sync initial state with the specific audio bus
	var bus_idx = AudioServer.get_bus_index(audio_bus_name)
	is_sound_on = !AudioServer.is_bus_mute(bus_idx)
	texture_normal = sound_on_texture if is_sound_on else sound_off_texture

func _on_pressed():
	if is_sound_on:
		click_sfx.play()
	
	disabled = true
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	
	is_sound_on = !is_sound_on
	texture_normal = sound_on_texture if is_sound_on else sound_off_texture
	
	var bus_idx = AudioServer.get_bus_index(audio_bus_name)
	AudioServer.set_bus_mute(bus_idx, !is_sound_on)
	
	emit_signal("sound_state_changed", is_sound_on)
	disabled = false
