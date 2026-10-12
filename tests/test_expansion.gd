extends SceneTree
const State = preload("res://scripts/game_state.gd")
var checks: int = 0
var failures: int = 0
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1; push_error(message)
func _init() -> void:
	_catalog_and_unlocks()
	_tutorial()
	_economy()
	_migration()
	print("Kitchen expansion: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
func _catalog_and_unlocks() -> void:
	var game = State.new()
	for id in State.ITEMS:
		expect(ResourceLoader.exists("res://assets/items/%s.svg" % id), "Food artwork exists: " + id)
	for city in State.CITIES:
		expect(ResourceLoader.exists("res://assets/cities/%s.svg" % city.art), "Destination artwork exists: " + city.name)
	for chain in State.CHAINS:
		game.xp = (int(chain.level)-1)*100
		expect(game.generate_from(chain.generator), "Supplier opens at the advertised level")
		if int(chain.level) > 1:
			game.xp -= 1
			var before: Array = game.board.duplicate()
			var energy_before: int = game.energy
			expect(not game.generate_from(chain.generator) and game.board == before and game.energy == energy_before, "Locked supplier cannot consume energy or spawn")
		for i in range(chain.items.size()-1):
			game.board[3] = chain.items[i]
			game.board[4] = chain.items[i]
			expect(game.move_or_merge(3,4) and game.board[4] == chain.items[i+1], "Every ingredient is reachable by merging")
	game.new_game(19)
	game.board[3] = "strawberry"
	game.xp = 99
	var before: Array = game.board.duplicate()
	expect(not game.start_cooking(3,"berry_tart") and game.board == before and game.jobs.is_empty(), "Recipe level gate is enforced atomically")
	game.xp = 100
	for i in range(3,63):
		if game.board[i] == "flour": game.board[i] = ""
	before = game.board.duplicate()
	expect(not game.start_cooking(3,"berry_tart") and game.board == before, "Missing second ingredient never consumes the first")
	game.board[4] = "flour"
	expect(game.start_cooking(3,"berry_tart") and game.board[3] == "" and game.board[4] == "", "Two-ingredient recipe consumes exactly both inputs")
	game.new_game(33)
	for level in range(1,21):
		game.xp = (level-1)*100
		for i in 50:
			var id: String = game._next_order_item()
			var recipe: Dictionary = game.get_recipe(id)
			expect(recipe.is_empty() or int(recipe.level) <= level, "Generated orders never demand a locked recipe")
func _tutorial() -> void:
	var game = State.new()
	expect(game.tutorial_step == 0, "Fresh players see the welcome guide")
	game.start_tutorial()
	expect(game.tutorial_step == 1, "Guide starts with generation")
	game.generate(0)
	expect(game.tutorial_step == 2, "Real generation advances tutorial")
	game.move_or_merge(7,8)
	expect(game.tutorial_step == 3, "Real merge advances tutorial")
	game.start_cooking(8,"smoothie")
	expect(game.tutorial_step == 4, "Real recipe starts the cooking lesson")
	expect(not game.collect_cooking(0) and game.tutorial_step == 4, "Premature collection cannot skip the lesson")
	var path: String = "user://expansion_tutorial_test.json"
	game.save_game(path)
	var resumed = State.new()
	expect(resumed.load_game(path) and resumed.tutorial_step == 4 and resumed.jobs.size() == 1, "Tutorial and running dish resume together")
	game.jobs[0].ready_at = 0.0
	game.collect_cooking(0)
	expect(game.tutorial_step == 5, "Collected food advances tutorial")
	game.serve_order(1)
	expect(game.tutorial_step == 6, "Serving advances tutorial")
	var before: int = game.coins
	game.renovate("floor","sage")
	expect(game.tutorial_step == 7 and game.tutorial_rewarded and game.coins == before+50, "First completed tutorial grants one welcome reward")
	game.tutorial_step = 6
	before = game.coins
	game.renovate("floor","rose")
	expect(game.tutorial_step == 7 and game.coins == before, "Replay cannot farm welcome rewards")
	var skipped = State.new()
	skipped.skip_tutorial()
	expect(skipped.tutorial_step == 7 and not skipped.tutorial_rewarded and skipped.coins == 240, "Skip preserves gameplay and does not grant completion reward")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
func _economy() -> void:
	var game = State.new()
	game.xp = 299
	expect(game.get_level() == 3 and game.pending_level_rewards() == 2, "Level thresholds and pending rewards agree")
	var before: int = game.coins
	expect(game.claim_level_rewards() and game.coins == before+125, "Claim all rewards grants correct level-two and level-three payouts")
	before = game.coins
	expect(not game.claim_level_rewards() and game.coins == before, "Level rewards cannot be claimed twice")
	game.xp = 5000
	expect(game.get_level() == 20, "Chef levels cap cleanly at twenty")
	game.coins = 5000
	game.energy = 100
	before = game.coins
	expect(not game.buy_supply("energy") and game.coins == before, "Full energy cannot waste coins")
	game.energy = 60
	expect(game.buy_supply("energy") and game.energy == 90 and game.coins == before-120, "Coin energy purchase is exact")
	for i in 10: expect(game.buy_supply("storage"), "Pantry expansion is purchasable")
	before = game.coins
	expect(game.inventory_capacity == 20 and not game.buy_supply("storage") and game.coins == before, "Pantry expansion caps at twenty without spending")
	game.coins = 0
	var boosts_before: int = game.boosts
	expect(not game.buy_supply("boost") and game.boosts == boosts_before, "Insufficient coins cannot buy boosts")
	expect(not game.sell_item(0), "Generators cannot be sold")
	game.board[3] = "coconut"
	expect(game.sell_item(3) and game.coins == 12 and game.board[3] == "", "Selling creates room and exact coin value")
	expect(not game.claim_goal("first_merges"), "Unfinished goal cannot be claimed")
	game.total_merges = 5
	before = game.coins
	expect(game.claim_goal("first_merges") and game.coins == before+60, "Completed goal pays its reward")
	expect(not game.claim_goal("first_merges"), "Goal cannot be farmed")
func _migration() -> void:
	var old: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://tests/fixtures/v1_save.json"))
	for order in old.orders:
		for key in ["id","coins","stars","xp"]: order[key] = int(order[key])
	var game = State.new()
	expect(game.load_game("res://tests/fixtures/v1_save.json"), "Actual v1 save from the previous Git commit migrates")
	expect(game.board == Array(old.board) and game.inventory == Array(old.inventory), "Migration preserves exact board and storage")
	expect(game.coins == int(old.coins) and game.stars == int(old.stars) and game.xp == int(old.xp), "Migration preserves earned currencies and XP")
	expect(game.jobs == Array(old.jobs) and game.orders == Array(old.orders), "Migration preserves active jobs and orders")
	expect(game.get_renovation("floor") == "rose" and game.renovations.size() == 8, "Old designs remain and new cities are added")
	expect(game.tutorial_step == 7, "Returning players are not forced through a new tutorial")
	game.claim_level_rewards()
	game.coins = 500
	game.buy_supply("storage")
	game.start_tutorial()
	game.generate(0)
	var path: String = "user://expansion_migration_test.json"
	expect(game.save_game(path), "Migrated save writes new schema")
	var restored = State.new()
	expect(restored.load_game(path) and restored.inventory_capacity == 11 and restored.tutorial_step == 2, "Expanded state survives restart")
	expect(restored.pending_level_rewards() == 0, "Claimed rewards survive restart")
	var valid: String = FileAccess.get_file_as_string(path)
	for changes in [{"inventory_capacity":99},{"tutorial_step":9},{"claimed_levels":[1,1]},{"claimed_goals":["fake"]},{"total_cooked":-1},{"tutorial_rewarded":"yes"}]:
		var data: Dictionary = JSON.parse_string(valid)
		data.merge(changes,true)
		var file := FileAccess.open(path,FileAccess.WRITE)
		file.store_string(JSON.stringify(data)); file.close()
		var before: Array = restored.board.duplicate()
		expect(not restored.load_game(path) and restored.board == before, "Corrupt expansion fields are rejected without losing progress")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
