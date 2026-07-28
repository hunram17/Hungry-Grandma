extends CharacterBody2D

@export var speed: float = 350.0
@export var catch_distance: float = 40.0 # How close she needs to be to grab the player

var player: Node2D = null

func _ready() -> void:
	# Ghost phases through walls
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)

func _physics_process(delta: float) -> void:
	# 1. Try to find the player if we don't have it yet
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		
	# 2. If the player STILL doesn't exist, wait until they do
	if player == null:
		return

	# 3. Move continuously toward the player's current position
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()

	# 4. Ghostly bobbing effect
	position.y += sin(Time.get_ticks_msec() * 0.005) * 0.5
	
	# 5. Check if Grandma caught the player!
	if global_position.distance_to(player.global_position) < catch_distance:
		_catch_player()

# --- Custom Functions ---

func _catch_player() -> void:
	print("Grandma caught the player!")
	
	# Teleport the player! 
	# Change (0, 0) to whatever X and Y coordinates you want the respawn room to be.
	player.global_position = Vector2(0, 0)
