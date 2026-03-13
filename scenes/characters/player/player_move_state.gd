extends BaseState
class_name PlayerMoveState

const SLIPPING_ANIMATION: String = "Slipping"
const RUN_ANIMATION: String = "run"

var player_node: Player

@export var move_speed: float = 5.0
@export var backward_modifier: float = 0.5
@export var sprint_modifier: float = 1.25
@export var slip_modifier: float = 1.8

var is_sprinting: bool = false
var is_slipping: bool = false
var is_moving_backward: bool = false

var direction: Vector3 = Vector3.ZERO
var input_direction: Vector2 = Vector2.ZERO

var current_move_speed: float:
	get:
		if is_moving_backward:
			return move_speed * backward_modifier
		elif is_slipping:
			return move_speed * slip_modifier
		else:
			return move_speed * (sprint_modifier if is_sprinting else 1.0)

func _ready() -> void:
	state_name = "PLAYER_MOVE_STATE"

	SignalManager.player_entered_slippery_area.connect(func(): is_slipping = true)
	SignalManager.player_exited_slippery_area.connect(func(): is_slipping = false)

func enter() -> void:
	super.enter()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func exit() -> void:
	super.exit()
	is_sprinting = false

func update(delta: float) -> void:
	input_direction = Input.get_vector(
		ActionNames.TURN_LEFT,
		ActionNames.TURN_RIGHT,
		ActionNames.MOVE_FORWARDS,
		ActionNames.MOVE_BACKWARDS)

	handle_movement(delta)
	handle_animations()
	player_node.move_and_slide()
	handle_state_transitions()

func handle_movement(delta: float) -> void:
	direction = player_node.get_camera_relative_direction(input_direction)

	is_sprinting = Input.is_action_pressed(ActionNames.SPRINT)
	is_moving_backward = Input.is_action_pressed(ActionNames.MOVE_BACKWARDS)

	if not player_node.is_on_floor():
		player_node.velocity += player_node.get_gravity() * delta

	if is_slipping:
		player_node.velocity.x = lerp(player_node.velocity.x, direction.x * current_move_speed, 0.02)
		player_node.velocity.z = lerp(player_node.velocity.z, direction.z * current_move_speed, 0.02)
	else:
		if direction.length() > 0:
			player_node.velocity.x = direction.x * current_move_speed
			player_node.velocity.z = direction.z * current_move_speed
		else:
			player_node.velocity.x = move_toward(player_node.velocity.x, 0, current_move_speed)
			player_node.velocity.z = move_toward(player_node.velocity.z, 0, current_move_speed)

	if direction.length() > 0:
		player_node.rotate_model_toward(direction, delta)

func handle_animations() -> void:
	if is_slipping:
		player_node.play_animation(SLIPPING_ANIMATION)
	else:
		player_node.play_animation(RUN_ANIMATION)

func handle_state_transitions() -> void:
	if player_node.is_effectively_on_floor():
		if player_node.velocity.length() == 0 and input_direction.length() == 0:
			player_node.state_machine.change_state(player_node.player_idle_state)
		elif Input.is_action_just_pressed(ActionNames.JUMP):
			player_node.state_machine.change_state(player_node.player_jump_state)
	else:
		player_node.state_machine.change_state(player_node.player_fall_state)
