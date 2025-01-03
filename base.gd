extends Area2D

var grow_speed := 5.0 # Speed of the grow/shrink animation
var original_scale := Vector2(1, 1) # Original scale
var grow_scale := Vector2(1.2, 1.2) # Scale during growth
var animating := false # Prevents repeated clicks during animation
var flip_direction := 1 # Tracks the direction of the flip (1 or -1)

func _ready() -> void:
	original_scale = scale
	self.connect("input_event", Callable(self, "_on_area2d_input_event"))

func _on_area2d_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not animating:
		animating = true
		animate()

func animate() -> void:
	var tween = get_tree().create_tween()
	
	# Step 1: Grow
	tween.tween_property(self, "scale", grow_scale, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# Step 2: Flip (in the same direction)
	flip_direction *= -1 # Toggle between 1 and -1
	tween.tween_property(self, "scale:x", original_scale.x * flip_direction * 1.2, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Step 3: Shrink back to original size
	tween.tween_property(self, "scale", Vector2(original_scale.x * flip_direction, original_scale.y), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# Step 4: Reset to original orientation
	tween.tween_callback(func():
		scale = original_scale
		flip_direction = 1
		animating = false)
