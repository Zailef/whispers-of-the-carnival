extends BaseState
class_name PlayerJumpState

const JUMPING_ANIMATION: String = "jump"

var player_node: Player

@export var jump_velocity: float = 4.5
@export var jump_grace_period: float = 0.1
@export var air_speed: float = 5.0
@export var air_control: float = 6.0

var jump_timer: float = 0.0

func _ready() -> void:
	state_name = "PLAYER_JUMP_STATE"

func enter() -> void:
	super.enter()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if player_node.is_effectively_on_floor():
		player_node.velocity.y = jump_velocity
		player_node._coyote_timer = 0.0
		jump_timer = jump_grace_period
		player_node.play_animation(JUMPING_ANIMATION)

func exit() -> void:
	super.exit()

func update(delta: float) -> void:
	if player_node.velocity.y < 0:
		player_node.state_machine.change_state(player_node.player_fall_state)
		return

	if jump_timer > 0.0:
		jump_timer -= delta

	if jump_timer <= 0.0 and player_node.is_on_floor():
		if player_node.velocity.length() > 0:
			player_node.state_machine.change_state(player_node.player_move_state)
		else:
			player_node.state_machine.change_state(player_node.player_idle_state)
		return

	var input_dir := Input.get_vector(
		ActionNames.TURN_LEFT,
		ActionNames.TURN_RIGHT,
		ActionNames.MOVE_FORWARDS,
		ActionNames.MOVE_BACKWARDS)
	var dir := player_node.get_camera_relative_direction(input_dir)
	if dir.length() > 0:
		player_node.velocity.x = lerpf(player_node.velocity.x, dir.x * air_speed, air_control * delta)
		player_node.velocity.z = lerpf(player_node.velocity.z, dir.z * air_speed, air_control * delta)
		player_node.rotate_model_toward(dir, delta)

	player_node.velocity += player_node.get_gravity() * delta
	player_node.move_and_slide()