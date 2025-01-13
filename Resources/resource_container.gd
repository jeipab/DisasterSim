extends Node2D

func _ready() -> void:
	# Container now just manages the group of resources
	var resources = $Grouped.get_children()
	print("[ResourceContainer] Managing ", resources.size(), " resources")
