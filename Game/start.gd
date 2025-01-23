extends Node2D

@onready var start_button = $PlayButton
@onready var start_bgm: AudioStreamPlayer = $start_bgm
@onready var start_click_sfx: AudioStreamPlayer = $start_click_sfx
@onready var animation_player = $AnimationPlayer

func _ready():
	start_bgm.play()
	start_button.pressed.connect(_on_start_button_pressed)
	animation_player.play("title_float")

func _on_start_button_pressed():
	start_click_sfx.play()
	start_button.disabled = true
	
	var tween = create_tween()
	tween.tween_property(start_button, "scale", Vector2(0.12, 0.12), 0.1)
	tween.tween_property(start_button, "scale", Vector2(0.15, 0.15), 0.1)
	
	await tween.finished
	get_tree().change_scene_to_file("res://Game/loading.tscn")
