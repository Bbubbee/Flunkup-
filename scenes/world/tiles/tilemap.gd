extends TileMap

# Tile map info. 
var ground_layer: int = 0
var plant_layer: int = 1 
var source_id: int = 0

var dirt_atlas_coord : Vector2i = Vector2i(13, 7) # Vector2i(13, 7)
var plant_atlas_coord : Vector2i = Vector2i(21, 2) # Vector2i(13, 7)

var tileset_layer: int = 0

func _ready():
	Events.process_tile.connect(_on_process_tile)
	Events.plant_on_tile.connect(_on_plant_on_tile)

const base_crop = preload("res://test/res_crop.tscn")
@onready var crops = $Crops

## Plant a crop on top of this tile. 
func _on_plant_on_tile(pos: Vector2):
	# Get tile positions. 
	var tile_pos = local_to_map(pos)
	var tile_above_pos = Vector2i(tile_pos.x, tile_pos.y-1)
	var new_pos = map_to_local(tile_above_pos)
	
	# See if can plant on tile. 
	if retrieve_custom_data(tile_pos, "can_plant", ground_layer):
		# Spawn crop!!!
		var crop = base_crop.instantiate()
		crop.position = new_pos
		crops.add_child(crop)
			

## Till this tile. 
func _on_process_tile(tile_pos: Vector2i): 
	if retrieve_custom_data(tile_pos, "can_till", 0): 
		set_cell(ground_layer, tile_pos, 0, dirt_atlas_coord)
	elif retrieve_custom_data(tile_pos, "can_water", 0): 	
		set_cell(ground_layer, tile_pos, 0, dirt_atlas_coord, 2)

## @param: layer = the layer of the tilemap. Defaults to 0, the ground layer. 
func get_valid_tile(pos: Vector2, custom_data_layer: String = "", layer: int = 0): 
	var tile_pos: Vector2i = local_to_map(pos)
	
	# Hacky way to seeing if there exists a tile in this pos.
	# May have to revamp later. 
	var tile_source = get_cell_source_id(layer, tile_pos) 
	if tile_source < 0: 
		return false
	
	# If you want to check if a custom data layer is true or exists, you can. 
	# Else, it will just return the tile pos. 
	if custom_data_layer: 
		if retrieve_custom_data(tile_pos, custom_data_layer, layer): return tile_pos
		else: return false 
	else: return tile_pos

## Checks if the selected tile contains the specified custom data.
## Returns true or false. 
## @param: tile_mouse_pos    = the position of the selected tile. 
## @param: custom_data_layer = checks if this tile has this custom data.
## @param: layer             = the layer the tile is on. I.e. ground, plants.
func retrieve_custom_data(tile_pos: Vector2i, custom_data_layer: String, layer: int):
	var tile_data: TileData = get_cell_tile_data(layer, tile_pos)
	if tile_data: return tile_data.get_custom_data(custom_data_layer)
	else: return false

func check_if_cell_is_occupied(): 
	pass



