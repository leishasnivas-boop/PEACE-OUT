extends Node3D
## Builds the maze, runs A* pathfinding for the enemy, and decides win / lose.
##   Win : player touches the green exit.
##   Lose: the enemy catches the player.

const MazeGenerator = preload("res://MAP/maze_generator.gd")
const PLAYER_SCENE := preload("res://PLAYER/player.tscn")
const ENEMY_SCENE := preload("res://ENEMY/enemy.tscn")
const HUD_SCENE := preload("res://UI/hud.tscn")
const GAME_OVER_SCENE := preload("res://UI/game_over.tscn")

@export var cols: int = 21           # maze size in cells (odd numbers)
@export var rows: int = 21
@export var cell_size: float = 3.0   # width of one cell in metres
@export var wall_height: float = 3.0

var grid: Array = []
var astar := AStarGrid2D.new()
var player: CharacterBody3D
var enemy: CharacterBody3D
var hud: CanvasLayer
var game_over_ui: CanvasLayer
var elapsed: float = 0.0
var finished: bool = false


func _ready() -> void:
	_setup_environment()
	grid = MazeGenerator.generate(cols, rows)
	rows = grid.size()
	cols = grid[0].size()
	_build_floor_and_ceiling()
	_build_walls()
	_setup_astar()
	_spawn_exit()
	_spawn_player()
	_spawn_enemy()
	_spawn_ui()


func _process(delta: float) -> void:
	if finished:
		return
	elapsed += delta
	hud.set_time(GameState.format_time(elapsed))
	hud.set_stamina(player.stamina / player.max_stamina)

	var wake_left: float = enemy.time_until_wake()
	if wake_left > 0.0:
		hud.set_message("The enemy wakes in %d..." % ceili(wake_left))
		hud.set_danger(false)
	else:
		hud.set_message("Find the GREEN exit!")
		var d := player.global_position.distance_to(enemy.global_position)
		hud.set_danger(d < 10.0)


# ---------------------------------------------------------------------------
# Pathfinding (used by the enemy)
# ---------------------------------------------------------------------------

func world_to_cell(p: Vector3) -> Vector2i:
	return Vector2i(int(floor(p.x / cell_size)), int(floor(p.z / cell_size)))


func cell_to_world(c: Vector2i) -> Vector3:
	return Vector3((c.x + 0.5) * cell_size, 0.0, (c.y + 0.5) * cell_size)


## Returns the A* path between two world positions as cell-centre waypoints.
func find_path(from_pos: Vector3, to_pos: Vector3) -> PackedVector3Array:
	var result := PackedVector3Array()
	var a := world_to_cell(from_pos)
	var b := world_to_cell(to_pos)
	if not astar.is_in_boundsv(a) or not astar.is_in_boundsv(b):
		return result
	if astar.is_point_solid(a) or astar.is_point_solid(b):
		return result
	for cell in astar.get_id_path(a, b):
		result.append(cell_to_world(cell))
	return result


func _setup_astar() -> void:
	astar.region = Rect2i(0, 0, cols, rows)
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	for y in rows:
		for x in cols:
			if grid[y][x] == 1:
				astar.set_point_solid(Vector2i(x, y), true)


# ---------------------------------------------------------------------------
# Building the level
# ---------------------------------------------------------------------------

func _setup_environment() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.01, 0.01, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.3, 0.3, 0.4)
	env.ambient_light_energy = 0.5
	env.fog_enabled = true
	env.fog_light_color = Color(0.02, 0.02, 0.04)
	env.fog_density = 0.04
	var world_env := WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)


func _make_material(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m


func _build_floor_and_ceiling() -> void:
	var width := cols * cell_size
	var depth := rows * cell_size
	var center_xz := Vector3(width / 2.0, 0.0, depth / 2.0)

	# Floor (with collision so the player can stand on it)
	var floor_body := StaticBody3D.new()
	floor_body.position = center_xz + Vector3(0, -0.1, 0)
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(width, 0.2, depth)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	var floor_mesh := MeshInstance3D.new()
	var floor_mesh_box := BoxMesh.new()
	floor_mesh_box.size = floor_box.size
	floor_mesh.mesh = floor_mesh_box
	floor_mesh.material_override = _make_material(Color(0.12, 0.11, 0.1))
	floor_body.add_child(floor_mesh)
	add_child(floor_body)

	# Ceiling (visual only)
	var ceiling := MeshInstance3D.new()
	var ceiling_box := BoxMesh.new()
	ceiling_box.size = Vector3(width, 0.2, depth)
	ceiling.mesh = ceiling_box
	ceiling.position = center_xz + Vector3(0, wall_height + 0.1, 0)
	ceiling.material_override = _make_material(Color(0.08, 0.08, 0.09))
	add_child(ceiling)


func _build_walls() -> void:
	var wall_material := _make_material(Color(0.35, 0.37, 0.45))
	var walls := Node3D.new()
	walls.name = "Walls"
	add_child(walls)

	for y in rows:
		for x in cols:
			if grid[y][x] != 1:
				continue
			var wall := StaticBody3D.new()
			wall.position = Vector3(
				(x + 0.5) * cell_size, wall_height / 2.0, (y + 0.5) * cell_size)

			var shape := CollisionShape3D.new()
			var box_shape := BoxShape3D.new()
			box_shape.size = Vector3(cell_size, wall_height, cell_size)
			shape.shape = box_shape
			wall.add_child(shape)

			var mesh := MeshInstance3D.new()
			var box_mesh := BoxMesh.new()
			box_mesh.size = box_shape.size
			mesh.mesh = box_mesh
			mesh.material_override = wall_material
			wall.add_child(mesh)

			walls.add_child(wall)


func _spawn_exit() -> void:
	var exit_cell := Vector2i(cols - 2, rows - 2)
	var exit_area := Area3D.new()
	exit_area.name = "Exit"
	exit_area.position = cell_to_world(exit_cell) + Vector3(0, 1.0, 0)

	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(cell_size * 0.8, 2.0, cell_size * 0.8)
	shape.shape = box
	exit_area.add_child(shape)

	var mesh := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1.2, 2.0, 1.2)
	mesh.mesh = box_mesh
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(0.1, 1.0, 0.3)
	glow.emission_enabled = true
	glow.emission = Color(0.1, 1.0, 0.3)
	glow.emission_energy_multiplier = 2.0
	mesh.material_override = glow
	exit_area.add_child(mesh)

	var light := OmniLight3D.new()
	light.light_color = Color(0.2, 1.0, 0.4)
	light.omni_range = 9.0
	light.light_energy = 2.0
	exit_area.add_child(light)

	exit_area.body_entered.connect(_on_exit_body_entered)
	add_child(exit_area)


func _spawn_player() -> void:
	player = PLAYER_SCENE.instantiate()
	add_child(player)
	player.global_position = cell_to_world(Vector2i(1, 1)) + Vector3(0, 1.0, 0)


func _spawn_enemy() -> void:
	enemy = ENEMY_SCENE.instantiate()
	add_child(enemy)
	var start_cell := _nearest_open_cell(Vector2i(cols / 2, rows / 2))
	enemy.global_position = cell_to_world(start_cell) + Vector3(0, 1.15, 0)
	enemy.setup(player, self)
	enemy.caught_player.connect(_on_player_caught)


func _spawn_ui() -> void:
	hud = HUD_SCENE.instantiate()
	add_child(hud)
	game_over_ui = GAME_OVER_SCENE.instantiate()
	add_child(game_over_ui)


func _nearest_open_cell(target: Vector2i) -> Vector2i:
	var best := Vector2i(1, 1)
	var best_dist := INF
	for y in rows:
		for x in cols:
			if grid[y][x] == 0:
				var d := Vector2(x, y).distance_to(Vector2(target))
				if d < best_dist:
					best_dist = d
					best = Vector2i(x, y)
	return best


# ---------------------------------------------------------------------------
# Win / lose
# ---------------------------------------------------------------------------

func _on_exit_body_entered(body: Node3D) -> void:
	if body == player and not finished:
		_end_game(true)


func _on_player_caught() -> void:
	if not finished:
		_end_game(false)


func _end_game(won: bool) -> void:
	finished = true
	player.can_move = false
	var new_record := false
	if won:
		new_record = GameState.record_win(elapsed)
	game_over_ui.show_result(won, GameState.format_time(elapsed), new_record)
