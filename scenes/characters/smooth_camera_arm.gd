# Attach this script to a SpringArm3D (or any Node3D) to make it smoothly
# follow a target node's world position using exponential decay.
#
# Usage: assign `target` to the Player (or a Marker3D on the player),
# then select this script on the SpringArm3D node in the inspector.
extends SpringArm3D

@export var target: Node3D
@export var decay: float = 20.0

func _physics_process(delta: float) -> void:
	if not target:
		return
	global_position = global_position.lerp(target.global_position, 1.0 - exp(-decay * delta))
