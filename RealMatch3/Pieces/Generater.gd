extends Node2D

enum {move, wait}
var state


export (int) var x_start
export (int) var y_start
export (int) var offset
export (int) var y_offset

export(NodePath) var Tiles
onready var Til = get_node(Tiles)
onready var width = Til.get_used_rect().size.x
onready var height = Til.get_used_rect().size.y
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
var piece_one = null
var piece_two = null
var last_place = Vector2(0,0)
var last_direction = Vector2(0,0)
var move_checked = false
var max_loop = 50

func _ready():
	state = move
	randomize();
	all_pieces = make_2d_array();
	spawn_pieces();
#	spawn_ice()
#	spawn_locks()
#	spawn_concrete()
#	spawn_slime()

func restricted_movement(place):
	# Check the empty pieces
	for i in empty_spaces.size():
		if empty_spaces[i] == place:
			return true
#	for i in concrete_pieces.size():
#		if concrete_pieces[i] == place:
#			return true
#	for i in slime_pieces.size():
#		if slime_pieces[i] == place:
#			return true
#	return false

func spawn_pieces():
	for cood in Til.get_used_cells():
		#print(Til.id_to_name[Til.get_cellv(cood)])
		if Til.id_to_name[Til.get_cellv(cood)][0] == '1':
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
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array

func grid_to_pixel(column, row):
	var new_x = x_start + offset * column + offset / 2
	var new_y = y_start + offset * row + offset / 2
	return Vector2(new_x, new_y)

func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start - offset / 2) / offset)
	var new_y = round((pixel_y - y_start - offset / 2) / offset)
	return Vector2(new_x, new_y)

#func is_in_grid(grid_position):
#	if grid_position.x >= 0 && grid_position.x < width:
#		if grid_position.y >= 0 && grid_position.y < height:
#			return true
#	return false

func is_in_grid(grid_position):
	if Til.id_to_name[Til.get_cellv(grid_position)][0] == '1':
		return true

func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		if !is_in_locks(Vector2(column, row)) && !is_in_locks(Vector2(column + direction.x, row + direction.y)):
			store_info(first_piece, other_piece, Vector2(column, row), direction)
			state = wait
			move_child(other_piece, 0)
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
			first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
			other_piece.move(grid_to_pixel(column, row))
			if !move_checked:
				find_matches()
				
func is_in_locks(place):
	for i in lock_pieces.size():
		if lock_pieces[i] == place:
			return true
	return false
				
func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction
	pass

func swap_back():
	# Move the previously swapped pieces back to the previous place.
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction) 
	state = move
	move_checked = false
	pass
	
func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if all_pieces[i - 1][j] != null && all_pieces[i + 1][j] != null:
						if all_pieces[i - 1][j].color == current_color && all_pieces[i + 1][j].color == current_color:
							all_pieces[i - 1][j].matched = true
							all_pieces[i - 1][j].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i + 1][j].matched = true
							all_pieces[i + 1][j].dim()
				if j > 0 && j < height - 1:
					if all_pieces[i][j-1] != null && all_pieces[i][j + 1] != null:
						if all_pieces[i][j - 1].color == current_color && all_pieces[i][j + 1].color == current_color:
							all_pieces[i][j - 1].matched = true
							all_pieces[i][j - 1].dim()
							all_pieces[i][j].matched = true
							all_pieces[i][j].dim()
							all_pieces[i][j + 1].matched = true
							all_pieces[i][j + 1].dim()
	get_parent().get_node("destroy_timer").start()

func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
#					emit_signal("damage_ice", Vector2(i,j))
#					emit_signal("damage_locks", Vector2(i,j))
#					destroy_concrete(i, j)
#					destroy_slime(i, j)
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	move_checked = true
#	if !slime_damaged:
#		generate_slime()
	if was_matched:
		get_parent().get_node("collapse_timer").start()
	else:
		swap_back()

func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_movement(Vector2(i,j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("refill_timer").start()
	
func push(vec1, vec2):
	if all_pieces[vec2.x][vec2.y] == null:
		if Til.id_to_name[Til.get_cellv(vec1)][0] == "0":
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(vec1.x, vec1.y)
			piece.move(grid_to_pixel(vec2.x, vec2.y))
			all_pieces[vec2.x][vec2.y] = piece
		else:
			if all_pieces[vec1.x][vec1.y] != null:
				all_pieces[vec1.x][vec1.y].move(grid_to_pixel(vec2.x, vec2.y))
				all_pieces[vec2.x][vec2.y] = all_pieces[vec1.x][vec1.y]
				all_pieces[vec1.x][vec1.y] = null
				
	
func collapse_columns1():
	var has_null = true
	var count = 0
	while has_null and count <= max_loop:
		count += 1
		has_null = false
		for cood in Til.get_used_cells():
			if Til.id_to_name[Til.get_cellv(cood)][0] == "0":
				continue
			if all_pieces[cood.x][cood.y] == null and !restricted_movement(Vector2(cood.x, cood.y)):
				has_null = true
				match Til.id_to_name[Til.get_cellv(cood)][0]:
					"1":
						match Til.id_to_name[Til.get_cellv(cood)]:
							"101", "111", "115":
								push(cood + Vector2(0, 1), cood)
							"102", "112", "118":
								push(cood - Vector2(1, 0), cood)
							"103", "113", "117":
								push(cood - Vector2(0, 1), cood)
							"104", "114", "116":
								push(cood + Vector2(1, 0), cood)
	after_refill()

func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_movement(Vector2(i,j)):
				#choose a random number and store it
				var rand = floor(rand_range(0, possible_pieces.size()));
				var piece = possible_pieces[rand].instance();
				var loops = 0;
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()));
					loops += 1;
					piece = possible_pieces[rand].instance();
				# Instance that piece from the array
				add_child(piece);
				piece.position = grid_to_pixel(i, j + y_offset);
				piece.move(grid_to_pixel(i,j))
				all_pieces[i][j] = piece;
	after_refill()

func after_refill():
#	slime_damaged = true
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					find_matches()
					get_parent().get_node("destroy_timer").start()
					return
	state = move
	move_checked = false
#	slime_damaged = false
	
func find_normal_neighbor(place):
	for i in range(-1, 2):
		for j in range(-1, 2):
			if i!= 0 && j != 0:
				if is_in_grid(Vector2(place.x + i, place.y + j)):
					if all_pieces[place.x + i][place.y + j] != null:
						return Vector2(place.x + i, place.y + j)
	return Vector2(0, 0)

func _on_destroy_timer_timeout():
	destroy_matched()

func _on_collapse_timer_timeout():
	collapse_columns1()

func _on_refill_timer_timeout():
	refill_columns()
