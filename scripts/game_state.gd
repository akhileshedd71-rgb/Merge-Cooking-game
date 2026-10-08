class_name KitchenState
extends RefCounted
## Deterministic, scene-independent rules for Little World Kitchen.

signal changed
signal feedback(message: String)

const COLS: int = 7
const ROWS: int = 9
const ENERGY_MAX: int = 100
const INVENTORY_MAX: int = 10
const ENERGY_INTERVAL: float = 45.0
const SAVE_VERSION: int = 1
const PARTS: Array[String] = ["floor", "tables", "decor"]
const RENOVATION_COSTS: Dictionary = {"floor": 2, "tables": 3, "decor": 4}
const STYLES: Array[String] = ["sage", "sunshine", "rose"]

const ITEMS: Dictionary = {
	"produce_fruit": {"name": "Fruit basket", "chain": "generator", "tier": 1, "next": "", "icon": "produce_fruit", "description": "Tap to grow cherries and strawberries. Costs 1 energy."},
	"produce_veg": {"name": "Garden crate", "chain": "generator", "tier": 1, "next": "", "icon": "produce_veg", "description": "Tap for tomatoes and carrots. Costs 1 energy."},
	"produce_pantry": {"name": "Pantry", "chain": "generator", "tier": 1, "next": "", "icon": "produce_pantry", "description": "Tap for flour and bread. Costs 1 energy."},
	"cherry": {"name": "Cherries", "chain": "fruit", "tier": 1, "next": "strawberry", "icon": "cherry"},
	"strawberry": {"name": "Strawberry", "chain": "fruit", "tier": 2, "next": "banana", "icon": "strawberry"},
	"banana": {"name": "Banana", "chain": "fruit", "tier": 3, "next": "pineapple", "icon": "banana"},
	"pineapple": {"name": "Pineapple", "chain": "fruit", "tier": 4, "next": "", "icon": "pineapple"},
	"tomato": {"name": "Tomato", "chain": "veg", "tier": 1, "next": "carrot", "icon": "tomato"},
	"carrot": {"name": "Carrot", "chain": "veg", "tier": 2, "next": "broccoli", "icon": "carrot"},
	"broccoli": {"name": "Broccoli", "chain": "veg", "tier": 3, "next": "avocado", "icon": "broccoli"},
	"avocado": {"name": "Avocado", "chain": "veg", "tier": 4, "next": "", "icon": "avocado"},
	"flour": {"name": "Flour", "chain": "pantry", "tier": 1, "next": "bread", "icon": "flour"},
	"bread": {"name": "Bread", "chain": "pantry", "tier": 2, "next": "cheese", "icon": "bread"},
	"cheese": {"name": "Cheese", "chain": "pantry", "tier": 3, "next": "egg", "icon": "cheese"},
	"egg": {"name": "Eggs", "chain": "pantry", "tier": 4, "next": "", "icon": "egg"},
	"smoothie": {"name": "Banana smoothie", "chain": "dish", "tier": 5, "next": "", "icon": "smoothie"},
	"salad": {"name": "Garden salad", "chain": "dish", "tier": 5, "next": "", "icon": "salad"},
	"toast": {"name": "Golden toast", "chain": "dish", "tier": 5, "next": "", "icon": "toast"},
	"benedict": {"name": "Eggs Benedict", "chain": "dish", "tier": 5, "next": "", "icon": "benedict"},
	"soup": {"name": "Sunshine soup", "chain": "dish", "tier": 5, "next": "", "icon": "soup"},
	"sushi": {"name": "Avocado sushi", "chain": "dish", "tier": 5, "next": "", "icon": "sushi"},
	"ramen": {"name": "Creamy ramen", "chain": "dish", "tier": 5, "next": "", "icon": "ramen"},
	"macaron": {"name": "Dreamy macarons", "chain": "dish", "tier": 5, "next": "", "icon": "macaron"},
	"tropical": {"name": "Tropical fizz", "chain": "dish", "tier": 5, "next": "", "icon": "tropical"},
}

const STATIONS: Dictionary = {
	"pan": {"name": "Frying pan", "description": "A little sizzle, a lot of happiness."},
	"blender": {"name": "Blender", "description": "Whirl fresh fruit into something lovely."},
	"oven": {"name": "Oven", "description": "Good things come to those who bake."},
	"pot": {"name": "Soup pot", "description": "Comfort, simmered slowly."},
	"steamer": {"name": "Steamer", "description": "Keep it fresh, bright and green."},
	"grill": {"name": "Grill", "description": "Give your ingredients a warm welcome."},
	"shaker": {"name": "Shaker", "description": "Shake up a little sunshine."},
}
const RECIPES: Array[Dictionary] = [
	{"id": "smoothie", "name": "Banana smoothie", "input": "banana", "station": "blender", "out": "smoothie", "duration": 10.0},
	{"id": "salad", "name": "Garden salad", "input": "broccoli", "station": "steamer", "out": "salad", "duration": 12.0},
	{"id": "toast", "name": "Golden toast", "input": "bread", "station": "oven", "out": "toast", "duration": 8.0},
	{"id": "benedict", "name": "Eggs Benedict", "input": "egg", "station": "pan", "out": "benedict", "duration": 16.0},
	{"id": "soup", "name": "Sunshine soup", "input": "carrot", "station": "pot", "out": "soup", "duration": 12.0},
	{"id": "sushi", "name": "Avocado sushi", "input": "avocado", "station": "grill", "out": "sushi", "duration": 18.0},
	{"id": "ramen", "name": "Creamy ramen", "input": "cheese", "station": "pot", "out": "ramen", "duration": 16.0},
	{"id": "macaron", "name": "Dreamy macarons", "input": "flour", "station": "oven", "out": "macaron", "duration": 18.0},
	{"id": "tropical", "name": "Tropical fizz", "input": "pineapple", "station": "shaker", "out": "tropical", "duration": 10.0},
]
const CITIES: Array[Dictionary] = [
	{"name": "New York", "country": "United States", "subtitle": "The little corner café", "signature": "benedict", "story": "Coach Miles has a big heart and a tiny café. Let's make it the neighborhood's favorite brunch spot!"},
	{"name": "Bangkok", "country": "Thailand", "subtitle": "A taste of sunshine", "signature": "soup", "story": "Mali's riverside kitchen is full of stories. A bright new dining room will give them a place to shine."},
	{"name": "Tokyo", "country": "Japan", "subtitle": "Small plates, big dreams", "signature": "sushi", "story": "Haru has perfected the recipes. Now we're helping turn a quiet corner into a warm neighborhood kitchen."},
	{"name": "Paris", "country": "France", "subtitle": "A little joie de vivre", "signature": "macaron", "story": "Camille believes every beautiful day starts with a pastry. Let's create a bistro as delightful as her macarons."},
]
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
	renovations = {"0": {}, "1": {}, "2": {}, "3": {}}
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
	return 1 + int(xp / 100.0)

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
	tick()
	if energy <= 0:
		return _fail("A little rest! Energy recharges every 45 seconds.")
	var empty: int = board.find("")
	if empty < 0:
		return _fail("Your kitchen is full. Merge, cook or store an ingredient.")
	var choices: Dictionary = {"produce_fruit": ["cherry", "strawberry"], "produce_veg": ["tomato", "carrot"], "produce_pantry": ["flour", "bread"]}
	var item: String = choices[board[index]][1 if _rng.randf() < 0.18 else 0]
	if energy == ENERGY_MAX:
		energy_updated_at = Time.get_unix_time_from_system()
	energy -= 1
	board[empty] = item
	_discover(item)
	_commit("Fresh %s!" % ITEMS[item]["name"].to_lower())
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
	if inventory.size() >= INVENTORY_MAX:
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
	for job: Dictionary in jobs:
		if job["station"] == recipe["station"]:
			return _fail("That station is busy. Collect its dish first.")
	board[index] = ""
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
		_commit("A fresh new look. Redecorating is always free!")
		return true
	var cost: int = RENOVATION_COSTS[part]
	if stars < cost:
		return _fail("Serve a few more guests to earn %d stars." % cost)
	stars -= cost
	current[part] = style
	if current.size() == PARTS.size():
		_commit("A beautiful new beginning! Your next destination awaits." if city_index < CITIES.size() - 1 else "Four cities, countless happy memories. Keep cooking, chef!")
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
	_rng.seed = int(data["rng_seed"])
	_rng.state = int(data["rng_state"])
	tick()
	changed.emit()
	return true

func _validate_save(data: Dictionary) -> bool:
	if data.get("version") != SAVE_VERSION:
		return false
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
	if not data.get("inventory") is Array or data["inventory"].size() > INVENTORY_MAX:
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
	var options: Array[String] = ["cherry", "toast", "carrot", str(CITIES[city_index]["signature"]), "smoothie", "bread", "salad", "strawberry", "soup", "ramen", "tropical", "macaron"]
	var result: String = options[_order_cursor % options.size()]
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
