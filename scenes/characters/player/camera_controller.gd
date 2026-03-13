extends Node

@onready var twist_pivot: Node3D = $TwistPivot
@onready var pitch_pivot: Node3D = $TwistPivot/PitchPivot
@onready var spring_arm: SpringArm3D = %SpringArm3D

@export var min_pitch: float = -45.0
@export var max_pitch: float = 45.0
@export var camera_zoom_speed: float = 4.0
@export var camera_zoom_min_distance: float = 3.0
@onready var camera_zoom_max_distance: float = spring_arm.spring_length
@onready var target_zoom_length: float = camera_zoom_min_distance
@export var mouse_sensitivity: float = 0.001

# Accumulated mouse/controller delta, applied and cleared each physics frame.
var look: Vector2 = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		look -= event.relative * mouse_sensitivity

func _physics_process(_delta: float) -> void:
	handle_camera_rotation()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(ActionNames.CAMERA_ZOOM_IN):
		target_zoom_length = clamp(target_zoom_length - camera_zoom_speed, camera_zoom_min_distance, camera_zoom_max_distance)
	elif Input.is_action_just_pressed(ActionNames.CAMERA_ZOOM_OUT):
		target_zoom_length = clamp(target_zoom_length + camera_zoom_speed, camera_zoom_min_distance, camera_zoom_max_distance)

	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom_length, camera_zoom_speed * delta)

func handle_camera_rotation() -> void:
	twist_pivot.rotate_y(look.x)
	pitch_pivot.rotate_x(look.y)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(min_pitch), deg_to_rad(max_pitch))
	look = Vector2.ZERO