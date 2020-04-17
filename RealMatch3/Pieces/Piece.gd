extends Node2D

signal back
signal moving

export (String) var color
var matched = false
#var h_matched = 0
#var v_matched = 0
var is_moving = false
var is_locked = false
var swapped = false
var swap_targets = []
var superpower = false
var lightning = false
var fire = false
var triger = false
onready var anim_time = get_parent().anim_time


func _ready():
	connect("back", get_parent(), "_on_piece_back")
	connect("moving", get_parent(), "_on_piece_moving")
	$DestroyTimer.wait_time = anim_time
	$Fire.emitting = false

func move(target):
	$MoveTween.interpolate_property(self, "position", position, target, anim_time, 
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$MoveTween.start()
	emit_signal("moving")
	is_moving = true

func dim():
#	print("dimed")
	swap_targets = []
	$DestroyTimer.start()
	triger = true
	var sprite = get_node("Sprite")
	sprite.modulate = Color(1, 1, 1, .5)

func fast_remove():
	queue_free()

func _on_MoveTween_tween_all_completed():
	is_moving = false
	if swap_targets != []:
		emit_signal("back", swap_targets)

func _on_DestroyTimer_timeout():
	if fire:
		$Fire.emitting = true
		matched = false
		$Sprite.modulate = Color(1, 1, 1, 1)
	else:
		queue_free()
