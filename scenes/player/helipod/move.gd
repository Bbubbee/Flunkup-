extends State 

var distance: float 
var direction: Vector2 
var target: Vector2

var tile_was_clicked: bool = false
var original_tile: Vector2i 

func _ready():
	Events.position_helipod.connect(_on_position_helipod)

func enter(_enter_params = null):
	# Either position the helipod above a tile or at the mouse position. 
	if _enter_params: 
		target = _enter_params['target']
		original_tile = _enter_params['original_tile_pos']
		tile_was_clicked = true 
	else: 
		target = actor.get_global_mouse_position()
		tile_was_clicked = false 
	
	direction = Globals.get_direction_to_target(actor.center_marker.global_position, target)
	distance = Globals.get_distance_between_two_targets(actor.center_marker.global_position, target)


func physics_process(delta: float) -> void:
	# Move towards the mouse's last right clicked position. 
	direction = Globals.get_direction_to_target(actor.center_marker.global_position, target)	
	distance = Globals.get_distance_between_two_targets(actor.center_marker.global_position, target) 
	
	# TODO: Change how far helipod stops from the target. 
	# Stop when near target. 
	if distance < 5: 
		if tile_was_clicked:
			# Tell the world to process the tile (till or plant) 
			transition.emit(self, 'action', original_tile)
			#Events.process_tile.emit(original_tile)
		else:
			transition.emit(self, 'idle')
	
	actor.velocity_component.move_freely(delta, direction)
	actor.move_and_slide()
	

func on_input(event: InputEvent): 
	# Target the new mouse position. 
	if event.is_action_pressed('right_click'):
		target = actor.get_global_mouse_position()
		direction = Globals.get_direction_to_target(actor.center_marker.global_position, actor.get_global_mouse_position())


# A tile has been pressed. Go to that tile. 
func _on_position_helipod(tile_pos: Vector2, original_tile_pos: Vector2i):
	target = tile_pos
	original_tile = original_tile_pos
	tile_was_clicked = true 
	

