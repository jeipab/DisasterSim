extends Node

enum Choice { LEFT, RIGHT };

var inputs: Array[Choice] = [Choice.LEFT, Choice.RIGHT]
var states: Array[int]
var start_state: int = 1
var final_states: Array[int]

const cards: Dictionary = {
	# Initial Phase (Preparation)
	1: {
		"phase": "initial",
		"type": "regular",
		"image": "res://Art/directed_square-05.png",
		"title": "You are home and you hear the news: a typhoon is approaching your area.",
		"choices": {
			"left": {
				"text": "Gather supplies like food, water, a flashlight, and a medical kit.",
				"next_card": 2,
				"resources": {
					"supplies": 15,
					"stamina": -5
				}
			},
			"right": {
				"text": "Check on neighbors to see if they need help.",
				"next_card": 3,
				"resources": {
					"morale": 10,
					"supplies": -10,
					"stamina": -5
				}
			}
		}
	},
	2: {
		"phase": "initial",
		"type": "regular",
		"image": "res://Art/test-squares-02.png",
		"title": "You gathered your supplies, but you realized that you need to secure and protect your home.",
		"choices": {
			"left": {
				"text": "Secure your home with available resources.",
				"next_card": 5,
				"resources": {
					"property": 15,
					"stamina": -10,
					"supplies": -5
				}
			},
			"right": {
				"text": "Ignore securing your home and pack your supplies.",
				"next_card": 4,
				"resources": {
					"supplies": 10,
					"property": -5
				}
			}
		}
	},
	3: {
		"phase": "initial",
		"type": "regular",
		"image": "res://Art/test-squares-03.png",
		"title": "You helped your neighbor and they are grateful for your help. Now, the typhoon is getting closer.",
		"choices": {
			"left": {
				"text": "Return home and gather your supplies.",
				"next_card": 2,
				"resources": {
					"supplies": 10,
					"stamina": -5
				}
			},
			"right": {
				"text": "Ask your neighbor to stay in each of your own houses.",
				"next_card": 6,
				"resources": {
					"morale": 10,
					"property": -5
				}
			}
		}
	},
	4: {
		"phase": "initial",
		"type": "regular",
		"image": "res://Art/test-squares-04.png",
		"title": "Your home is now secured, but you need to decide if you will stay at your home or prepare to evacuate.",
		"choices": {
			"left": {
				"text": "Stay at home and ride out the typhoon.",
				"next_card": 7,
				"resources": {
					"property": 10,
					"supplies": -5
				}
			},
			"right": {
				"text": "Prepare to evacuate with your packed supplies.",
				"next_card": 8,
				"resources": {
					"supplies": 10,
					"stamina": -5
				}
			}
		}
	},
	5: {
		"phase": "initial",
		"type": "regular",
		"image": "res://Art/test-squares-01.png",
		"title": "Your supplies are now packed in a bag, but you didn’t secure your home. The typhoon is almost here.",
		"choices": {
			"left": {
				"text": "Stay at home and ride out the typhoon.",
				"next_card": 7,
				"resources": {
					"property": 10,
					"supplies": -5
				}
			},
			"right": {
				"text": "Evacuate to a safer location with your packed supplies.",
				"next_card": 8,
				"resources": {
					"stamina": -5,
					"supplies": 5
				}
			}
		}
	},
	6: {
		"phase": "initial",
		"type": "regular",
		"image": "res://Art/test-squares-02.png",
		"title": "You all agreed to stay at home, but you realized that you need to secure and protect your houses.",
		"choices": {
			"left": {
				"text": "Stay at home and secure each of your own houses.",
				"next_card": 7,
				"resources": {
					"morale": 10,
					"stamina": -10,
					"property": 10
				}
			},
			"right": {
				"text": "Convince the group to evacuate to an evacuation area.",
				"next_card": 8,
				"resources": {
					"supplies": 10,
					"morale": -10
				}
			}
		}
	},

	# Crisis Phase (During Typhoon)
	7: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-03.png",
		"title": "You stayed at home, but there’s a flood rising...",
		"choices": {
			"left": {
				"text": "Call for help and wait from the higher ground of your house.",
				"next_card": 8,
				"resources": {
					"stamina": -5,
					"supplies": -10,
					"morale": 10
				}
			},
			"right": {
				"text": "Evacuate quickly despite the risks.",
				"next_card": 8,
				"resources": {
					"stamina": -10,
					"supplies": 5,
					"property": -5
				}
			}
		}
	},
	8: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-04.png",
		"title": "You’ve reached an organized evacuation center with sufficient resources.",
		"choices": {
			"left": {
				"text": "Follow instructions and participate in activities.",
				"next_card": 12,
				"resources": {
					"morale": 10,
					"stamina": 5
				}
			},
			"right": {
				"text": "Focus on personal needs and preparedness.",
				"next_card": 13,
				"resources": {
					"supplies": 10,
					"morale": -5
				}
			}
		}
	},

	# Crisis Phase (Continued)
	9: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-01.png",
		"title": "You’re staying at home, but the floodwaters are rising higher, and food is running out.",
		"choices": {
			"left": {
				"text": "Attempt to signal rescuers for help.",
				"next_card": 8,
				"resources": {
					"stamina": -10,
					"morale": 10
				}
			},
			"right": {
				"text": "Risk going out on your own to find supplies.",
				"next_card": 8,
				"resources": {
					"stamina": -15,
					"supplies": 15
				}
			}
		}
	},
	10: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-2.png",
		"title": "You evacuated quickly but forgot key supplies in your rush.",
		"choices": {
			"left": {
				"text": "Return briefly to retrieve the forgotten items.",
				"next_card": 8,
				"resources": {
					"stamina": -10,
					"supplies": 10
				}
			},
			"right": {
				"text": "Accept the loss and focus on finding safety.",
				"next_card": 8,
				"resources": {
					"stamina": 5,
					"supplies": -10
				}
			}
		}
	},
	11: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-3.png",
		"title": "You chose to stay at home despite rising risks.",
		"choices": {
			"left": {
				"text": "Reinforce your shelter with remaining resources.",
				"next_card": 9,
				"resources": {
					"supplies": -10,
					"property": 10
				}
			},
			"right": {
				"text": "Conserve your energy and supplies for a prolonged wait.",
				"next_card": 9,
				"resources": {
					"supplies": -5,
					"stamina": 10
				}
			}
		}
	},
	12: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-4.png",
		"title": "You participate in activities at the evacuation center and follow instructions.",
		"choices": {
			"left": {
				"text": "Continue cooperating, contributing to a positive environment.",
				"next_card": "recovery",
				"resources": {
					"morale": 10,
					"stamina": 5
				}
			},
			"right": {
				"text": "Focus on yourself and minimize interactions.",
				"next_card": "recovery",
				"resources": {
					"supplies": 5,
					"morale": -5
				}
			}
		}
	},
	13: {
		"phase": "crisis",
		"type": "regular",
		"image": "res://Art/test-squares-1.png",
		"title": "You decide to focus on your own needs and preparations.",
		"choices": {
			"left": {
				"text": "Conserve your supplies for future needs.",
				"next_card": "recovery",
				"resources": {
					"supplies": 10,
					"morale": -5
				}
			},
			"right": {
				"text": "Use some of your supplies to create a makeshift sleeping area for yourself.",
				"next_card": "recovery",
				"resources": {
					"supplies": -5,
					"stamina": 10
				}
			}
		}
	},

	# Recovery Phase
	16: {
		"phase": "recovery",
		"type": "regular",
		"image": "res://Art/test-squares-2.png",
		"title": "You emerge from the debris, but you're facing resource scarcity.",
		"choices": {
			"left": {
				"text": "Search nearby houses for food and water.",
				"next_card": 17,
				"resources": {
					"supplies": 10,
					"stamina": -10
				}
			},
			"right": {
				"text": "Move toward a known safe zone, hoping for help.",
				"next_card": 18,
				"resources": {
					"stamina": -10,
					"morale": 5
				}
			}
		}
	},
	17: {
		"phase": "recovery",
		"type": "regular",
		"image": "res://Art/test-squares-3.png",
		"title": "You found some supplies, but now you must contend with unstable structures.",
		"choices": {
			"left": {
				"text": "Use available tools to stabilize the structure, making it safer for shelter.",
				"next_card": 19,
				"resources": {
					"property": 15,
					"stamina": -10
				}
			},
			"right": {
				"text": "Keep moving toward a safer location, hoping the structure will hold.",
				"next_card": 20,
				"resources": {
					"property": -5,
					"stamina": -10,
					"morale": 5
				}
			}
		}
	},
	18: {
		"phase": "recovery",
		"type": "regular",
		"image": "res://Art/test-squares-4.png",
		"title": "You’re heading toward the safe zone, but you encounter another group of survivors.",
		"choices": {
			"left": {
				"text": "Share your supplies with them, knowing the risks of depleting your own.",
				"next_card": 21,
				"resources": {
					"supplies": -10,
					"morale": 10
				}
			},
			"right": {
				"text": "Keep your supplies to yourself, prioritizing your own survival.",
				"next_card": 22,
				"resources": {
					"supplies": 5,
					"morale": -5
				}
			}
		}
	},
	19: {
		"phase": "recovery",
		"type": "regular",
		"image": "res://Art/test-squares-1.png",
		"title": "You’ve reached a temporary refuge, but disease is spreading in the area.",
		"choices": {
			"left": {
				"text": "Help organize the shelter and provide assistance to those in need.",
				"next_card": 23,
				"resources": {
					"morale": 10,
					"stamina": -10
				}
			},
			"right": {
				"text": "Keep to yourself, focusing only on your own survival.",
				"next_card": 24,
				"resources": {
					"morale": -5,
					"supplies": 5
				}
			}
		}
	},
	20: {
		"phase": "recovery",
		"type": "regular",
		"image": "res://Art/test-squares-2.png",
		"title": "You continue your journey toward safety, but the terrain is difficult.",
		"choices": {
			"left": {
				"text": "Rest and recuperate, hoping your stamina holds out.",
				"next_card": 25,
				"resources": {
					"stamina": 10,
					"morale": -5
				}
			},
			"right": {
				"text": "Push through the exhaustion to reach the safe zone as fast as you can.",
				"next_card": 26,
				"resources": {
					"stamina": -10,
					"morale": 10
				}
			}
		}
	},

	# Concluding Phase
	21: {
		"phase": "concluding",
		"type": "win",
		"image": "res://Art/test-squares-3.png",
		"title": "Safe Haven Secured",
		"description": "You finally reach an evacuation center. Rescue personnel greet you with food, water, and medical care. You survived and reunited with your community."
	},
	22: {
		"phase": "concluding",
		"type": "win",
		"image": "res://Art/test-squares-4.png",
		"title": "Community Leader",
		"description": "Your leadership and resourcefulness allowed a group of survivors to reach safety. You inspire others with your courage."
	},
	23: {
		"phase": "concluding",
		"type": "win",
		"image": "res://Art/test-squares-1.png",
		"title": "Rebuilding Starts Here",
		"description": "You balanced resource management and property repairs. Aid arrives, and you begin rebuilding your community."
	},
	24: {
		"phase": "concluding",
		"type": "lose",
		"image": "res://Art/test-squares-2.png",
		"title": "Despair and Isolation",
		"description": "You lost the will to continue. Supplies ran out, and rescue never arrived. A tragic end to your story."
	},
	25: {
		"phase": "concluding",
		"type": "lose",
		"image": "res://Art/test-squares-3.png",
		"title": "Property Over People",
		"description": "You focused on your property and neglected survival. The storm claimed everything you held dear."
	},
	26: {
		"phase": "concluding",
		"type": "lose",
		"image": "res://Art/test-squares-4.png",
		"title": "Starvation and Dehydration",
		"description": "Running out of supplies left you too weak to survive. The harsh conditions claimed your life."
	}
};


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Populate the states and the final states
	for id in cards.keys():
		var card = cards[id]
		if card["phase"] == "concluding":
			final_states.append(id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
