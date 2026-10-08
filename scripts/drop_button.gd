extends Button
## Also accepts native Godot drag data from the merge board.
signal ingredient_dropped(index: int)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("board_index")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	ingredient_dropped.emit(int(data["board_index"]))
