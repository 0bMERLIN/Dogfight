extends Node2D

var nm
var ap
signal on_buy(data_item)

func update_ui():
	$Current.text = str(ap.config[nm]["current"])
	$Name.text = nm
	$Cost.text = str(ap.config[nm]["increment_price"])


func _ready():
	update_ui()
	
func _process(delta):
	pass

func _on_buy_pressed():
	on_buy.emit(self)
