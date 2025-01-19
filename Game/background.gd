extends Node2D

# Preload background textures
var background_textures = {
	"initial": preload("res://Art/BG_Initial.png"),
	"crisis": preload("res://Art/BG_Crisis.png"),
	"recovery": preload("res://Art/BG_Recovery.png"),
	"concluding": preload("res://Art/BG_Concluding.png")
}

# Preload BGM tracks
var bgm_tracks = {
	"initial": preload("res://Sounds/initial_phase_bgm.mp3"),
	"crisis": preload("res://Sounds/crisis_phase_bgm.mp3"),
	"recovery": preload("res://Sounds/recovery_phase_bgm.mp3"),
	"concluding": preload("res://Sounds/concluding_phase_bgm.mp3"),
}

# Reference to the background sprite and audio player
@onready var background_sprite = $Sprite2D
@onready var phase_bgm: AudioStreamPlayer = $phase_bgm

# Reference to FSM
var fsm = null
var current_phase: String = "initial"

func _ready() -> void:
	# Find FSM node
	fsm = get_tree().get_root().find_child("Fsm", true, false)
	if fsm:
		print("[Background] Found FSM node")
	else:
		push_error("[Background] Failed to find FSM node")
		return

	# Find CardSystem to connect to card spawned signal
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if card_system:
		card_system.connect("card_spawned", _on_card_spawned)
		print("[Background] Connected to CardSystem")
	else:
		push_error("[Background] Failed to find CardSystem")

	# Set initial background
	update_background("initial")

func _on_card_spawned(card) -> void:
	# Connect to card's signals
	if !card.is_connected("card_chosen", _on_card_chosen):
		card.connect("card_chosen", _on_card_chosen)
		print("[Background] Connected to card signals")

func _on_card_chosen(_is_right: bool) -> void:
	if not fsm:
		return

	# Get current card data from FSM
	var card_system = get_tree().get_root().find_child("CardSystem", true, false)
	if not card_system:
		push_error("[Background] CardSystem not found")
		return
		
	var card_data = fsm.cards.get(card_system.current_card_id)
	if not card_data:
		push_error("[Background] Current card not found in FSM")
		return

	# Update background based on card phase
	var new_phase = card_data.get("phase", "initial")
	if new_phase != current_phase:
		update_background(new_phase)

func update_background(phase: String) -> void:
	if not background_sprite:
		push_error("[Background] Background sprite not found")
		return

	if not background_textures.has(phase):
		push_error("[Background] Invalid phase: ", phase)
		return

	print("[Background] Updating background to phase: ", phase)
	background_sprite.texture = background_textures[phase]
	
	update_bgm(phase)
	current_phase = phase

func update_bgm(phase: String) -> void:
	if not phase_bgm:
		push_error("[Background] Audio player not found")
		return

	if not bgm_tracks.has(phase):
		push_error("[Background] Invalid BGM phase: ", phase)
		return

	print("[Background] Updating BGM to phase: ", phase)
	phase_bgm.stop()
	phase_bgm.stream = bgm_tracks[phase]
	phase_bgm.play()

# Add transition effects
func transition_to_background(phase: String) -> void:
	var tween = create_tween()
	tween.tween_property(background_sprite, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	update_background(phase)
	
	tween = create_tween()
	tween.tween_property(background_sprite, "modulate:a", 1.0, 0.3)
