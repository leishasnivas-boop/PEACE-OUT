extends RefCounted
## Builds a random maze with the "recursive backtracker" (depth-first search).
## grid[y][x] == 1 means wall, 0 means open floor.
## Usage: var grid = MazeGenerator.generate(21, 21)


static func generate(cols: int, rows: int, loop_chance: float = 0.08) -> Array:
	# The algorithm needs odd sizes so walls and corridors alternate.
	if cols % 2 == 0:
		cols += 1
	if rows % 2 == 0:
		rows += 1

	var rng := RandomNumberGenerator.new()
	rng.randomize()

	# 1. Start with a grid full of walls.
	var grid: Array = []
	for y in rows:
		var row: Array = []
		row.resize(cols)
		row.fill(1)
		grid.append(row)

	# 2. Carve corridors with depth-first search from the top-left cell.
	var directions: Array[Vector2i] = [
		Vector2i(2, 0), Vector2i(-2, 0), Vector2i(0, 2), Vector2i(0, -2)
	]
	var stack: Array[Vector2i] = [Vector2i(1, 1)]
	grid[1][1] = 0

	while not stack.is_empty():
		var current: Vector2i = stack.back()
		var options: Array[Vector2i] = []
		for d in directions:
			var n: Vector2i = current + d
			if n.x > 0 and n.y > 0 and n.x < cols - 1 and n.y < rows - 1 and grid[n.y][n.x] == 1:
				options.append(d)

		if options.is_empty():
			stack.pop_back()   # dead end: backtrack
		else:
			var step: Vector2i = options[rng.randi() % options.size()]
			var wall_between: Vector2i = current + step / 2
			var next_cell: Vector2i = current + step
			grid[wall_between.y][wall_between.x] = 0
			grid[next_cell.y][next_cell.x] = 0
			stack.append(next_cell)

	# 3. Knock out a few walls so the maze has loops (gives the player
	#    a chance to run around the enemy instead of only dead ends).
	for y in range(1, rows - 1):
		for x in range(1, cols - 1):
			var is_wall_between_cells: bool = (x % 2) != (y % 2)
			if grid[y][x] == 1 and is_wall_between_cells and rng.randf() < loop_chance:
				grid[y][x] = 0

	return grid
