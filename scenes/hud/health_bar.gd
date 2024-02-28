extends Control

@export var player : Node

@onready var timer = $Timer
@onready var damage_bar = $Hp/DamageBar

@export var max_value = 100
@export var value = 100

var health = 0 : set = _set_health

func _set_health(new_health):
	var prev_health = health
	health = min(max_value, new_health)
	$Hp.value = health
	
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health 

func init_health(_health):
	health = _health
	max_value = health
	value = health
	damage_bar.max_value = health
	damage_bar.value = health

func _on_timer_timeout():
	damage_bar.value = health
	
func _physics_process(delta):
	health = player.hitpoints
