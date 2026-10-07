extends CharacterBody3D
## Enemy AI: every fraction of a second it asks the map for an A* path to the
## player and walks along that path, so it always finds a way around walls.

signal caught_player

@export var speed: float = 3.5            # starting speed (m/s)
@export var max_speed: float = 5.5        # the chase slowly gets faster
@export var speed_gain_per_second: float = 0.03
@export var repath_interval: float = 0.25 # how often the path is recalculated
@export var catch_distance: float = 1.2
@export var start_delay: float = 5.0      # head start for the player (seconds)

var player: Node3D
var map: Node                             # the map provides find_path()
var path: PackedVector3Array = PackedVector3Array()
var path_index: int = 0
var repath_timer: float = 0.0
var wake_timer: float = 0.0
var active: bool = false

@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


func _ready() -> void:
	wake_timer = start_delay
	audio.finished.connect(audio.play)   # loop the sound


## Called by the map right after spawning the enemy.
func setup(target_player: Node3D, owner_map: Node) -> void:
	player = target_player
	map = owner_map


func time_until_wake() -> float:
	return maxf(wake_timer, 0.0)


func _physics_process(delta: float) -> void:
	if player == null or map == null:
		return

	# Wait during the player's head start.
	if not active:
		wake_timer -= delta
		if wake_timer <= 0.0:
			active = true
			audio.play()
		return

	# The enemy speeds up over time, up to max_speed.
	speed = minf(speed + speed_gain_per_second * delta, max_speed)

	# Re-calculate the A* path regularly because the player keeps moving.
	repath_timer -= delta
	if repath_timer <= 0.0:
		repath_timer = repath_interval
		path = map.find_path(global_position, player.global_position)
		path_index = 1 if path.size() > 1 else 0   # index 0 is our own cell

	# Choose where to walk: the next waypoint, or straight at the player
	# when we are already in the same cell.
	var target: Vector3 = player.global_position
	if path.size() > 1 and path_index < path.size():
		target = path[path_index]

	var to_target := target - global_position
	to_target.y = 0.0
	if to_target.length() < 0.25 and path_index < path.size() - 1:
		path_index += 1

	velocity = to_target.normalized() * speed
	velocity.y = 0.0
	move_and_slide()

	# Caught the player?
	var flat_distance := Vector2(global_position.x, global_position.z).distance_to(
		Vector2(player.global_position.x, player.global_position.z))
	if flat_distance < catch_distance:
		active = false
		audio.stop()
		caught_player.emit()
