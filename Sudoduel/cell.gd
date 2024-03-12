extends Button

signal cell_selected(button)


var jottings = []
var is_editable = false
var index = 0
var normal_font = load("res://Default_font.tres")
var blurred_font = load("res://blurred_font.tres")
# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_theme_font_override("font", normal_font)
	
	for i in range(self.get_child_count()):
		jottings.append(get_child(i))

	self.connect("pressed", Callable(self, "_on_cell_pressed"))


func _on_cell_pressed():
	cell_selected.emit(self)
	
func toggle_jotting_visibility(number: int):
	if number >= 1 and number <= 9:
		var jotting = jottings[number - 1]
		jotting.visible = not jotting.visible

func hide_all_jottings():
	for jotting in jottings:
		jotting.visible = false

func highlight_cell(highlight:bool):
	if highlight:
		modulate = Color(1,0.8,0.8)
	else:
		modulate = Color(1,1,1)
		
func toggle_blur():
	if self.get_theme_font("font") == normal_font:
		self.add_theme_font_override("font", blurred_font)
	else:
		self.add_theme_font_override("font", normal_font)
		
func set_index(index:int):
	self.index = index
	
