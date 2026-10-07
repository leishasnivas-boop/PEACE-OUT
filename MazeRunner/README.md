# Maze Runner with AI-Controlled Enemy

A 3D first-person maze game made in Godot (GDScript). Reach the green exit
before the enemy catches you. The enemy chases the player using the A*
pathfinding algorithm.

## Tech stack
- Godot Engine 4.x (Standard build) + GDScript
- `AStarGrid2D` - A* pathfinding on the maze grid (enemy AI)
- `CharacterBody3D` - player and enemy movement and collision
- `Sprite3D` (billboard) + `AudioStreamPlayer3D` - enemy visuals and sound
- Recursive-backtracker (DFS) algorithm - random maze generation

## Run
1. Install Godot 4.x (Standard): `brew install --cask godot`
2. Open Godot > Import > select `project.godot` > Import & Edit
3. Press Cmd+B (or Play) to run

## Controls
WASD / Arrows = move, Mouse = look, Shift = sprint, Esc = free the mouse

## Folder structure
GLOBALS/  game_state.gd        best-time save + scene paths (autoload)
SPLASH/   splash_scene.tscn    title screen
LOBBY/    lobby.tscn           menu (start / quit)
MAP/      map.tscn, map.gd     builds maze, A* pathfinding, win/lose rules
          maze_generator.gd    random maze (DFS)
PLAYER/   player.tscn, .gd     first-person controller
ENEMY/    enemy.tscn, .gd      A* chase AI (posters/ = image, music/ = sound)
UI/       hud.*, game_over.*   in-game overlay and result screen

## How the enemy AI works
1. The map stores the maze as a grid and loads it into an `AStarGrid2D`
   (walls are marked solid).
2. Every 0.25 s the enemy asks the map for the A* path from its cell to the
   player's cell.
3. The enemy walks from waypoint to waypoint along that path, getting
   slightly faster over time.
4. If it gets within ~1.2 m of the player, the player loses.
