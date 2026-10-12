class_name KitchenCatalog
extends RefCounted
## Stable identifiers are shared by saves, original artwork, and the UI.

const ITEMS: Dictionary = {
	"produce_fruit": {
		"name": "Fruit basket",
		"chain": "generator",
		"tier": 1,
		"next": "",
		"icon": "produce_fruit",
		"description": "Tap to grow cherries and strawberries. Costs 1 energy."
	},
	"produce_veg": {
		"name": "Garden crate",
		"chain": "generator",
		"tier": 1,
		"next": "",
		"icon": "produce_veg",
		"description": "Tap for tomatoes and carrots. Costs 1 energy."
	},
	"produce_pantry": {
		"name": "Pantry",
		"chain": "generator",
		"tier": 1,
		"next": "",
		"icon": "produce_pantry",
		"description": "Tap for flour and bread. Costs 1 energy."
	},
	"cherry": {
		"name": "Cherries",
		"chain": "fruit",
		"tier": 1,
		"next": "strawberry",
		"icon": "cherry"
	},
	"strawberry": {
		"name": "Strawberry",
		"chain": "fruit",
		"tier": 2,
		"next": "banana",
		"icon": "strawberry"
	},
	"banana": {
		"name": "Banana",
		"chain": "fruit",
		"tier": 3,
		"next": "pineapple",
		"icon": "banana"
	},
	"pineapple": {
		"name": "Pineapple",
		"chain": "fruit",
		"tier": 4,
		"next": "mango",
		"icon": "pineapple"
	},
	"tomato": {
		"name": "Tomato",
		"chain": "veg",
		"tier": 1,
		"next": "carrot",
		"icon": "tomato"
	},
	"carrot": {
		"name": "Carrot",
		"chain": "veg",
		"tier": 2,
		"next": "broccoli",
		"icon": "carrot"
	},
	"broccoli": {
		"name": "Broccoli",
		"chain": "veg",
		"tier": 3,
		"next": "avocado",
		"icon": "broccoli"
	},
	"avocado": {
		"name": "Avocado",
		"chain": "veg",
		"tier": 4,
		"next": "pepper",
		"icon": "avocado"
	},
	"flour": {
		"name": "Flour",
		"chain": "pantry",
		"tier": 1,
		"next": "bread",
		"icon": "flour"
	},
	"bread": {
		"name": "Bread",
		"chain": "pantry",
		"tier": 2,
		"next": "cheese",
		"icon": "bread"
	},
	"cheese": {
		"name": "Cheese",
		"chain": "pantry",
		"tier": 3,
		"next": "egg",
		"icon": "cheese"
	},
	"egg": {
		"name": "Eggs",
		"chain": "pantry",
		"tier": 4,
		"next": "butter",
		"icon": "egg"
	},
	"smoothie": {
		"name": "Banana smoothie",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "smoothie"
	},
	"salad": {
		"name": "Garden salad",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "salad"
	},
	"toast": {
		"name": "Golden toast",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "toast"
	},
	"benedict": {
		"name": "Eggs Benedict",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "benedict"
	},
	"soup": {
		"name": "Sunshine soup",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "soup"
	},
	"sushi": {
		"name": "Avocado sushi",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "sushi"
	},
	"ramen": {
		"name": "Creamy ramen",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "ramen"
	},
	"macaron": {
		"name": "Dreamy macarons",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "macaron"
	},
	"tropical": {
		"name": "Tropical fizz",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "tropical"
	},
	"mango": {
		"name": "Mango",
		"chain": "fruit",
		"tier": 5,
		"next": "coconut",
		"icon": "mango"
	},
	"coconut": {
		"name": "Coconut",
		"chain": "fruit",
		"tier": 6,
		"next": "",
		"icon": "coconut"
	},
	"pepper": {
		"name": "Pepper",
		"chain": "veg",
		"tier": 5,
		"next": "mushroom",
		"icon": "pepper"
	},
	"mushroom": {
		"name": "Mushroom",
		"chain": "veg",
		"tier": 6,
		"next": "",
		"icon": "mushroom"
	},
	"butter": {
		"name": "Butter",
		"chain": "pantry",
		"tier": 5,
		"next": "cream",
		"icon": "butter"
	},
	"cream": {
		"name": "Cream",
		"chain": "pantry",
		"tier": 6,
		"next": "",
		"icon": "cream"
	},
	"shrimp": {
		"name": "Shrimp",
		"chain": "seafood",
		"tier": 1,
		"next": "fish",
		"icon": "shrimp"
	},
	"fish": {
		"name": "Fish",
		"chain": "seafood",
		"tier": 2,
		"next": "salmon",
		"icon": "fish"
	},
	"salmon": {
		"name": "Salmon",
		"chain": "seafood",
		"tier": 3,
		"next": "crab",
		"icon": "salmon"
	},
	"crab": {
		"name": "Crab",
		"chain": "seafood",
		"tier": 4,
		"next": "lobster",
		"icon": "crab"
	},
	"lobster": {
		"name": "Lobster",
		"chain": "seafood",
		"tier": 5,
		"next": "roe",
		"icon": "lobster"
	},
	"roe": {
		"name": "Roe",
		"chain": "seafood",
		"tier": 6,
		"next": "",
		"icon": "roe"
	},
	"produce_seafood": {
		"name": "The fish market",
		"chain": "generator",
		"tier": 1,
		"next": "",
		"icon": "produce_seafood",
		"description": "Unlocks at chef level 3. Fresh supplies cost 1 energy."
	},
	"cocoa": {
		"name": "Cocoa",
		"chain": "bakery",
		"tier": 1,
		"next": "cookie",
		"icon": "cocoa"
	},
	"cookie": {
		"name": "Cookie",
		"chain": "bakery",
		"tier": 2,
		"next": "chocolate",
		"icon": "cookie"
	},
	"chocolate": {
		"name": "Chocolate",
		"chain": "bakery",
		"tier": 3,
		"next": "croissant",
		"icon": "chocolate"
	},
	"croissant": {
		"name": "Croissant",
		"chain": "bakery",
		"tier": 4,
		"next": "cake",
		"icon": "croissant"
	},
	"cake": {
		"name": "Cake",
		"chain": "bakery",
		"tier": 5,
		"next": "truffle",
		"icon": "cake"
	},
	"truffle": {
		"name": "Truffle",
		"chain": "bakery",
		"tier": 6,
		"next": "",
		"icon": "truffle"
	},
	"produce_bakery": {
		"name": "The patisserie",
		"chain": "generator",
		"tier": 1,
		"next": "",
		"icon": "produce_bakery",
		"description": "Unlocks at chef level 5. Fresh supplies cost 1 energy."
	},
	"berry_tart": {
		"name": "Berry tart",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "berry_tart"
	},
	"mango_lassi": {
		"name": "Mango lassi",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "mango_lassi"
	},
	"coconut_cooler": {
		"name": "Coconut cooler",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "coconut_cooler"
	},
	"bruschetta": {
		"name": "Bruschetta",
		"chain": "dish",
		"tier": 5,
		"next": "",
		"icon": "bruschetta"
	},
	"tacos": {
		"name": "Garden tacos",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "tacos"
	},
	"risotto": {
		"name": "Mushroom risotto",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "risotto"
	},
	"pizza": {
		"name": "Margherita pizza",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "pizza"
	},
	"pancakes": {
		"name": "Sunday pancakes",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "pancakes"
	},
	"creme_brulee": {
		"name": "Crème brûlée",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "creme_brulee"
	},
	"shrimp_skewer": {
		"name": "Shrimp skewers",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "shrimp_skewer"
	},
	"fish_chips": {
		"name": "Fish & chips",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "fish_chips"
	},
	"salmon_bowl": {
		"name": "Salmon bowl",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "salmon_bowl"
	},
	"crab_cakes": {
		"name": "Crab cakes",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "crab_cakes"
	},
	"lobster_bisque": {
		"name": "Lobster bisque",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "lobster_bisque"
	},
	"caviar_toast": {
		"name": "Caviar toast",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "caviar_toast"
	},
	"hot_cocoa": {
		"name": "Hot cocoa",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "hot_cocoa"
	},
	"choc_cookie": {
		"name": "Chocolate cookies",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "choc_cookie"
	},
	"chocolate_mousse": {
		"name": "Chocolate mousse",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "chocolate_mousse"
	},
	"croissant_sandwich": {
		"name": "Croissant sandwich",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "croissant_sandwich"
	},
	"strawberry_cake": {
		"name": "Strawberry gâteau",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "strawberry_cake"
	},
	"truffle_box": {
		"name": "Truffle collection",
		"chain": "dish",
		"tier": 7,
		"next": "",
		"icon": "truffle_box"
	},
	"bibimbap": {
		"name": "Garden bibimbap",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "bibimbap"
	},
	"dumplings": {
		"name": "Mushroom dumplings",
		"chain": "dish",
		"tier": 6,
		"next": "",
		"icon": "dumplings"
	}
}

const RECIPES: Array[Dictionary] = [
	{
		"id": "smoothie",
		"name": "Banana smoothie",
		"input": "banana",
		"station": "blender",
		"out": "smoothie",
		"duration": 10.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "salad",
		"name": "Garden salad",
		"input": "broccoli",
		"station": "steamer",
		"out": "salad",
		"duration": 12.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "toast",
		"name": "Golden toast",
		"input": "bread",
		"station": "oven",
		"out": "toast",
		"duration": 8.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "benedict",
		"name": "Eggs Benedict",
		"input": "egg",
		"station": "pan",
		"out": "benedict",
		"duration": 16.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "soup",
		"name": "Sunshine soup",
		"input": "carrot",
		"station": "pot",
		"out": "soup",
		"duration": 12.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "sushi",
		"name": "Avocado sushi",
		"input": "avocado",
		"station": "grill",
		"out": "sushi",
		"duration": 18.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "ramen",
		"name": "Creamy ramen",
		"input": "cheese",
		"station": "pot",
		"out": "ramen",
		"duration": 16.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "macaron",
		"name": "Dreamy macarons",
		"input": "flour",
		"station": "oven",
		"out": "macaron",
		"duration": 18.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "tropical",
		"name": "Tropical fizz",
		"input": "pineapple",
		"station": "shaker",
		"out": "tropical",
		"duration": 10.0,
		"level": 1,
		"extra": ""
	},
	{
		"id": "berry_tart",
		"name": "Berry tart",
		"input": "strawberry",
		"extra": "flour",
		"station": "oven",
		"out": "berry_tart",
		"duration": 14.0,
		"level": 2
	},
	{
		"id": "mango_lassi",
		"name": "Mango lassi",
		"input": "mango",
		"extra": "",
		"station": "blender",
		"out": "mango_lassi",
		"duration": 14.0,
		"level": 2
	},
	{
		"id": "coconut_cooler",
		"name": "Coconut cooler",
		"input": "coconut",
		"extra": "",
		"station": "shaker",
		"out": "coconut_cooler",
		"duration": 16.0,
		"level": 3
	},
	{
		"id": "bruschetta",
		"name": "Bruschetta",
		"input": "tomato",
		"extra": "bread",
		"station": "grill",
		"out": "bruschetta",
		"duration": 14.0,
		"level": 2
	},
	{
		"id": "tacos",
		"name": "Garden tacos",
		"input": "pepper",
		"extra": "cheese",
		"station": "grill",
		"out": "tacos",
		"duration": 18.0,
		"level": 4
	},
	{
		"id": "risotto",
		"name": "Mushroom risotto",
		"input": "mushroom",
		"extra": "butter",
		"station": "pot",
		"out": "risotto",
		"duration": 22.0,
		"level": 6
	},
	{
		"id": "pizza",
		"name": "Margherita pizza",
		"input": "cheese",
		"extra": "tomato",
		"station": "oven",
		"out": "pizza",
		"duration": 16.0,
		"level": 3
	},
	{
		"id": "pancakes",
		"name": "Sunday pancakes",
		"input": "butter",
		"extra": "egg",
		"station": "pan",
		"out": "pancakes",
		"duration": 18.0,
		"level": 4
	},
	{
		"id": "creme_brulee",
		"name": "Crème brûlée",
		"input": "cream",
		"extra": "egg",
		"station": "oven",
		"out": "creme_brulee",
		"duration": 22.0,
		"level": 6
	},
	{
		"id": "shrimp_skewer",
		"name": "Shrimp skewers",
		"input": "shrimp",
		"extra": "",
		"station": "grill",
		"out": "shrimp_skewer",
		"duration": 16.0,
		"level": 3
	},
	{
		"id": "fish_chips",
		"name": "Fish & chips",
		"input": "fish",
		"extra": "bread",
		"station": "pan",
		"out": "fish_chips",
		"duration": 16.0,
		"level": 3
	},
	{
		"id": "salmon_bowl",
		"name": "Salmon bowl",
		"input": "salmon",
		"extra": "avocado",
		"station": "steamer",
		"out": "salmon_bowl",
		"duration": 18.0,
		"level": 4
	},
	{
		"id": "crab_cakes",
		"name": "Crab cakes",
		"input": "crab",
		"extra": "flour",
		"station": "pan",
		"out": "crab_cakes",
		"duration": 20.0,
		"level": 5
	},
	{
		"id": "lobster_bisque",
		"name": "Lobster bisque",
		"input": "lobster",
		"extra": "cream",
		"station": "pot",
		"out": "lobster_bisque",
		"duration": 24.0,
		"level": 7
	},
	{
		"id": "caviar_toast",
		"name": "Caviar toast",
		"input": "roe",
		"extra": "bread",
		"station": "pan",
		"out": "caviar_toast",
		"duration": 26.0,
		"level": 8
	},
	{
		"id": "hot_cocoa",
		"name": "Hot cocoa",
		"input": "cocoa",
		"extra": "",
		"station": "pot",
		"out": "hot_cocoa",
		"duration": 20.0,
		"level": 5
	},
	{
		"id": "choc_cookie",
		"name": "Chocolate cookies",
		"input": "cookie",
		"extra": "chocolate",
		"station": "oven",
		"out": "choc_cookie",
		"duration": 20.0,
		"level": 5
	},
	{
		"id": "chocolate_mousse",
		"name": "Chocolate mousse",
		"input": "chocolate",
		"extra": "cream",
		"station": "blender",
		"out": "chocolate_mousse",
		"duration": 22.0,
		"level": 6
	},
	{
		"id": "croissant_sandwich",
		"name": "Croissant sandwich",
		"input": "croissant",
		"extra": "cheese",
		"station": "grill",
		"out": "croissant_sandwich",
		"duration": 22.0,
		"level": 6
	},
	{
		"id": "strawberry_cake",
		"name": "Strawberry gâteau",
		"input": "cake",
		"extra": "strawberry",
		"station": "oven",
		"out": "strawberry_cake",
		"duration": 24.0,
		"level": 7
	},
	{
		"id": "truffle_box",
		"name": "Truffle collection",
		"input": "truffle",
		"extra": "",
		"station": "oven",
		"out": "truffle_box",
		"duration": 26.0,
		"level": 8
	},
	{
		"id": "bibimbap",
		"name": "Garden bibimbap",
		"input": "egg",
		"extra": "carrot",
		"station": "pan",
		"out": "bibimbap",
		"duration": 18.0,
		"level": 4
	},
	{
		"id": "dumplings",
		"name": "Mushroom dumplings",
		"input": "mushroom",
		"extra": "flour",
		"station": "steamer",
		"out": "dumplings",
		"duration": 20.0,
		"level": 5
	}
]

const CITIES: Array[Dictionary] = [
	{
		"name": "New York",
		"country": "United States",
		"subtitle": "The little corner café",
		"signature": "benedict",
		"story": "Coach Miles has a big heart and a tiny café. Let's make it the neighborhood's favorite brunch spot!",
		"art": "new_york"
	},
	{
		"name": "Bangkok",
		"country": "Thailand",
		"subtitle": "A taste of sunshine",
		"signature": "soup",
		"story": "Mali's riverside kitchen is full of stories. A bright new dining room will give them a place to shine.",
		"art": "bangkok"
	},
	{
		"name": "Tokyo",
		"country": "Japan",
		"subtitle": "Small plates, big dreams",
		"signature": "sushi",
		"story": "Haru has perfected the recipes. Now we're helping turn a quiet corner into a warm neighborhood kitchen.",
		"art": "tokyo"
	},
	{
		"name": "Paris",
		"country": "France",
		"subtitle": "A little joie de vivre",
		"signature": "macaron",
		"story": "Camille believes every beautiful day starts with a pastry. Let's create a bistro as delightful as her macarons.",
		"art": "paris"
	},
	{
		"name": "Rome",
		"country": "Italy",
		"subtitle": "A table in the piazza",
		"signature": "pizza",
		"story": "Nonna Rosa keeps one extra chair for a new friend. Bring her sunlit trattoria back to life.",
		"art": "rome"
	},
	{
		"name": "Mexico City",
		"country": "Mexico",
		"subtitle": "A fiesta of little flavors",
		"signature": "tacos",
		"story": "Diego dreams of a courtyard full of color, laughter, and sizzling tacos. Pull up a chair!",
		"art": "mexico_city"
	},
	{
		"name": "Istanbul",
		"country": "Türkiye",
		"subtitle": "Where two worlds meet",
		"signature": "shrimp_skewer",
		"story": "Deniz serves tea with every story. Give this waterfront kitchen a warm and welcoming glow.",
		"art": "istanbul"
	},
	{
		"name": "Seoul",
		"country": "South Korea",
		"subtitle": "A delicious new chapter",
		"signature": "bibimbap",
		"story": "Jin loves sharing family recipes after sunset. Let’s fill the neighborhood with warm lights and good food.",
		"art": "seoul"
	}
]

const CHAINS: Array[Dictionary] = [
	{
		"id": "fruit",
		"name": "The orchard",
		"generator": "produce_fruit",
		"level": 1,
		"items": [
			"cherry",
			"strawberry",
			"banana",
			"pineapple",
			"mango",
			"coconut"
		]
	},
	{
		"id": "veg",
		"name": "The garden",
		"generator": "produce_veg",
		"level": 1,
		"items": [
			"tomato",
			"carrot",
			"broccoli",
			"avocado",
			"pepper",
			"mushroom"
		]
	},
	{
		"id": "pantry",
		"name": "The pantry",
		"generator": "produce_pantry",
		"level": 1,
		"items": [
			"flour",
			"bread",
			"cheese",
			"egg",
			"butter",
			"cream"
		]
	},
	{
		"id": "seafood",
		"name": "The fish market",
		"generator": "produce_seafood",
		"level": 3,
		"items": [
			"shrimp",
			"fish",
			"salmon",
			"crab",
			"lobster",
			"roe"
		]
	},
	{
		"id": "bakery",
		"name": "The patisserie",
		"generator": "produce_bakery",
		"level": 5,
		"items": [
			"cocoa",
			"cookie",
			"chocolate",
			"croissant",
			"cake",
			"truffle"
		]
	}
]

const GOALS: Array[Dictionary] = [
	{
		"id": "first_merges",
		"title": "A perfect pair",
		"kind": "merges",
		"target": 5,
		"coins": 60,
		"stars": 1
	},
	{
		"id": "merge_party",
		"title": "A little merge magic",
		"kind": "merges",
		"target": 25,
		"coins": 120,
		"stars": 2
	},
	{
		"id": "merge_master",
		"title": "Master of the board",
		"kind": "merges",
		"target": 100,
		"coins": 300,
		"stars": 3
	},
	{
		"id": "neighbors",
		"title": "Meet the neighbors",
		"kind": "orders",
		"target": 3,
		"coins": 75,
		"stars": 1
	},
	{
		"id": "regulars",
		"title": "Everybody knows your name",
		"kind": "orders",
		"target": 15,
		"coins": 180,
		"stars": 2
	},
	{
		"id": "full_house",
		"title": "A very full house",
		"kind": "orders",
		"target": 50,
		"coins": 400,
		"stars": 3
	},
	{
		"id": "first_service",
		"title": "Made with love",
		"kind": "cooked",
		"target": 5,
		"coins": 90,
		"stars": 1
	},
	{
		"id": "sous_chef",
		"title": "A confident cook",
		"kind": "cooked",
		"target": 20,
		"coins": 200,
		"stars": 2
	},
	{
		"id": "collector",
		"title": "A curious palate",
		"kind": "discovered",
		"target": 35,
		"coins": 220,
		"stars": 2
	},
	{
		"id": "traveler",
		"title": "Flavors without borders",
		"kind": "cities",
		"target": 4,
		"coins": 350,
		"stars": 3
	}
]
