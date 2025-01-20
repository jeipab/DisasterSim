extends Node2D

@onready var progress_bar = $CanvasLayer/ProgressBar
@onready var loading_text = $CanvasLayer/LoadingText
@onready var animation_player = $AnimationPlayer
@onready var loading_bgm: AudioStreamPlayer = $loading_bgm

var scenes_to_load = {
	"game": "res://Game/game.tscn",
	"card_system": "res://CardSystem/card_system.tscn",
	"resource_container": "res://Resources/resource_container.tscn"
}

var loading_progress = {}
var scene_resources = {}
var is_transitioning = false
var max_progress_reached = 0.0  # Track maximum progress

# Smooth progress variables
var current_display_progress: float = 0.0
var target_progress: float = 0.0
const SMOOTHING_SPEED = 2.0
const MIN_LOAD_TIME = 1.0  # Minimum loading time in seconds
var load_start_time: float = 0.0

# BGM control variables
const BGM_START_THRESHOLD = 5.0  # Start BGM when progress reaches 5%
const PROGRESS_STALL_THRESHOLD = 0.1  # How much progress needs to change to be considered "moving"
var bgm_started = false
var last_progress = 0.0
var stall_timer = 0.0
const STALL_CHECK_TIME = 0.5  # How long to wait before considering progress stalled


func _ready():
	# Verify all required nodes are present
	if not progress_bar or not loading_text:
		push_error("Required nodes not found in Loading scene")
		get_tree().quit()
	
	# Initialize progress bar
	if progress_bar:
		progress_bar.value = 0
		
	# Start loading animation
	if animation_player:
		animation_player.play("fade_in")
	
	# Initialize loading
	load_start_time = Time.get_unix_time_from_system()
	
	# Initialize loading for each scene
	for key in scenes_to_load:
		var scene_path = scenes_to_load[key]
		print("[Loading] Requesting load for: ", scene_path)
		ResourceLoader.load_threaded_request(scene_path)
		loading_progress[scene_path] = 0.0

func _process(delta):
	if is_transitioning:
		return
		
	var total_progress = 0.0
	var all_loaded = true
	var scenes_processed = 0
	
	# Update progress for each scene
	for scene_path in loading_progress:
		var progress_array = []
		var status = ResourceLoader.load_threaded_get_status(scene_path, progress_array)
		
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				all_loaded = false
				if progress_array.size() > 0:
					# Ensure progress never decreases for a scene
					var new_progress = progress_array[0]
					loading_progress[scene_path] = maxf(loading_progress[scene_path], new_progress)
				scenes_processed += 1
			ResourceLoader.THREAD_LOAD_LOADED:
				if not scene_resources.has(scene_path):
					print("[Loading] Getting loaded resource: ", scene_path)
					scene_resources[scene_path] = ResourceLoader.load_threaded_get(scene_path)
				loading_progress[scene_path] = 1.0
				scenes_processed += 1
			ResourceLoader.THREAD_LOAD_FAILED:
				push_error("[Loading] Failed to load: " + scene_path)
				scenes_processed += 1
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				push_error("[Loading] Invalid resource: " + scene_path)
				scenes_processed += 1
		
		total_progress += loading_progress[scene_path]
	
	# Only update progress if we've processed all scenes
	if scenes_processed == loading_progress.size():
		# Calculate target progress
		var new_target = (total_progress / loading_progress.size()) * 100
		
		# Ensure target progress never decreases
		target_progress = maxf(target_progress, new_target)
		
		# Update max progress reached
		max_progress_reached = maxf(max_progress_reached, current_display_progress)
		
		# Ensure current progress never goes backwards
		current_display_progress = lerp(
			max_progress_reached, 
			target_progress, 
			delta * SMOOTHING_SPEED
		)
		
		var progress_delta = abs(current_display_progress - last_progress)
		
		if progress_delta > PROGRESS_STALL_THRESHOLD:
			# Progress is moving
			stall_timer = 0.0
			if not loading_bgm.playing and current_display_progress >= BGM_START_THRESHOLD:
				loading_bgm.play()
		else:
			# Progress might be stalled
			stall_timer += delta
			if stall_timer >= STALL_CHECK_TIME and loading_bgm.playing:
				loading_bgm.stop()
		
		last_progress = current_display_progress		
		
		# Update UI with smoothed progress
		if progress_bar and loading_text:
			progress_bar.value = current_display_progress
			loading_text.text = "Loading... %d%%" % round(current_display_progress)
	
	# Check if minimum load time has passed
	var current_time = Time.get_unix_time_from_system()
	var time_elapsed = current_time - load_start_time
	
	# Handle completion - only if minimum time has passed
	if all_loaded and scene_resources.size() == scenes_to_load.size() and time_elapsed >= MIN_LOAD_TIME:
		# Ensure we reach 100% before transitioning
		if current_display_progress >= 99.9:
			transition_to_game()

func transition_to_game():
	if is_transitioning:
		return
		
	is_transitioning = true
	print("[Loading] All resources loaded, preparing transition...")
	
	# Fade out BGM if it's playing
	if loading_bgm.playing:
		var tween = create_tween()
		tween.tween_property(loading_bgm, "volume_db", -80.0, 0.5)
		await tween.finished
		loading_bgm.stop()	
	
	# Ensure progress bar shows 100%
	if progress_bar:
		progress_bar.value = 100
		loading_text.text = "Loading... 100%"
	
	# Add a small delay for smoother transition
	await get_tree().create_timer(0.5).timeout
	
	# Wait for fade animation
	if animation_player:
		animation_player.play("fade_out")
		await animation_player.animation_finished
	
	print("[Loading] Transitioning to game scene...")
	# Change to game scene
	get_tree().change_scene_to_file("res://Game/game.tscn")
