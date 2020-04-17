extends Node2D

enum {move, wait}
var state


export (int) var offset

export(NodePath) var Tiles
onready var Til = get_node(Tiles)
onready var play_board_tiles = Til.play_board
onready var obstacle_tiles = Til.obstacles
onready var generator_tiles = Til.generator
export (PoolVector2Array) var empty_spaces
export (PoolVector2Array) var lock_pieces

# The piece array
var possible_pieces = [
preload("res://Pieces/Piece1.tscn"),
preload("res://Pieces/Piece2.tscn"),
preload("res://Pieces/Piece3.tscn"),
preload("res://Pieces/Piece4.tscn"),
preload("res://Pieces/Piece5.tscn"),
preload("res://Pieces/Piece6.tscn")
];

var all_pieces = []
var move_checked = false
var ready = false
var can_check = false
var anim_time = 0.2
var play_board = []
var obstacles = []
var generators = []

func _ready():
	randomize()
	for i in Til.get_used_cells():
		if Til.get_cellv(i) in play_board_tiles:
			play_board.append(i)
		elif Til.get_cellv(i) in obstacle_tiles:
			obstacles.append(i)
		elif Til.get_cellv(i) in generator_tiles:
			generators.append(i)
	$IsMoving.wait_time = anim_time + 0.01
	all_pieces = make_2d_array()
	spawn_pieces()
	ready = true
#	spawn_ice()
#	spawn_locks()
#	spawn_concrete()
#	spawn_slime()

func _process(delta):
	if ready:
		for cood in generators + play_board: # maybe looping for end to generator is better
			if !check_exist(cood):
				all_pieces[cood.x][cood.y] = null
			push(cood)
			if (can_check
				and cood in play_board
				and check_exist(cood)
				and !all_pieces[cood.x][cood.y].is_moving
				and !all_pieces[cood.x][cood.y].matched):
				check_match_(cood)
			
func check_exist(cood):
	if all_pieces[cood.x][cood.y] != null and weakref(all_pieces[cood.x][cood.y]).get_ref():
		return true
	else:
		return false
			
func push(cood):
	var tile_id = Til.get_cellv(cood)
	if tile_id in [1, 2, 3, 4]:
		if (tile_id == 1 
			and !check_exist(cood + Vector2(0, -1)) 
			and Til.get_cellv(cood + Vector2(0, -1)) in play_board_tiles):
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(cood.x, cood.y)
			all_pieces[cood.x][cood.y - 1] = piece
			piece.move(grid_to_pixel(cood.x, cood.y - 1))
		if (tile_id == 2 
			and !check_exist(cood + Vector2(1, 0)) 
			and Til.get_cellv(cood + Vector2(1, 0)) in play_board_tiles):
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(cood.x, cood.y)	
			all_pieces[cood.x + 1][cood.y] = piece
			piece.move(grid_to_pixel(cood.x + 1, cood.y))
		if (tile_id == 3 
			and all_pieces[cood.x][cood.y + 1] == null#!check_exist(cood + Vector2(0, 1)) 
			and Til.get_cellv(cood + Vector2(0, 1)) in play_board_tiles):
			var rand = floor(rand_range(0, possible_pieces.size()))			
			var piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(cood.x, cood.y)
			all_pieces[cood.x][cood.y + 1] = piece
			piece.move(grid_to_pixel(cood.x, cood.y + 1))
		if (tile_id == 4 
			and !check_exist(cood + Vector2(-1, 0)) 
			and Til.get_cellv(cood + Vector2(-1, 0)) in play_board_tiles):
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(cood.x, cood.y)
			all_pieces[cood.x - 1][cood.y] = piece
			piece.move(grid_to_pixel(cood.x - 1, cood.y))			
	if (check_exist(cood) 
		and !all_pieces[cood.x][cood.y].is_locked
		and !all_pieces[cood.x][cood.y].is_moving):
		if (tile_id in [5, 12, 16] 
			and !check_exist(cood + Vector2(0, -1)) 
			and Til.id_to_name[Til.get_cellv(cood + Vector2(0, -1))][0] == "1"):
			all_pieces[cood.x][cood.y].move(grid_to_pixel(cood.x, cood.y - 1))
			all_pieces[cood.x][cood.y - 1] = all_pieces[cood.x][cood.y]
			all_pieces[cood.x][cood.y] = null
		if (tile_id in [6, 9, 15] 
			and !check_exist(cood + Vector2(1, 0)) 
			and Til.id_to_name[Til.get_cellv(cood + Vector2(1, 0))][0] == "1"):
			all_pieces[cood.x][cood.y].move(grid_to_pixel(cood.x + 1, cood.y))
			all_pieces[cood.x + 1][cood.y] = all_pieces[cood.x][cood.y]
			all_pieces[cood.x][cood.y] = null
		if (tile_id in [7, 10, 14] 
			and !check_exist(cood + Vector2(0, 1)) 
			and Til.id_to_name[Til.get_cellv(cood + Vector2(0, 1))][0] == "1"):
			all_pieces[cood.x][cood.y].move(grid_to_pixel(cood.x, cood.y + 1))
			all_pieces[cood.x][cood.y + 1] = all_pieces[cood.x][cood.y]
			all_pieces[cood.x][cood.y] = null
		if (tile_id in [8, 11, 13] 
			and !check_exist(cood + Vector2(-1, 0)) 
			and Til.id_to_name[Til.get_cellv(cood + Vector2(-1, 0))][0] == "1"):
			all_pieces[cood.x][cood.y].move(grid_to_pixel(cood.x - 1, cood.y))
			all_pieces[cood.x - 1][cood.y] = all_pieces[cood.x][cood.y]
			all_pieces[cood.x][cood.y] = null
			
	
func check_match_(cood, f_dir=0, f_num=0):
	all_pieces[cood.x][cood.y].matched = true
	var h_start = true
	var v_start = true
	var vh_num = [1, 1, 1, 1] # right, left, up, down
	vh_num[f_dir] += f_num
#	print(cood)
	if (check_exist(cood + Vector2(1, 0)) 
			and !all_pieces[cood.x + 1][cood.y].is_moving
			and all_pieces[cood.x + 1][cood.y].color == all_pieces[cood.x][cood.y].color):
		if !all_pieces[cood.x + 1][cood.y].matched:
#			print(cood, "?")
			vh_num[0] += check_match_(cood + Vector2(1, 0), 1, vh_num[1])[0]
		else:
			h_start = false
	if (check_exist(cood + Vector2(-1, 0)) 
			and !all_pieces[cood.x - 1][cood.y].is_moving
			and all_pieces[cood.x - 1][cood.y].color == all_pieces[cood.x][cood.y].color):
		if !all_pieces[cood.x - 1][cood.y].matched:
			vh_num[1] += check_match_(cood + Vector2(-1, 0), 0, vh_num[0])[1]
		else:
			h_start = false
	if (check_exist(cood + Vector2(0, 1)) 
			and !all_pieces[cood.x][cood.y + 1].is_moving
			and all_pieces[cood.x][cood.y + 1].color == all_pieces[cood.x][cood.y].color):
		if !all_pieces[cood.x][cood.y + 1].matched:
			vh_num[2] += check_match_(cood + Vector2(0, 1), 3, vh_num[3])[2]
		else:
			v_start = false
	if (check_exist(cood + Vector2(0, -1)) 
			and !all_pieces[cood.x][cood.y - 1].is_moving
			and all_pieces[cood.x][cood.y - 1].color == all_pieces[cood.x][cood.y].color):
		if !all_pieces[cood.x][cood.y - 1].matched:
			vh_num[3] += check_match_(cood + Vector2(0, -1), 2, vh_num[2])[3]
		else:
			v_start = false
#	print(cood, h_start, v_start, vh_num)
	if vh_num[0] + vh_num[1] <= 3 and vh_num[2] + vh_num[3] <= 3:
		all_pieces[cood.x][cood.y].matched = false
	if h_start:
		match vh_num[0] + vh_num[1]:
			1, 2, 3:
				pass
#				for i in vh_num[0]:
#					all_pieces[cood.x + i][cood.y].matched = false
#				for i in vh_num[1]:
#					all_pieces[cood.x - i][cood.y].matched = false
			4:
#				print(cood, h_start, v_start, vh_num)
				if vh_num[2] + vh_num[3] >= 4:
					all_pieces[cood.x][cood.y].lightning = true
				for i in vh_num[0]:
					all_pieces[cood.x + i][cood.y].dim()
					bomb_explosion(cood + Vector2(i, 0))
				for i in range(1, vh_num[1]):
					all_pieces[cood.x - i][cood.y].dim()
					bomb_explosion(cood + Vector2(-i, 0))
			5:
#				print("5")
				if vh_num[2] + vh_num[3] >= 4:
					all_pieces[cood.x][cood.y].lightning = true
					if vh_num[0] >= 2:
						all_pieces[cood.x + 1][cood.y].fire = true
					else:
						all_pieces[cood.x - 1][cood.y].fire = true
				else:
					all_pieces[cood.x][cood.y].fire = true
				for i in vh_num[0]:
					bomb_explosion(cood + Vector2(i, 0))
					all_pieces[cood.x + i][cood.y].dim()
				for i in range(1, vh_num[1]):
					bomb_explosion(cood + Vector2(-i, 0))
					all_pieces[cood.x - i][cood.y].dim()
			_:
#				print("_")
				all_pieces[cood.x][cood.y].superpower = true
				if vh_num[2] + vh_num[3] >= 4:
					if vh_num[0] >= 2:
						all_pieces[cood.x + 1][cood.y].lightning = true
					else:
						all_pieces[cood.x - 1][cood.y].lightning = true
				for i in vh_num[0]:
					bomb_explosion(cood + Vector2(i, 0))
					all_pieces[cood.x + i][cood.y].dim()
				for i in range(1, vh_num[1]):
					bomb_explosion(cood + Vector2(-i, 0))
					all_pieces[cood.x - i][cood.y].dim()
	if v_start:
		match vh_num[2] + vh_num[3]:
			1, 2, 3:
				pass
#				for i in vh_num[2]:
#					all_pieces[cood.x][cood.y + i].matched = false
#				for i in vh_num[3]:
#					all_pieces[cood.x][cood.y - i].matched = false
			4:
				if vh_num[0] + vh_num[1] >= 4:
					all_pieces[cood.x][cood.y].lightning = true
				for i in vh_num[2]:
					bomb_explosion(cood + Vector2(0, i))
					all_pieces[cood.x][cood.y + i].dim()
				for i in range(1, vh_num[3]):
					bomb_explosion(cood + Vector2(0, -i))
					all_pieces[cood.x][cood.y - i].dim()
			5:
				if vh_num[0] + vh_num[1] >= 4:
					all_pieces[cood.x][cood.y].lightning = true
					if vh_num[2] >= 2:
						all_pieces[cood.x][cood.y + 1].fire = true
					else:
						all_pieces[cood.x][cood.y - 1].fire = true
				else:
					all_pieces[cood.x][cood.y].fire = true
				for i in vh_num[2]:
					bomb_explosion(cood + Vector2(0, i))
					all_pieces[cood.x][cood.y + i].dim()					
				for i in range(1, vh_num[3]):
					bomb_explosion(cood + Vector2(0, -i))
					all_pieces[cood.x][cood.y - i].dim()
			_:
				all_pieces[cood.x][cood.y].superpower = true
				if vh_num[0] + vh_num[1] >= 4:
					if vh_num[2] >= 2:
						all_pieces[cood.x][cood.y + 1].lightning = true
					else:
						all_pieces[cood.x][cood.y - 1].lightning = true
				for i in vh_num[2]:
					bomb_explosion(cood + Vector2(0, i))
					all_pieces[cood.x][cood.y + i].dim()
				for i in range(1, vh_num[3]):
					bomb_explosion(cood + Vector2(0, -i))
					all_pieces[cood.x][cood.y - i].dim()					
#	print("???")
	return vh_num
	
func bomb_explosion(cood):
	if !check_exist(cood) or !all_pieces[cood.x][cood.y].triger:
		return
	var piece = all_pieces[cood.x][cood.y]
	if piece.superpower:
		pass
	elif piece.lightning:
		pass
	elif piece.fire:
		$FireExplosion.show()
		$FireExplosion.position = grid_to_pixel(cood.x, cood.y)
		$FireExplosion.emitting = true # make a new scene to show effects
		all_pieces[cood.x][cood.y].fast_remove()
		for i in [-1, 0, 1]:
			for j in [-1, 0, 1]:
				if (cood + Vector2(i, j) in play_board
						and check_exist(cood + Vector2(i, j))):
					if !all_pieces[cood.x + i][cood.y + j].matched:
						if i or j:
							bomb_explosion(cood + Vector2(i, j))
						all_pieces[cood.x + i][cood.y + j].fast_remove()
						pass
#		piece.queue_free()
	pass
#
#func restricted_movement(place):
#	# Check the empty pieces
#	for i in empty_spaces.size():
#		if empty_spaces[i] == place:
#			return true
#	for i in concrete_pieces.size():
#		if concrete_pieces[i] == place:
#			return true
#	for i in slime_pieces.size():
#		if slime_pieces[i] == place:
#			return true
#	return false
#	pass
	
func spawn_pieces():
	for cood in play_board:
#		if Til.id_to_name[Til.get_cellv(cood)][0] == '1':
			#choose a random number and store it
		var rand = floor(rand_range(0, possible_pieces.size()))
		var piece = possible_pieces[rand].instance()
		var loops = 0
		while(match_at(cood.x, cood.y, piece.color) && loops < 100):
			rand = floor(rand_range(0, possible_pieces.size()))
			loops += 1
			piece = possible_pieces[rand].instance()
			# Instance that piece from the array

		add_child(piece)
		piece.position = grid_to_pixel(cood.x, cood.y)
		all_pieces[cood.x][cood.y] = piece
				
func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null && all_pieces[i][j-2] != null:
			if all_pieces[i ][j-1].color == color && all_pieces[i][j-2].color == color:
				return true
				
func make_2d_array():
	var array = []
#	print(Til.get_used_rect().size)
#	print(Til.get_used_cells())
	for i in Til.get_used_rect().size.x:
		array.append([])
		for j in Til.get_used_rect().size.y:
			array[i].append(null)
	return array

func grid_to_pixel(column, row):
	var new_x = offset * column + offset / 2
	var new_y = offset * row + offset / 2
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - offset / 2) / offset)
	var new_y = round((pixel_y - offset / 2) / offset)
	return Vector2(new_x, new_y)

func is_in_grid(grid_position):
	if grid_position.x < 0 or grid_position.y < 0:
		return false
	if grid_position in play_board:
		return true
	else:
		return false

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		if !is_in_locks(Vector2(column, row)) && !is_in_locks(Vector2(column + direction.x, row + direction.y)):
#			store_info(first_piece, other_piece, Vector2(column, row), direction)
#			state = wait
			first_piece.swap_targets = [Vector2(column, row), Vector2(column + direction.x, row + direction.y)]
			move_child(other_piece, 0)
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
			first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
			other_piece.move(grid_to_pixel(column, row))
				
func is_in_locks(place):
	for i in lock_pieces.size():
		if lock_pieces[i] == place:
			return true
	return false

#func _on_piece_back(swap_targets):
#	var res = false
#	for t in swap_targets:
#		for v in [Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)]:
#			if check_match(t + v):
#				res = true
#	if !res:
#		var first_piece = all_pieces[swap_targets[0].x][swap_targets[0].y]
#		var other_piece = all_pieces[swap_targets[1].x][swap_targets[1].y]
#		all_pieces[swap_targets[0].x][swap_targets[0].y] = other_piece
#		all_pieces[swap_targets[1].x][swap_targets[1].y] = first_piece
#		first_piece.move(grid_to_pixel(swap_targets[1].x, swap_targets[1].y))
#		first_piece.swap_targets = []
#		other_piece.move(grid_to_pixel(swap_targets[0].x, swap_targets[0].y))
#		other_piece.swap_targets = []

func _on_piece_back(swap_targets):
	check_match_(swap_targets[0])
	check_match_(swap_targets[1])
	if (!all_pieces[swap_targets[0][0]][swap_targets[0][1]].matched
			and !all_pieces[swap_targets[1][0]][swap_targets[1][1]].matched):
		var first_piece = all_pieces[swap_targets[0].x][swap_targets[0].y]
		var other_piece = all_pieces[swap_targets[1].x][swap_targets[1].y]
		all_pieces[swap_targets[0].x][swap_targets[0].y] = other_piece
		all_pieces[swap_targets[1].x][swap_targets[1].y] = first_piece
		first_piece.move(grid_to_pixel(swap_targets[1].x, swap_targets[1].y))
		first_piece.swap_targets = []
		other_piece.move(grid_to_pixel(swap_targets[0].x, swap_targets[0].y))
		other_piece.swap_targets = []


func _on_IsMoving_timeout():
	can_check = true

func _on_piece_moving():
	can_check = false
	$IsMoving.start()
