extends SceneTree
## Run: godot --headless --path . --script tests/test_game.gd

const State = preload("res://scripts/game_state.gd")
var checks: int = 0
var failures: int = 0

func _init() -> void:
	_test_start_and_merge()
	_test_generation_and_storage()
	_test_recipes_and_orders()
	_test_complete_loop()
	_test_travel_and_renovation()
	_test_save_and_offline()
	print("Kitchen rules: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAILED: " + message)

func _test_start_and_merge() -> void:
	var game = State.new()
	game.new_game(17)
	expect(game.board.size() == 63, "Board has 7 columns and 9 rows")
	expect(game.orders.size() == 7, "Seven simultaneous guests")
	expect(game.board.count("locked") == 14, "Two dusty rows to uncover")
	var initial_board: Array = game.board.duplicate()
	expect(not game.move_or_merge(-1, 5), "Negative source rejected")
	expect(not game.move_or_merge(3, 63), "Out-of-bounds target rejected")
	expect(not game.move_or_merge(0, 8), "Generator cannot move")
	expect(not game.move_or_merge(3, 0), "Generator cannot be replaced")
	expect(not game.move_or_merge(3, 49), "Dusty tiles cannot be overwritten")
	expect(not game.move_or_merge(3, 3), "Self-merge rejected")
	expect(game.board == initial_board, "Invalid moves leave board intact")
	expect(game.move_or_merge(3, 4), "Matching cherries merge")
	expect(game.board[3] == "" and game.board[4] == "strawberry", "Merge consumes two ingredients and produces next tier")
	expect(game.total_merges == 1 and game.xp == 2, "Merge earns XP and updates progress")
	expect(game.move_or_merge(4, 5), "Different ingredients swap")
	expect(game.board[4] == "tomato" and game.board[5] == "strawberry", "Swap preserves both ingredients")
	expect(game.move_or_merge(42, 43), "Merge beside dusty row")
	expect(game.board[50] == "" and game.board[49] == "locked", "Only orthogonal neighbor clears")
	game.board[6] = "cherry"
	game.board[13] = "cherry"
	game.board[7] = "locked"
	game.move_or_merge(13, 6)
	expect(game.board[7] == "locked", "Neighbor clearing does not wrap across rows")
	game.board[28] = "pineapple"
	game.board[30] = "pineapple"
	game.move_or_merge(28, 30)
	expect(game.board[28] == "pineapple" and game.board[30] == "pineapple", "Maximum-tier ingredients never disappear")

func _test_generation_and_storage() -> void:
	var game = State.new()
	game.new_game(29)
	var old_energy: int = game.energy
	var old_count: int = game.board.count("")
	expect(game.generate(0), "Fruit generator spawns")
	expect(game.energy == old_energy - 1 and game.board.count("") == old_count - 1, "Spawn costs one energy and uses one empty tile")
	expect(not game.generate(3), "Ingredient is not a generator")
	game.energy = 0
	game.energy_updated_at = Time.get_unix_time_from_system()
	expect(not game.generate(1), "No spawning without energy")
	expect(game.store_item(3), "Ingredient goes into storage")
	expect(game.board[3] == "" and game.inventory == ["cherry"], "Storage transfers exactly one item")
	expect(game.restore_item(0), "Stored ingredient returns")
	expect(game.board[3] == "cherry" and game.inventory.is_empty(), "Restore removes stored copy")
	expect(not game.store_item(0) and not game.store_item(49), "Generators and dust cannot be stored")
	for index: int in range(3, 13):
		expect(game.store_item(index), "Fill storage slot %d" % index)
	expect(not game.store_item(13), "Storage stops at ten slots")
	for index: int in range(3, game.board.size()):
		if game.board[index] != "locked":
			game.board[index] = "cherry"
	game.energy = 50
	expect(not game.generate(0) and game.energy == 50, "Full board never spends energy")
	expect(not game.restore_item(0) and game.inventory.size() == 10, "Full board never consumes stored items")
	expect(not game.restore_item(-1) and not game.restore_item(10), "Invalid inventory slot rejected")

func _test_recipes_and_orders() -> void:
	var stations: Dictionary = {}
	for recipe: Dictionary in State.RECIPES:
		var game = State.new()
		game.board[3] = recipe["input"]
		expect(game.start_cooking(3, recipe["id"]), "Start recipe " + recipe["id"])
		expect(game.board[3] == "" and game.jobs.size() == 1, "Cooking consumes ingredient exactly once")
		expect(not game.collect_cooking(0), "Unfinished dish cannot be collected")
		game.board[4] = recipe["input"]
		expect(not game.start_cooking(4, recipe["id"]) and game.board[4] == recipe["input"], "Busy station preserves second ingredient")
		var ready_before: float = game.jobs[0]["ready_at"]
		expect(game.boost_cooking(0), "Boost accelerates cooking")
		expect(game.boosts == 2 and is_equal_approx(ready_before - float(game.jobs[0]["ready_at"]), 5.0), "One boost saves five seconds")
		game.jobs[0]["ready_at"] = Time.get_unix_time_from_system() - 1.0
		expect(game.collect_cooking(0), "Collect finished " + recipe["id"])
		expect(game.board[3] == recipe["out"] and game.jobs.is_empty(), "Finished dish appears and job clears")
		expect(game.discovered.has(recipe["out"]), "Recipe added to discoveries")
		stations[recipe["station"]] = true
	expect(stations.size() == 7, "All seven stations have a playable recipe")
	var game = State.new()
	var before: Array = game.board.duplicate()
	expect(not game.start_cooking(3, "unknown"), "Unknown recipe rejected")
	expect(not game.start_cooking(3, "benedict"), "Wrong recipe ingredient rejected")
	expect(game.board == before, "Failed cooking preserves board")
	game.board[3] = "bread"
	game.start_cooking(3, "toast")
	game.boosts = 0
	expect(not game.boost_cooking(0), "No free boosts")
	game.jobs[0]["ready_at"] = Time.get_unix_time_from_system() - 1.0
	for index: int in range(3, game.board.size()):
		if game.board[index] != "locked":
			game.board[index] = "cherry"
	expect(not game.collect_cooking(0) and game.jobs.size() == 1, "Full board retains cooked food safely")
	game.board[3] = ""
	expect(game.collect_cooking(0), "Dish can be collected after making room")
	var order: Dictionary = game.orders[0].duplicate()
	var coin_before: int = game.coins
	var star_before: int = game.stars
	expect(game.is_order_ready(0), "Matching board ingredient marks order ready")
	var cherry_count: int = game.board.count("cherry")
	expect(game.serve_order(0), "Guest served")
	expect(game.board.count("cherry") == cherry_count - 1, "Serving consumes one requested item")
	expect(game.coins == coin_before + order["coins"] and game.stars == star_before + order["stars"], "Serving grants advertised rewards")
	expect(game.orders.size() == 7 and game.orders[0]["id"] != order["id"], "New guest replaces served order")
	expect(not game.serve_order(1), "Unavailable smoothie order rejected")
	expect(not game.serve_order(-1) and not game.serve_order(99), "Invalid guest indices rejected")

func _test_complete_loop() -> void:
	# Follow an actual new player's merge -> cook -> serve -> renovate loop.
	# Only the wall clock is advanced so this test never waits on a timer.
	var game = State.new()
	expect(game.move_or_merge(7, 8), "Loop: two starting strawberries become a banana")
	expect(game.start_cooking(8, "smoothie"), "Loop: merged banana goes into blender")
	game.jobs[0]["ready_at"] = Time.get_unix_time_from_system() - 1.0
	expect(game.collect_cooking(0), "Loop: smoothie lands on the board")
	expect(game.is_order_ready(1), "Loop: smoothie guest becomes ready")
	expect(game.serve_order(1), "Loop: serve the smoothie")
	expect(game.stars == 3, "Loop: earned star joins two starting stars")
	expect(game.renovate("tables", "sage"), "Loop: earned stars furnish the restaurant")
	expect(game.get_renovation("tables") == "sage" and game.stars == 0, "Loop: renovation persists and spends stars")

func _test_travel_and_renovation() -> void:
	var game = State.new()
	expect(not game.travel(1), "Bangkok starts locked")
	expect(not game.renovate("ceiling", "sage"), "Unknown renovation rejected")
	expect(not game.renovate("floor", "invisible"), "Unknown style rejected")
	expect(game.renovate("floor", "sage"), "Starting stars can renovate floor")
	expect(game.stars == 0 and game.get_renovation("floor") == "sage", "Renovation spends correct stars and saves style")
	expect(not game.renovate("tables", "rose"), "Insufficient stars cannot renovate")
	expect(game.renovate("floor", "sunshine") and game.stars == 0, "Owned detail can be recolored freely")
	game.stars = 100
	for city: int in range(4):
		if city > 0:
			expect(game.travel(city), "Travel to unlocked city %d" % city)
		for part: String in State.PARTS:
			if game.get_renovation(part).is_empty():
				expect(game.renovate(part, "rose"), "Renovate %s in city %d" % [part, city])
		expect(game.get_unlocked_city() == mini(city + 1, 3), "Completing room unlocks exactly the next chapter")
	expect(not game.travel(4), "Travel cannot exceed four cities")
	expect(game.travel(0) and game.get_renovation("floor") == "sunshine", "Returning to city preserves its design")
	game.energy = 70
	expect(game.claim_daily(), "First daily gift is available")
	expect(game.energy == 95, "Gift grants 25 energy")
	var coins_after: int = game.coins
	expect(not game.claim_daily() and game.coins == coins_after, "Daily reward cannot be double-claimed")
	game.daily_claimed_at -= 86400
	expect(game.claim_daily() and game.energy == 100, "Next day reward becomes available, energy stays capped")

func _test_save_and_offline() -> void:
	var path: String = "user://test_kitchen_rules.json"
	var game = State.new()
	game.new_game(99)
	game.store_item(3)
	game.renovate("floor", "rose")
	game.start_cooking(12, "soup")
	game.energy = 20
	game.energy_updated_at = Time.get_unix_time_from_system() - State.ENERGY_INTERVAL * 3.0 - 4.0
	expect(game.save_game(path), "Game saves successfully")
	var restored = State.new()
	expect(restored.load_game(path), "Valid save restores")
	expect(restored.board == game.board and restored.inventory == game.inventory, "Board and pantry survive restart")
	expect(restored.orders == game.orders and restored.jobs == game.jobs, "Guests and running cooking jobs survive restart")
	expect(restored.energy == 23, "Offline time regenerates three energy")
	expect(restored.get_renovation("floor") == "rose", "Room style survives restart")
	expect(restored.energy_seconds_remaining() >= 39 and restored.energy_seconds_remaining() <= 42, "Offline partial recharge interval is retained")
	game.tick()
	game.generate(0)
	restored.generate(0)
	expect(restored.board == game.board, "Random generator continues from saved state")
	restored.energy_updated_at = Time.get_unix_time_from_system() - 100000.0
	restored.tick()
	expect(restored.energy == 100, "Long offline recharge caps at 100")
	restored.energy = 99
	restored.energy_updated_at = Time.get_unix_time_from_system() + 600.0
	restored.tick()
	expect(restored.energy == 99 and restored.energy_seconds_remaining() <= 45, "Clock rollback repairs recharge baseline")
	var good_save: String = FileAccess.get_file_as_string(path)
	var malformed: Array = ["not json", "[]", "{}", "null"]
	for content: String in malformed:
		_write(path, content)
		var previous: Array = restored.board.duplicate()
		expect(not restored.load_game(path) and restored.board == previous, "Malformed save rejected without destroying current game")
	var invalid: Dictionary = JSON.parse_string(good_save)
	invalid["board"][4] = "not_an_item"
	_write(path, JSON.stringify(invalid))
	expect(not restored.load_game(path), "Unknown saved item rejected")
	invalid = JSON.parse_string(good_save)
	invalid["coins"] = -1
	_write(path, JSON.stringify(invalid))
	expect(not restored.load_game(path), "Negative resources rejected")
	invalid = JSON.parse_string(good_save)
	invalid["version"] = 99
	_write(path, JSON.stringify(invalid))
	expect(not restored.load_game(path), "Unknown save version rejected")
	invalid = JSON.parse_string(good_save)
	invalid["jobs"][0]["station"] = "pan"
	_write(path, JSON.stringify(invalid))
	expect(not restored.load_game(path), "Mismatched cooking station rejected")
	invalid = JSON.parse_string(good_save)
	invalid["city_index"] = 3
	_write(path, JSON.stringify(invalid))
	expect(not restored.load_game(path), "Locked destination in corrupt save rejected")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	expect(not restored.load_game(path), "Missing save handled without errors")

func _write(path: String, content: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()
