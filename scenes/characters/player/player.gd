extends CharacterBody3D
class_name Player

const MAJOR_ARCANA_CARD_COUNT: int = 22

@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var player_idle_state: PlayerIdleState = $PlayerStateMachine/PlayerIdleState
@onready var player_move_state: PlayerMoveState = $PlayerStateMachine/PlayerMoveState
@onready var player_jump_state: PlayerJumpState = $PlayerStateMachine/PlayerJumpState
@onready var player_freeze_state: PlayerFreezeState = $PlayerStateMachine/PlayerFreezeState
@onready var player_fall_state: PlayerFallState = $PlayerStateMachine/PlayerFallState
@onready var third_person_camera: Camera3D = %ThirdPersonCamera
@onready var player_model_animated: Node3D = $PlayerModelAnimated
@onready var music_player_remote_transform: RemoteTransform3D = $MusicPlayerTransform
@onready var _camera_twist_pivot: Node3D = $CameraController/TwistPivot
@onready var _animation_player: AnimationPlayer = $PlayerModelAnimated/AnimationPlayer

@export var look_at_decay: float = 10.0
@export var coyote_time: float = 0.12
@export var animation_blend_time: float = 0.15

var _coyote_timer: float = 0.0

@export var collected_cards: Array[String] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	play_animation("rest")

	SignalManager.player_freeze_requested.connect(_on_player_freeze_requested)
	SignalManager.player_unfreeze_requested.connect(_on_player_unfreeze_requested)
	SignalManager.major_arcana_card_collected.connect(_on_major_arcana_card_collected)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_released("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_pressed(ActionNames.KILL_PLAYER):
		SignalManager.player_died.emit()

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	elif _coyote_timer > 0.0:
		_coyote_timer -= delta
	state_machine.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

func is_effectively_on_floor() -> bool:
	return is_on_floor() or _coyote_timer > 0.0

func get_camera_relative_direction(input_dir: Vector2) -> Vector3:
	var input_vector := Vector3(input_dir.x, 0.0, input_dir.y).normalized()
	return (_camera_twist_pivot.global_transform.basis * input_vector).normalized()

func play_animation(anim_name: String) -> void:
	if not _animation_player:
		return
	if _animation_player.current_animation == anim_name:
		return
	_animation_player.play(anim_name, animation_blend_time)

func rotate_model_toward(direction: Vector3, delta: float) -> void:
	var flat_dir := Vector3(direction.x, 0.0, direction.z)
	if flat_dir.length_squared() < 0.0001:
		return
	flat_dir = flat_dir.normalized()
	var current_scale := player_model_animated.scale
	var target_xform := player_model_animated.global_transform.looking_at(
		player_model_animated.global_transform.origin + flat_dir, Vector3.UP, true)
	player_model_animated.global_transform = player_model_animated.global_transform.interpolate_with(
		target_xform, 1.0 - exp(-look_at_decay * delta))
	player_model_animated.scale = current_scale

func _on_player_freeze_requested() -> void:
	state_machine.change_state(player_freeze_state)

func _on_player_unfreeze_requested() -> void:
	third_person_camera.make_current()
	state_machine.change_state(player_idle_state)

func _on_major_arcana_card_collected(card_name: String) -> void:
	collected_cards.append(card_name)
	SignalManager.major_acrana_card_added_to_inventory.emit(card_name)

	# Greater than or equal to is used for easier debugging
	if collected_cards.size() >= MAJOR_ARCANA_CARD_COUNT:
		SignalManager.all_major_arcana_cards_added_to_inventory.emit()
