extends Control

var msg : String
var color : Color
var duration_ms : int
var timer : Timer

func _ready():
	timer = $Timer
	$Label.text = msg
	$ColorRect.color = color
	timer.start(duration_ms / 1000)
	timer.one_shot = true

func _process(delta):
	if timer.time_left <= 0: queue_free()
	
	var fade_start = .7
	if timer.time_left < fade_start:
		var a = (timer.time_left + fade_start) / (duration_ms / 1000)
		$ColorRect.color.a = a
		$ColorRect2.color.a = a
		($Label as Label).label_settings.font_color.a = a
