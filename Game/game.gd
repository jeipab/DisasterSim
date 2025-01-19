extends Node2D

@onready var fsm = $FSM
@onready var card_system = $CardSystem
@onready var scenario_text = $ScenarioText
@onready var resource_container = $ResourceContainer
@onready var game_manager = $GameManager

# Called when the node enters the scene tree for the first time.
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
	
	# Initialize game manager last since it depends on other systems
	if game_manager:
		# Game manager will find its own references
		pass
	else:
		push_error("GameManager node not found!")
	
	print("[Game] All systems initialized")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
