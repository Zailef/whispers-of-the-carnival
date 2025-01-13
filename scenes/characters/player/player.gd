extends CharacterBody3D
class_name Player

const MAJOR_ARCANA_CARD_COUNT: int = 22

@export var player_rotation_speed: float = 160.0

@onready var state_machine: PlayerStateMachine = $PlayerStateMachine
@onready var player_idle_state: PlayerIdleState = $PlayerStateMachine/PlayerIdleState
@onready var player_move_state: PlayerMoveState = $PlayerStateMachine/PlayerMoveState
@onready var player_jump_state: PlayerJumpState = $PlayerStateMachine/PlayerJumpState
@onready var player_freeze_state: PlayerFreezeState = $PlayerStateMachine/PlayerFreezeState
@onready var player_fall_state: PlayerFallState = $PlayerStateMachine/PlayerFallState
@onready var third_person_camera: Camera3D = %ThirdPersonCamera
@onready var player_model_animated: Node3D = $PlayerModelAnimated
@onready var music_player_remote_transform: RemoteTransform3D = $MusicPlayerTransform

@export var collected_cards: Array[String] = []

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	state_machine.update(delta)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.handle_input(event)

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
