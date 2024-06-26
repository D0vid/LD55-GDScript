class_name Drawing extends Node2D

var previous_paths = []

var current_path: PackedVector2Array = []
var current_rate_limited_path: PackedVector2Array  = []
var current_glyph = null

var drawing = false
var debug = false
var enabled = false

@export var sampling_rate_sec = 0.10


var time_since_last_draw_sec = sampling_rate_sec


@onready var glyph_shape = $GlyphShape as GlyphShape

# signals
signal drawing_ended(glyph)


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_glyph()
	
func show_glyph():
	glyph_shape.base = current_glyph.glyph_shape_base
	glyph_shape.visible = true
	
func hide_glyph():
	glyph_shape.visible = false

func _draw():

	#for path: PackedVector2Array in self.previous_paths:
		#draw_polyline(path, Color.DARK_RED, 15)


	if current_path.size() > 1:
		draw_polyline(self.current_path, Color.RED, 15)
		if debug:
			draw_polyline(self.current_rate_limited_path, Color.BROWN, 10)

func _input(event):
	if !self.enabled:
		return

	if event is InputEventMouseButton:
		if event.is_released():
			self.drawing = false
			current_path.push_back(event.position)
			current_rate_limited_path.push_back(event.position)
			drawing_ended.emit(self.current_glyph)
		elif event.is_pressed():
			self.drawing = true

	elif event is InputEventMouseMotion:
		if self.drawing:
			if time_since_last_draw_sec >= sampling_rate_sec:
				current_rate_limited_path.push_back(event.position)
				self.time_since_last_draw_sec = 0
			current_path.push_back(event.position)
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	time_since_last_draw_sec += delta

func next_drawing():
	if current_path.size() > 1:
		self.previous_paths.push_back(current_path)

	self.current_path = []
	self.current_rate_limited_path = []
	self.time_since_last_draw_sec = sampling_rate_sec
	self.drawing = false
	self.current_glyph = null
