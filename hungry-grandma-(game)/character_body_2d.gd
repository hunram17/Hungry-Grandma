extends CharacterBody2D
# --- Speed Settings ---
@export var max_speed: float = 900.0
@export var acceleration: float = 3000.0
@export var friction: float = 1500.0
@export var air_friction: float = 400.0
# --- Jump Settings ---
@export var jump_force: float = -1800.0
@export var gravity_up: float = 980
@export var gravity_down: float = 980    # fast fall
@export var jump_buffer_time: float = 0.12
@export var coyote_time: float = 0.10
@export var max_jumps: int = 2
# --- Drop-Through Settings ---
@export var drop_through_duration: float = 0.15
# --- Internal State ---
var _jump_buffer: float = 0.0
var _coyote: float = 0.0
var _was_on_floor: bool = false
var _drop_timer: float = 0.0
var _jumps_remaining: int = 0
func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_jump_buffer(delta)
	_handle_coyote(delta)
	_handle_horizontal(delta)
	_handle_jump()
	_handle_drop_through(delta)
	move_and_slide()
func _handle_gravity(delta: float) -> void:
	if not is_on_floor():
		var grav := gravity_up if velocity.y < 0 else gravity_down
		velocity.y += grav * delta
		velocity.y = min(velocity.y, 2000.0)
func _handle_jump_buffer(delta: float) -> void:
	if _jump_buffer > 0:
		_jump_buffer -= delta
	if Input.is_action_just_pressed("jump"):
		_jump_buffer = jump_buffer_time
func _handle_coyote(delta: float) -> void:
	if is_on_floor():
		_coyote = coyote_time
		_was_on_floor = true
		_jumps_remaining = max_jumps
	else:
		if _was_on_floor:
			_coyote -= delta
			if _coyote <= 0:
				_was_on_floor = false
func _handle_horizontal(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0:
		velocity.x = move_toward(velocity.x, dir * max_speed, acceleration * delta)
	else:
		var fric := friction if is_on_floor() else air_friction
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)
func _handle_jump() -> void:
	var can_jump := is_on_floor() or (_coyote > 0 and _was_on_floor)
	if can_jump and _jumps_remaining == 0:
		_jumps_remaining = max_jumps
	if _jump_buffer > 0 and _jumps_remaining > 0:
		velocity.y = jump_force
		_jump_buffer = 0.0
		_jumps_remaining -= 1
		if can_jump:
			_coyote = 0.0
			_was_on_floor = false
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.5
func _handle_drop_through(delta: float) -> void:
	if _drop_timer > 0:
		_drop_timer -= delta
		if _drop_timer <= 0:
			set_collision_mask_value(2, true)
	if Input.is_action_just_pressed("drop_down") and is_on_floor():
		set_collision_mask_value(2, false)
		velocity.y = 50.0
		_drop_timer = drop_through_duration
