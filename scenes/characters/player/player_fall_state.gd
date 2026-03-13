extends BaseState
class_name PlayerFallState

const FALLING_ANIMATION: String = "falling"

var player_node: Player

@export var air_speed: float = 5.0
@export var air_control: float = 6.0

func _ready() -> void:
	state_name = "PLAYER_FALL_STATE"

func enter() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	super.enter()
	player_node.play_animation(FALLING_ANIMATION)

func exit() -> void:
	super.exit()

func update(delta: float) -> void:
	if player_node.is_on_floor():
		player_node.state_machine.change_state(player_node.player_idle_state)
		return

	player_node.velocity += player_node.get_gravity() * delta

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

	player_node.move_and_slide()