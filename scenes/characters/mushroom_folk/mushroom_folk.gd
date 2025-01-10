extends Node3D

@onready var static_body: StaticBody3D = $StaticBody3D
@onready var interaction_handler: InteractionHandler = $InteractionHandler
@onready var original_rotation: Vector3 = global_rotation

var player: Player
var is_tracking_player: bool = false

func _ready() -> void:
	if not name == "SpeakerMushroom":
		interaction_handler.queue_free()

	set_physics_process(false)
	set_process_input(false)

	if scale <= Vector3(0.1, 0.1, 0.1):
		static_body.collision_layer = 0

func _process(_delta: float) -> void:
	if not player:
		return

	if not is_tracking_player:
		if global_rotation != original_rotation:
			rotation = lerp(rotation, original_rotation, 0.05)
		return

	var target := Vector3(
		player.transform.origin.x,
		global_transform.origin.y,
		player.transform.origin.z)

	look_at(target, Vector3.UP, true)

func stop_tracking_player() -> void:
	is_tracking_player = false

func start_tracking_player() -> void:
	is_tracking_player = true
