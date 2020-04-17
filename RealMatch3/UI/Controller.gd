extends Node2D

export (NodePath) var Generator
onready var Gen = get_node(Generator)

# Touch Variables
var first_touch = Vector2(0, 0)
var final_touch = Vector2(0, 0)
var controlling = false

func _process(delta):
	#print(Gen)
	touch_input()

func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if Gen.is_in_grid(Gen.pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			first_touch = Gen.pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			controlling = true
	if Input.is_action_just_released("ui_touch"):
		if Gen.is_in_grid(Gen.pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling:
			controlling = false
			final_touch = Gen.pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)
			
func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1;
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			Gen.swap_pieces(grid_1.x, grid_1.y, Vector2(1, 0));
		elif difference.x < 0:
			Gen.swap_pieces(grid_1.x, grid_1.y, Vector2(-1, 0));
	elif abs(difference.y) > abs(difference.x):
		if difference.y > 0:
			Gen.swap_pieces(grid_1.x, grid_1.y, Vector2(0, 1));
		elif difference.y < 0:
			Gen.swap_pieces(grid_1.x, grid_1.y, Vector2(0, -1));
