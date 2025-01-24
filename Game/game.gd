extends Node2D

@onready var fsm = $FSM
@onready var card_system = $CardSystem
@onready var scenario_text = $ScenarioText
@onready var resource_container = $ResourceContainer
@onready var exit_button = $ExitButton
@onready var retry_button = $RetryButton
@onready var exit_click_sfx = $exit_click_sfx

func _ready() -> void:
	# Ensure FSM is initialized before other systems
	if not fsm:
		push_error("FSM node not found!")
		return
		
	# Initialize starting state
	fsm.start_state = 1  # Start with first card
	
	# Initialize other game systems
	card_system.initialize(fsm)
	scenario_text.initialize(fsm)
	
	# Connect button signals
	exit_button.pressed.connect(_on_exit_button_pressed)
	exit_button.mouse_entered.connect(_on_button_mouse_entered)
	exit_button.mouse_exited.connect(_on_button_mouse_exited)
	
	retry_button.pressed.connect(_on_retry_button_pressed)
	retry_button.mouse_entered.connect(_on_button_mouse_entered)
	retry_button.mouse_exited.connect(_on_button_mouse_exited)
	
	print("[Game] All systems initialized")

func _on_exit_button_pressed() -> void:
	# Temporarily disable card system input
	if card_system and card_system.get_node_or_null("Card"):
		card_system.get_node("Card").set_process_input(false)
	
	exit_click_sfx.play()
	exit_button.disabled = true
	
	# Create animation tween
	var tween = create_tween()
	tween.tween_property(exit_button, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(exit_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	get_tree().change_scene_to_file("res://Game/start.tscn")
	
func _on_retry_button_pressed() -> void:
	# Temporarily disable card system input
	if card_system and card_system.get_node_or_null("Card"):
		card_system.get_node("Card").set_process_input(false)
	
	exit_click_sfx.play()
	retry_button.disabled = true
	
	# Create animation tween
	var tween = create_tween()
	tween.tween_property(retry_button, "scale", Vector2(0.8, 0.8), 0.1)
	tween.tween_property(retry_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	await tween.finished
	get_tree().reload_current_scene()  # Reload the current scene to restart

# Disable card input when mouse is over buttons
func _on_button_mouse_entered() -> void:
	if card_system and card_system.get_node_or_null("Card"):
		card_system.get_node("Card").set_process_input(false)

func _on_button_mouse_exited() -> void:
	if card_system and card_system.get_node_or_null("Card"):
		card_system.get_node("Card").set_process_input(true)
