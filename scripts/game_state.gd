class_name KitchenState
extends RefCounted
## Deterministic, scene-independent rules for Little World Kitchen.

signal changed
signal feedback(message: String)
signal tutorial_finished

const COLS: int = 7
const ROWS: int = 9
const ENERGY_MAX: int = 100
const INVENTORY_MAX: int = 10
const ENERGY_INTERVAL: float = 45.0
const SAVE_VERSION: int = 2
const MAX_LEVEL: int = 20
const CHAINS = preload("res://scripts/catalog.gd").CHAINS
const GOALS = preload("res://scripts/catalog.gd").GOALS
const PARTS: Array[String] = ["floor", "tables", "decor"]
const RENOVATION_COSTS: Dictionary = {"floor": 2, "tables": 3, "decor": 4}
const STYLES: Array[String] = ["sage", "sunshine", "rose"]

const ITEMS: Dictionary = preload("res://scripts/catalog.gd").ITEMS

const STATIONS: Dictionary = {
	"pan": {"name": "Frying pan", "description": "A little sizzle, a lot of happiness."},
	"blender": {"name": "Blender", "description": "Whirl fresh fruit into something lovely."},
	"oven": {"name": "Oven", "description": "Good things come to those who bake."},
	"pot": {"name": "Soup pot", "description": "Comfort, simmered slowly."},
	"steamer": {"name": "Steamer", "description": "Keep it fresh, bright and green."},
	"grill": {"name": "Grill", "description": "Give your ingredients a warm welcome."},
	"shaker": {"name": "Shaker", "description": "Shake up a little sunshine."},
}
const RECIPES: Array[Dictionary] = preload("res://scripts/catalog.gd").RECIPES
const CITIES: Array[Dictionary] = preload("res://scripts/catalog.gd").CITIES
const CUSTOMERS: Array[String] = ["Oliver", "Maya", "Theo", "Sophie", "Miles", "Amara", "Leo", "Mali", "Haru", "Camille"]

var board: Array[String] = []
var inventory: Array[String] = []
var orders: Array[Dictionary] = []
var jobs: Array[Dictionary] = []
var energy: int = 80
var coins: int = 240
var stars: int = 2
var gems: int = 20
var xp: int = 0
var boosts: int = 3
var city_index: int = 0
var renovations: Dictionary = {}
var daily_claimed_at: int = 0
var energy_updated_at: float = 0.0
var total_merges: int = 0
var total_orders: int = 0
var discovered: Array[String] = []
var inventory_capacity: int = 10
var total_cooked: int = 0
var claimed_levels: Array[int] = [1]
var claimed_goals: Array[String] = []
var tutorial_step: int = 0
var tutorial_rewarded: bool = false
var _order_cursor: int = 0
var _next_order_id: int = 1
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _init() -> void:
	new_game()

func new_game(seed_value: int = 0) -> void:
	if seed_value == 0:
		_rng.randomize()
	else:
		_rng.seed = seed_value
	board.assign([
		"produce_fruit", "produce_veg", "produce_pantry", "cherry", "cherry", "tomato", "tomato",
		"strawberry", "strawberry", "bread", "bread", "banana", "carrot", "carrot",
		"flour", "flour", "broccoli", "cheese", "egg", "pineapple", "avocado",
		"cherry", "tomato", "flour", "banana", "broccoli", "bread", "strawberry",
		"", "carrot", "", "cheese", "", "tomato", "",
		"", "", "", "", "", "", "",
		"cherry", "cherry", "", "tomato", "tomato", "", "",
		"locked", "locked", "locked", "locked", "locked", "locked", "locked",
		"locked", "locked", "locked", "locked", "locked", "locked", "locked",
	])
	inventory.clear()
	jobs.clear()
	orders.clear()
	energy = 80
	coins = 240
	stars = 2
	gems = 20
	xp = 0
	boosts = 3
	city_index = 0
	renovations = {}
	for i in CITIES.size(): renovations[str(i)] = {}
	inventory_capacity = 10
	total_cooked = 0
	claimed_levels.assign([1])
	claimed_goals.clear()
	tutorial_step = 0
	tutorial_rewarded = false
	daily_claimed_at = 0
	energy_updated_at = Time.get_unix_time_from_system()
	total_merges = 0
	total_orders = 0
	_order_cursor = 0
	_next_order_id = 1
	discovered.clear()
	for item: String in board:
		_discover(item)
	for item: String in ["cherry", "smoothie", "toast", "tomato", "salad", "benedict", "strawberry"]:
		orders.append(_make_order(item))
	changed.emit()

func get_item(id: String) -> Dictionary:
	return ITEMS.get(id, {})

func get_recipe(id: String) -> Dictionary:
	for recipe: Dictionary in RECIPES:
		if recipe["id"] == id:
			return recipe
	return {}

func get_level() -> int:
	return mini(MAX_LEVEL, 1 + int(xp / 100.0))

func get_unlocked_city() -> int:
	for index: int in range(CITIES.size() - 1):
		if renovations.get(str(index), {}).size() < PARTS.size():
			return index
	return CITIES.size() - 1

func get_renovation(part: String) -> String:
	return str(renovations.get(str(city_index), {}).get(part, ""))

func is_order_ready(index: int) -> bool:
	return index >= 0 and index < orders.size() and board.has(str(orders[index]["item"]))

func can_move(index: int) -> bool:
	return _valid_cell(index) and ITEMS.has(board[index]) and ITEMS[board[index]]["chain"] != "generator"

func generate(index: int) -> bool:
	if not _valid_cell(index) or not ITEMS.has(board[index]) or ITEMS[board[index]]["chain"] != "generator":
		return _fail("Tap one of the three ingredient baskets.")
	return generate_from(board[index])

func generate_from(source: String) -> bool:
	var chain: Dictionary = {}
	for entry in CHAINS:
		if entry.generator == source: chain = entry
	if chain.is_empty(): return _fail("Choose an ingredient supplier.")
	if get_level() < int(chain.level): return _fail("This supplier opens at chef level %d." % int(chain.level))
	tick()
	if energy <= 0: return _fail("Energy is resting. Visit the market or collect a daily gift.")
	var empty: int = board.find("")
	if empty < 0: return _fail("Your board is full. Store, merge, cook, or sell an ingredient.")
	var item: String = chain.items[1 if _rng.randf() < 0.18 else 0]
	if energy == ENERGY_MAX: energy_updated_at = Time.get_unix_time_from_system()
	energy -= 1
	board[empty] = item
	_discover(item)
	_tutorial_event("generate")
	_commit("")
	return true

func move_or_merge(from: int, to: int) -> bool:
	if not can_move(from) or not _valid_cell(to) or from == to:
		return false
	if board[to] == "locked":
		return _fail("Merge beside a dusty tile to clear it.")
	if ITEMS.has(board[to]) and ITEMS[board[to]]["chain"] == "generator":
		return _fail("Your ingredient baskets stay at the top.")
	var item: String = board[from]
	if item == board[to] and not str(ITEMS[item]["next"]).is_empty():
		var upgraded: String = ITEMS[item]["next"]
		board[from] = ""
		board[to] = upgraded
		total_merges += 1
		_tutorial_event("merge")
		xp += 2
		_discover(upgraded)
		var cleared: int = _unlock_neighbors(to)
		_commit("%s!%s" % [ITEMS[upgraded]["name"], " A fresh corner unlocked." if cleared > 0 else " Lovely merge."])
	else:
		board[from] = board[to]
		board[to] = item
		_commit("")
	return true

func store_item(index: int) -> bool:
	if not can_move(index):
		return _fail("Choose an ingredient to tuck away.")
	if inventory.size() >= inventory_capacity:
		return _fail("The pantry is full. Bring an ingredient back first.")
	inventory.append(board[index])
	board[index] = ""
	_commit("Saved in your pantry.")
	return true

func restore_item(slot: int) -> bool:
	if slot < 0 or slot >= inventory.size():
		return false
	var empty: int = board.find("")
	if empty < 0:
		return _fail("Make a little room on your board first.")
	board[empty] = inventory[slot]
	inventory.remove_at(slot)
	_commit("Back in the kitchen!")
	return true

func start_cooking(index: int, recipe_id: String) -> bool:
	var recipe: Dictionary = get_recipe(recipe_id)
	if recipe.is_empty() or not can_move(index) or board[index] != recipe["input"]:
		return _fail("Pick the matching ingredient for this recipe.")
	if get_level() < int(recipe.level): return _fail("Unlock this recipe at chef level %d." % int(recipe.level))
	var extra_index: int = -1
	if not str(recipe.extra).is_empty():
		extra_index = board.find(recipe.extra)
		if extra_index < 0 or extra_index == index: return _fail("Also needed: %s." % ITEMS[recipe.extra].name)
	for job: Dictionary in jobs:
		if job["station"] == recipe["station"]:
			return _fail("That station is busy. Collect its dish first.")
	board[index] = ""
	if extra_index >= 0: board[extra_index] = ""
	_tutorial_event("cook")
	jobs.append({"recipe": recipe_id, "output": recipe["out"], "station": recipe["station"], "ready_at": Time.get_unix_time_from_system() + float(recipe["duration"])})
	_commit("%s is on its way!" % recipe["name"])
	return true

func cooking_seconds_remaining(job_index: int) -> int:
	if job_index < 0 or job_index >= jobs.size():
		return 0
	return maxi(0, int(ceil(float(jobs[job_index]["ready_at"]) - Time.get_unix_time_from_system())))

func collect_cooking(job_index: int) -> bool:
	if job_index < 0 or job_index >= jobs.size():
		return false
	if cooking_seconds_remaining(job_index) > 0:
		return _fail("Almost ready. Good food takes a moment.")
	var empty: int = board.find("")
	if empty < 0:
		return _fail("Make a little room to plate your dish.")
	var item: String = jobs[job_index]["output"]
	board[empty] = item
	jobs.remove_at(job_index)
	_discover(item)
	xp += 5
	total_cooked += 1
	_tutorial_event("collect")
	_commit("%s, made with love!" % ITEMS[item]["name"])
	return true

func boost_cooking(job_index: int) -> bool:
	if job_index < 0 or job_index >= jobs.size() or cooking_seconds_remaining(job_index) == 0:
		return false
	if boosts <= 0:
		return _fail("No cooking boosts left. Find more in your daily gift.")
	boosts -= 1
	jobs[job_index]["ready_at"] = maxf(Time.get_unix_time_from_system(), float(jobs[job_index]["ready_at"]) - 5.0)
	_commit("A little chef magic! 5 seconds saved.")
	return true

func serve_order(index: int) -> bool:
	if not is_order_ready(index):
		return _fail("This guest is happy to wait. Make their dish first.")
	var order: Dictionary = orders[index]
	board[board.find(str(order["item"]))] = ""
	coins += int(order["coins"])
	stars += int(order["stars"])
	xp += int(order["xp"])
	total_orders += 1
	_tutorial_event("serve")
	orders[index] = _make_order(_next_order_item())
	_commit("Merci, chef! +%d coins  +%d star" % [int(order["coins"]), int(order["stars"])])
	return true

func renovate(part: String, style: String) -> bool:
	if not PARTS.has(part) or not STYLES.has(style):
		return _fail("Choose a room detail and a color you love.")
	var current: Dictionary = renovations[str(city_index)]
	if current.has(part):
		if current[part] == style:
			return false
		current[part] = style
		_tutorial_event("renovate")
		_commit("A fresh new look. Redecorating is always free!")
		return true
	var cost: int = RENOVATION_COSTS[part]
	if stars < cost:
		return _fail("Serve a few more guests to earn %d stars." % cost)
	stars -= cost
	current[part] = style
	_tutorial_event("renovate")
	if current.size() == PARTS.size():
		_commit("A beautiful new beginning! Your next destination awaits." if city_index < CITIES.size() - 1 else "Eight cities, countless happy memories. Keep cooking, chef!")
	else:
		_commit("One lovely detail makes all the difference.")
	return true

func travel(index: int) -> bool:
	if index < 0 or index >= CITIES.size() or index > get_unlocked_city():
		return _fail("Finish your restaurant to unlock the next destination.")
	if index == city_index:
		return false
	city_index = index
	_order_cursor = 0
	orders.clear()
	for i: int in range(7):
		orders.append(_make_order(_next_order_item()))
	_commit("Welcome to %s! A new chapter begins." % CITIES[index]["name"])
	return true

func can_claim_daily() -> bool:
	return daily_claimed_at == 0 or _day_number(Time.get_unix_time_from_system()) > _day_number(float(daily_claimed_at))

func claim_daily() -> bool:
	if not can_claim_daily():
		return _fail("Your next little gift arrives tomorrow.")
	tick()
	daily_claimed_at = int(Time.get_unix_time_from_system())
	energy = mini(ENERGY_MAX, energy + 25)
	coins += 100
	stars += 1
	boosts += 2
	if energy == ENERGY_MAX:
		energy_updated_at = Time.get_unix_time_from_system()
	_commit("A gift for you! +25 energy, +100 coins, +1 star, +2 boosts.")
	return true

func energy_seconds_remaining() -> int:
	if energy >= ENERGY_MAX:
		return 0
	return maxi(0, int(ceil(ENERGY_INTERVAL - (Time.get_unix_time_from_system() - energy_updated_at))))

func tick() -> bool:
	var now: float = Time.get_unix_time_from_system()
	if now < energy_updated_at:
		energy_updated_at = now
	if energy >= ENERGY_MAX:
		energy_updated_at = now
		return false
	var units: int = int((now - energy_updated_at) / ENERGY_INTERVAL)
	if units <= 0:
		return false
	energy = mini(ENERGY_MAX, energy + units)
	energy_updated_at = now if energy == ENERGY_MAX else energy_updated_at + units * ENERGY_INTERVAL
	changed.emit()
	return true

func save_game(path: String = "user://kitchen_save.json") -> bool:
	var data: Dictionary = {
		"version": SAVE_VERSION, "board": board, "inventory": inventory, "orders": orders, "jobs": jobs,
		"energy": energy, "coins": coins, "stars": stars, "gems": gems, "xp": xp, "boosts": boosts,
		"city_index": city_index, "renovations": renovations, "daily_claimed_at": daily_claimed_at,
		"energy_updated_at": energy_updated_at, "total_merges": total_merges, "total_orders": total_orders,
		"discovered": discovered, "order_cursor": _order_cursor, "next_order_id": _next_order_id,
		"rng_seed": str(_rng.seed), "rng_state": str(_rng.state),
		"inventory_capacity": inventory_capacity, "total_cooked": total_cooked, "claimed_levels": claimed_levels, "claimed_goals": claimed_goals, "tutorial_step": tutorial_step, "tutorial_rewarded": tutorial_rewarded,
	}
	var temporary: String = path + ".tmp"
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "", true, true))
	file.flush()
	var write_ok: bool = file.get_error() == OK
	file.close()
	if not write_ok:
		return false
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path)) == OK

func load_game(path: String = "user://kitchen_save.json") -> bool:
	if not FileAccess.file_exists(path):
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false
	var parser: JSON = JSON.new()
	var parse_result: Error = parser.parse(file.get_as_text())
	file.close()
	if parse_result != OK:
		return false
	var parsed: Variant = parser.data
	if parsed is Dictionary and parsed.get("version") == 1: parsed = _migrate_v1(parsed)
	if not parsed is Dictionary or not _validate_save(parsed):
		return false
	var data: Dictionary = parsed
	board.assign(data["board"])
	inventory.assign(data["inventory"])
	orders.assign(data["orders"])
	for order: Dictionary in orders:
		for key: String in ["id", "coins", "stars", "xp"]:
			order[key] = int(order[key])
	jobs.assign(data["jobs"])
	energy = int(data["energy"])
	coins = int(data["coins"])
	stars = int(data["stars"])
	gems = int(data["gems"])
	xp = int(data["xp"])
	boosts = int(data["boosts"])
	city_index = int(data["city_index"])
	renovations = data["renovations"].duplicate(true)
	daily_claimed_at = int(data["daily_claimed_at"])
	energy_updated_at = float(data["energy_updated_at"])
	total_merges = int(data["total_merges"])
	total_orders = int(data["total_orders"])
	discovered.assign(data["discovered"])
	_order_cursor = int(data["order_cursor"])
	_next_order_id = int(data["next_order_id"])
	inventory_capacity = int(data.inventory_capacity)
	total_cooked = int(data.total_cooked)
	claimed_levels.assign(data.claimed_levels.map(func(value): return int(value)))
	claimed_goals.assign(data.claimed_goals)
	tutorial_step = int(data.tutorial_step)
	tutorial_rewarded = bool(data.tutorial_rewarded)
	_rng.seed = int(data["rng_seed"])
	_rng.state = int(data["rng_state"])
	tick()
	changed.emit()
	return true

func _validate_save(data: Dictionary) -> bool:
	if data.get("version") != SAVE_VERSION:
		return false
	if not _validate_expansion(data): return false
	for key: String in ["energy", "coins", "stars", "gems", "xp", "boosts", "city_index", "daily_claimed_at", "total_merges", "total_orders", "order_cursor", "next_order_id"]:
		if not _nonnegative_integer(data.get(key)):
			return false
	if data["energy"] > ENERGY_MAX or data["city_index"] >= CITIES.size():
		return false
	if not _nonnegative_number(data.get("energy_updated_at")):
		return false
	for key: String in ["rng_seed", "rng_state"]:
		if not data.get(key) is String or not str(data[key]).is_valid_int():
			return false
	if not data.get("board") is Array or data["board"].size() != COLS * ROWS:
		return false
	var anchors: Array[String] = ["produce_fruit", "produce_veg", "produce_pantry"]
	for index: int in range(COLS * ROWS):
		var item: Variant = data["board"][index]
		if not item is String:
			return false
		if index < 3:
			if item != anchors[index]:
				return false
		elif item != "" and item != "locked" and (not ITEMS.has(item) or ITEMS[item]["chain"] == "generator"):
			return false
	if not data.get("inventory") is Array or data["inventory"].size() > int(data.inventory_capacity):
		return false
	for item: Variant in data["inventory"]:
		if not item is String or not ITEMS.has(item) or ITEMS[item]["chain"] == "generator":
			return false
	if not data.get("discovered") is Array:
		return false
	for item: Variant in data["discovered"]:
		if not item is String or not ITEMS.has(item):
			return false
	if not data.get("orders") is Array or data["orders"].size() != 7:
		return false
	for order: Variant in data["orders"]:
		if not order is Dictionary or not order.get("item") is String or not ITEMS.has(order["item"]) or ITEMS[order["item"]]["chain"] == "generator" or not order.get("customer") is String:
			return false
		for key: String in ["id", "coins", "stars", "xp"]:
			if not _nonnegative_integer(order.get(key)):
				return false
	if not data.get("jobs") is Array or data["jobs"].size() > STATIONS.size():
		return false
	var occupied_stations: Array[String] = []
	for job: Variant in data["jobs"]:
		if not job is Dictionary or not job.get("recipe") is String:
			return false
		var recipe: Dictionary = get_recipe(job["recipe"])
		if recipe.is_empty() or job.get("output") != recipe["out"] or job.get("station") != recipe["station"] or not _nonnegative_number(job.get("ready_at")):
			return false
		if occupied_stations.has(str(job["station"])):
			return false
		occupied_stations.append(str(job["station"]))
	if not data.get("renovations") is Dictionary:
		return false
	for index: int in range(CITIES.size()):
		var room: Variant = data["renovations"].get(str(index))
		if not room is Dictionary:
			return false
		for part: Variant in room:
			if not part is String or not PARTS.has(part) or not room[part] is String or not STYLES.has(room[part]):
				return false
	for index: int in range(int(data["city_index"])):
		if data["renovations"][str(index)].size() < PARTS.size():
			return false
	return true

func _nonnegative_integer(value: Variant) -> bool:
	return _nonnegative_number(value) and float(value) == floor(float(value)) and float(value) < 9.0e15

func _nonnegative_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) >= 0.0

func _valid_cell(index: int) -> bool:
	return index >= 0 and index < board.size()

func _unlock_neighbors(index: int) -> int:
	var unlocked: int = 0
	for offset: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
		var position: Vector2i = Vector2i(index % COLS, int(index / float(COLS))) + offset
		if position.x < 0 or position.x >= COLS or position.y < 0 or position.y >= ROWS:
			continue
		var adjacent: int = position.y * COLS + position.x
		if board[adjacent] == "locked":
			board[adjacent] = ""
			unlocked += 1
	return unlocked

func _make_order(item: String) -> Dictionary:
	var tier: int = int(ITEMS[item]["tier"])
	var result: Dictionary = {"id": _next_order_id, "customer": CUSTOMERS[(_next_order_id - 1 + city_index * 2) % CUSTOMERS.size()], "item": item, "coins": 15 + tier * 12, "stars": 1, "xp": 8 + tier * 3}
	_next_order_id += 1
	return result

func _next_order_item() -> String:
	# Only attainable, level-unlocked dishes enter the order pool.
	var options: Array[String] = ["cherry", "carrot", "bread", "strawberry"]
	for recipe in RECIPES:
		if int(recipe.level) <= get_level(): options.append(recipe.out)
	var signature: String = CITIES[city_index].signature
	if int(get_recipe(signature).get("level", 1)) <= get_level(): options.append(signature)
	var result: String = options[(_order_cursor + city_index * 3) % options.size()]
	_order_cursor += 1
	return result

func _discover(item: String) -> void:
	if ITEMS.has(item) and not discovered.has(item):
		discovered.append(item)

func _day_number(timestamp: float) -> int:
	return int(timestamp / 86400.0)

func _commit(message: String) -> void:
	changed.emit()
	if not message.is_empty():
		feedback.emit(message)

func _fail(message: String) -> bool:
	feedback.emit(message)
	return false

func recipe_status(recipe: Dictionary) -> String:
	if get_level() < int(recipe.level): return "Chef level %d" % int(recipe.level)
	for job in jobs:
		if job.station == recipe.station: return "Station busy"
	if not board.has(recipe.input): return "Need %s" % ITEMS[recipe.input].name
	if not str(recipe.extra).is_empty() and not board.has(recipe.extra): return "Also need %s" % ITEMS[recipe.extra].name
	return ""

func find_merge() -> Array[int]:
	for i in board.size():
		if not can_move(i) or str(ITEMS[board[i]].next).is_empty(): continue
		for j in range(i + 1, board.size()):
			if board[i] == board[j]: return [i, j]
	return []

func sell_item(index: int) -> bool:
	if not can_move(index): return _fail("Choose a food item to sell.")
	var value: int = int(ITEMS[board[index]].tier) * 2
	board[index] = ""
	coins += value
	_commit("A little more space! +%d coins." % value)
	return true

func buy_supply(kind: String) -> bool:
	var cost: int = {"energy": 120, "boost": 75, "storage": 250}.get(kind, 0)
	if cost == 0: return false
	if kind == "energy" and energy >= ENERGY_MAX: return _fail("Your energy is already full.")
	if kind == "storage" and inventory_capacity >= 20: return _fail("Your pantry has all 20 slots.")
	if coins < cost: return _fail("Serve a few more guests to earn %d coins." % cost)
	coins -= cost
	match kind:
		"energy":
			tick()
			energy = mini(ENERGY_MAX, energy + 30)
			if energy == ENERGY_MAX: energy_updated_at = Time.get_unix_time_from_system()
		"boost": boosts += 3
		"storage": inventory_capacity += 1
	_commit("A little kitchen upgrade, just for you.")
	return true

func pending_level_rewards() -> int:
	var count: int = 0
	for level in range(2, get_level() + 1):
		if not claimed_levels.has(level): count += 1
	return count

func claim_level_rewards() -> bool:
	var count: int = pending_level_rewards()
	if count == 0: return false
	for level in range(2, get_level() + 1):
		if claimed_levels.has(level): continue
		coins += level * 25
		energy = mini(ENERGY_MAX, energy + 10)
		boosts += 1
		claimed_levels.append(level)
	if energy == ENERGY_MAX: energy_updated_at = Time.get_unix_time_from_system()
	_commit("%d chef rewards claimed! Coins, energy, and boosts." % count)
	return true

func goal_progress(goal: Dictionary) -> int:
	match str(goal.kind):
		"merges": return total_merges
		"orders": return total_orders
		"cooked": return total_cooked
		"discovered":
			var foods: int = 0
			for id in discovered:
				if ITEMS[id].chain != "generator": foods += 1
			return foods
		"cities": return get_unlocked_city() + 1
	return 0

func claim_goal(id: String) -> bool:
	if claimed_goals.has(id): return false
	for goal in GOALS:
		if goal.id != id: continue
		if goal_progress(goal) < int(goal.target): return _fail("Keep going, chef. Every little step counts.")
		claimed_goals.append(id)
		coins += int(goal.coins)
		stars += int(goal.stars)
		_commit("%s! +%d coins, +%d stars." % [goal.title, int(goal.coins), int(goal.stars)])
		return true
	return false

func start_tutorial() -> void:
	tutorial_step = 1
	_commit("")

func skip_tutorial() -> void:
	tutorial_step = 7
	_commit("")

func _tutorial_event(action: String) -> void:
	var actions: Array[String] = ["", "generate", "merge", "cook", "collect", "serve", "renovate"]
	if tutorial_step < 1 or tutorial_step >= 7 or actions[tutorial_step] != action: return
	tutorial_step += 1
	if tutorial_step == 7 and not tutorial_rewarded:
		tutorial_rewarded = true
		coins += 50
		stars += 1
		energy = mini(ENERGY_MAX, energy + 10)
		if energy == ENERGY_MAX: energy_updated_at = Time.get_unix_time_from_system()
	if tutorial_step == 7: tutorial_finished.emit()

func _migrate_v1(old: Dictionary) -> Dictionary:
	var data: Dictionary = old.duplicate(true)
	if not data.get("renovations") is Dictionary: return data
	for i in range(4, CITIES.size()): data.renovations[str(i)] = {}
	data.version = SAVE_VERSION
	data.inventory_capacity = 10
	data.total_cooked = 0
	data.claimed_levels = [1]
	data.claimed_goals = []
	# Returning players keep playing; the guide can be replayed from Help.
	data.tutorial_step = 7
	data.tutorial_rewarded = false
	return data

func _validate_expansion(data: Dictionary) -> bool:
	for key in ["inventory_capacity", "total_cooked", "tutorial_step"]:
		if not _nonnegative_integer(data.get(key)): return false
	if int(data.inventory_capacity) < 10 or int(data.inventory_capacity) > 20 or int(data.tutorial_step) > 7: return false
	if not data.get("tutorial_rewarded") is bool: return false
	if not data.get("claimed_levels") is Array or not data.get("claimed_goals") is Array: return false
	var levels: Array = []
	for value in data.claimed_levels:
		if not _nonnegative_integer(value) or int(value) < 1 or int(value) > MAX_LEVEL or levels.has(int(value)): return false
		levels.append(int(value))
	var goals: Array = []
	for value in data.claimed_goals:
		if not value is String or goals.has(value): return false
		var known: bool = false
		for goal in GOALS:
			if goal.id == value: known = true
		if not known: return false
		goals.append(value)
	return true
