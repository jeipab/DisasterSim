extends Node

# Game state enum
enum GameState {
    PLAYING,
    WON,
    LOST
}

var current_state = GameState.PLAYING

# Resource thresholds
const RESOURCE_MIN = 0.0
const MORALE_THRESHOLD = 20.0
const STAMINA_THRESHOLD = 20.0
const SUPPLIES_THRESHOLD = 20.0
const PROPERTY_THRESHOLD = 20.0

# Win condition thresholds for combined resources
const HIGH_THRESHOLD = 320.0  # Average 80 per resource
const MEDIUM_THRESHOLD = 240.0  # Average 60 per resource
const LOW_THRESHOLD = 160.0  # Average 40 per resource

# References to resource indicators
var morale_indicator
var stamina_indicator
var supplies_indicator
var property_indicator

func _ready():
    # Find resource indicators
    var resource_container = get_tree().get_root().find_child("ResourceContainer", true, false)
    if resource_container:
        morale_indicator = resource_container.find_child("Morale")
        stamina_indicator = resource_container.find_child("Stamina")
        supplies_indicator = resource_container.find_child("Supplies")
        property_indicator = resource_container.find_child("Property")
    
    # Connect to card system for checking after each choice
    var card_system = get_tree().get_root().find_child("CardSystem", true, false)
    if card_system:
        card_system.connect("card_spawned", _on_card_spawned)

func _on_card_spawned(card):
    card.connect("card_chosen", _on_card_chosen)

func _on_card_chosen(_is_right: bool):
    check_game_state()

func check_game_state() -> void:
    if current_state != GameState.PLAYING:
        return

    # Check lose conditions first (in specified order)
    if morale_indicator.get_value() <= RESOURCE_MIN:
        end_game(GameState.LOST, 25)  # Morale loss
        return
    elif stamina_indicator.get_value() <= RESOURCE_MIN:
        end_game(GameState.LOST, 24)  # Stamina loss
        return
    elif supplies_indicator.get_value() <= RESOURCE_MIN:
        end_game(GameState.LOST, 27)  # Resource loss
        return
    elif property_indicator.get_value() <= RESOURCE_MIN:
        end_game(GameState.LOST, 26)  # Property loss
        return
    
    # Calculate total resources for win condition
    var total_resources = (
        morale_indicator.get_value() +
        stamina_indicator.get_value() +
        supplies_indicator.get_value() +
        property_indicator.get_value()
    )
    
    # Check win conditions
    if total_resources >= HIGH_THRESHOLD:
        end_game(GameState.WON, 21)  # High resources win
    elif total_resources >= MEDIUM_THRESHOLD:
        end_game(GameState.WON, 22)  # Medium resources win
    elif total_resources >= LOW_THRESHOLD:
        end_game(GameState.WON, 23)  # Low resources win

func end_game(state: GameState, card_id: int) -> void:
    current_state = state
    
    # Get card system and update current card
    var card_system = get_tree().get_root().find_child("CardSystem", true, false)
    if card_system:
        card_system.current_card_id = card_id
        
    # Disable base node clicks
    var base = card_system.get_node("Base")
    if base:
        base.set_process_input(false)

func reset_game() -> void:
    current_state = GameState.PLAYING
    get_tree().change_scene_to_file("res://Game/start.tscn")