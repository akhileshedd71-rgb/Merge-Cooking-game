extends SceneTree
## Real scene/input smoke tests. Run with tools/godot.sh --headless --path . --script tests/test_ui.gd
## Autosave is detached so the test never writes the player's progress.

const MainScene: PackedScene = preload("res://main.tscn")
var game: Control
var checks: int = 0
var failures: int = 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 1080)
	game = MainScene.instantiate()
	root.add_child(game)
	game.state.changed.disconnect(game._state_changed)
	game.state.changed.connect(func(): game.pending_refresh = true)
	game.state.new_game(53)
	game.state.skip_tutorial()
	game._close_modal()
	await _settle()
	_expect(_tiles().size() == 63, "Scene creates all 63 board controls")
	var energy_before: int = game.state.energy
	await _click(_tile(0))
	_expect(game.state.energy == energy_before - 1, "One generator click spends exactly one energy")
	await _click(_tile(3))
	_expect(game.selected == 3, "Ingredient click selects its board slot")
	await _click(_tile(4))
	_expect(game.state.board[3] == "" and game.state.board[4] == "strawberry", "Two taps merge matching ingredients through scene input")
	_expect(game.state.total_merges == 1, "A tap merge is applied once")
	await _drag(_tile(5), _tile(6))
	_expect(game.state.board[5] == "" and game.state.board[6] == "carrot", "Native pointer drag merges matching ingredients")
	_expect(game.state.total_merges == 2, "Drag release does not trigger a duplicate tap merge")
	_expect(game.selected == 6, "Drag keeps the destination selected after release")
	await _drag(_tile(11), _button_named("Cook"))
	_expect(game.modal == "ingredient" and game.modal_arg == "banana", "Dragging an ingredient onto Cook opens its recipes after the drag ends")
	await _click(_button_prefix("Cook with Banana"))
	_expect(game.current_tab == "Cook" and game.modal.is_empty(), "Starting a recipe opens the cooking stations")
	_expect(game.state.jobs.size() == 1 and game.state.jobs[0].output == "smoothie", "Recipe UI starts the selected dish")
	game.state.jobs[0].ready_at = Time.get_unix_time_from_system() - 1.0
	game.pending_refresh = true
	await _settle()
	await _click(_button_prefix("Collect dish"))
	_expect(game.state.jobs.is_empty() and game.state.board.has("smoothie"), "Station collection puts the cooked dish on the board")
	game._switch_tab("Kitchen")
	await _settle()
	var served_before: int = game.state.total_orders
	var smoothie_order: int = -1
	for i: int in game.state.orders.size():
		if game.state.orders[i].item == "smoothie": smoothie_order = i
	_expect(smoothie_order >= 0, "A waiting guest requests the cooked dish")
	game._order_clicked(smoothie_order)
	await _settle()
	_expect(game.state.total_orders == served_before + 1 and not game.state.board.has("smoothie"), "Serving through the scene consumes the dish and rewards the order")
	game._open_modal("storage")
	await _settle()
	energy_before = game.state.energy
	# The dimmed board must be blocked while a modal is open.
	await _click_at(game.canvas.get_global_transform() * Vector2(70, 372))
	_expect(game.state.energy == energy_before, "Modal prevents clicks from reaching the generator underneath")
	game._close_modal()
	game._switch_tab("Travel")
	await _settle()
	var locked_count: int = 0
	for button: Button in _buttons(game):
		if button.text == "Locked" and button.disabled: locked_count += 1
	_expect(locked_count == 7, "Future destinations are visibly disabled")
	game.queue_free()
	await process_frame
	print("Kitchen scene: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)


func _settle() -> void:
	await process_frame
	await process_frame
	await process_frame


func _expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAILED: " + message)


func _tiles() -> Array[BoardTile]:
	var result: Array[BoardTile] = []
	for child: Node in game.content.get_children():
		if child is BoardTile: result.append(child as BoardTile)
	return result


func _tile(index: int) -> BoardTile:
	for tile: BoardTile in _tiles():
		if tile.index == index: return tile
	return null


func _buttons(parent: Node) -> Array[Button]:
	var result: Array[Button] = []
	for child: Node in parent.get_children():
		if child is Button: result.append(child as Button)
		result.append_array(_buttons(child))
	return result


func _button_named(text: String) -> Button:
	for button: Button in _buttons(game):
		if button.text == text: return button
	return null


func _button_prefix(prefix: String) -> Button:
	for button: Button in _buttons(game):
		if button.text.begins_with(prefix): return button
	return null


func _click(control: Control) -> void:
	if control == null:
		_expect(false, "Requested scene control exists")
		return
	await _click_at(control.get_global_rect().get_center())


func _click_at(at: Vector2) -> void:
	_mouse_button(at, true)
	await process_frame
	_mouse_button(at, false)
	await _settle()


func _mouse_button(at: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = at
	event.global_position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	root.push_input(event, true)


func _drag(from: Control, to: Control) -> void:
	var start: Vector2 = from.get_global_rect().get_center()
	var finish: Vector2 = to.get_global_rect().get_center()
	_mouse_button(start, true)
	await process_frame
	for step: int in range(1, 5):
		var motion: InputEventMouseMotion = InputEventMouseMotion.new()
		motion.position = start.lerp(finish, float(step) / 4.0)
		motion.global_position = motion.position
		motion.relative = (finish - start) / 4.0
		motion.button_mask = MOUSE_BUTTON_MASK_LEFT
		root.push_input(motion, true)
		await process_frame
		if step == 2:
			game.pending_refresh = true
			await process_frame
			_expect(is_instance_valid(from) and from.is_inside_tree(), "Pending scene refresh preserves controls while a drag is active")
	_expect(root.gui_is_dragging(), "Moving a pressed ingredient starts native Godot drag")
	_mouse_button(finish, false)
	await _settle()
