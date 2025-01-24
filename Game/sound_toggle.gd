extends TextureButton

@onready var click_sfx = $click_sfx

var sound_on_texture = preload("res://Art/Button_Sounds.png")
var sound_off_texture = preload("res://Art/Button_No-Sounds.png")

func _ready():
	texture_normal = sound_on_texture
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
