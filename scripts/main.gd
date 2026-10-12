extends Control
## All gameplay is kept in KitchenState; this scene presents the portrait game.
const Tile = preload("res://scripts/board_tile.gd")
const Sound = preload("res://scripts/sound.gd")
const DropButton = preload("res://scripts/drop_button.gd")
const INK = Color("294e46")
const MUTED = Color("7a8f81")
const CREAM = Color("fbf8ed")
const MINT = Color("e5efe3")
const GREEN = Color("397b62")
const CORAL = Color("e98269")
const GOLD = Color("f0b94e")
const WHITE = Color("fffef8")
var state: KitchenState
var canvas: Control
var content: Control
var overlay: Control
var toast_layer: Control
var sfx: Node
var body_font: Font
var title_font: Font
var selected: int = -1
var current_tab: String = "Kitchen"
var modal: String = ""
var modal_arg: String = ""
var pending_refresh: bool = false
var second: float = 0.0
var timers: Array[Dictionary] = []
var scroll_positions: Dictionary = {}
var active_scrolls: Dictionary = {}
var toast_serial: int = 0
var sparkles: Array[Dictionary] = []
var screenshot_path: String = ""
var pop_cells: Array[int] = []
var guide_layer: Control
var journal_mode: String = "Recipes"
var recipe_filter: String = "All"
var career_mode: String = "Goals"
var hint_cells: Array[int] = []
var hint_seconds: float = 0.0
var transition_requested: bool = false
var last_level: int = 1
var toast_tween: Tween
var reduced_motion: bool = false
var last_tutorial_step: int = 0
var graduation_pending: bool = false

func _ready() -> void:
	body_font = load("res://assets/fonts/Quicksand.ttf") if ResourceLoader.exists("res://assets/fonts/Quicksand.ttf") else ThemeDB.fallback_font
	title_font = load("res://assets/fonts/Fraunces.ttf") if ResourceLoader.exists("res://assets/fonts/Fraunces.ttf") else body_font
	var rounded := FontVariation.new()
	rounded.base_font = body_font
	rounded.variation_opentype = {2003265652:600.0} # OpenType 'wght' tag.
	if ResourceLoader.exists("res://assets/fonts/Fallback.ttf"):
		rounded.fallbacks = [load("res://assets/fonts/Fallback.ttf")]
	body_font = rounded
	state = KitchenState.new()
	if not "--fresh" in OS.get_cmdline_user_args(): state.load_game()
	last_level = state.get_level()
	last_tutorial_step = state.tutorial_step
	state.changed.connect(_state_changed)
	state.feedback.connect(_toast)
	state.tutorial_finished.connect(func(): graduation_pending = true)
	sfx = Sound.new()
	add_child(sfx)
	var preferences := ConfigFile.new()
	if preferences.load("user://preferences.cfg") == OK:
		sfx.enabled = bool(preferences.get_value("audio","enabled",true))
		reduced_motion = bool(preferences.get_value("display","reduced_motion",false))
	canvas = Control.new()
	canvas.size = Vector2(540, 1080)
	add_child(canvas)
	content = Control.new()
	content.size = canvas.size
	canvas.add_child(content)
	guide_layer = Control.new()
	guide_layer.size = canvas.size
	guide_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(guide_layer)
	overlay = Control.new()
	overlay.size = canvas.size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(overlay)
	toast_layer = Control.new()
	toast_layer.size = canvas.size
	toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(toast_layer)
	resized.connect(_fit)
	_fit()
	if state.tutorial_step == 0: modal = "welcome"
	_render()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--screenshot="): screenshot_path = arg.trim_prefix("--screenshot=")
	if not screenshot_path.is_empty():
		await get_tree().create_timer(1.0).timeout
		get_viewport().get_texture().get_image().save_png(screenshot_path)
		get_tree().quit()

func _fit() -> void:
	if not is_instance_valid(canvas): return
	var ratio: float = min(size.x / 540.0, size.y / 1080.0)
	canvas.scale = Vector2.ONE * ratio
	canvas.position = (size - Vector2(540,1080) * ratio) / 2.0

func _process(delta: float) -> void:
	if hint_seconds > 0:
		hint_seconds -= delta
		if hint_seconds <= 0: hint_cells.clear(); pending_refresh = true
	second += delta
	if second >= 1.0:
		second = 0.0
		state.tick()
		if state.jobs.size() > 0 and current_tab != "Cook":
			var ready_count: int = 0
			for i in state.jobs.size():
				if state.cooking_seconds_remaining(i) == 0: ready_count += 1
			if ready_count != int(content.get_meta("ready_count",0)): pending_refresh = true
		for timer in timers:
			if is_instance_valid(timer.label):
				var remaining: int = state.cooking_seconds_remaining(timer.job)
				timer.label.text = "Ready to plate!" if remaining <= 0 else "%ds · slow food, good mood" % remaining
				if remaining <= 0 and not timer.get("ready", false): pending_refresh = true
	if pending_refresh and not get_viewport().gui_is_dragging():
		pending_refresh = false
		_render()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if state != null: state.save_game()

func _state_changed() -> void:
	if not state.save_game(): _toast("Progress could not be saved. Check available device storage.")
	if state.get_level() > last_level:
		last_level = state.get_level()
		sfx.play("reward")
		if not reduced_motion: _burst(Vector2(483,75),GOLD)
		_toast("Chef level %d! Your new rewards are waiting." % last_level)
	last_tutorial_step = state.tutorial_step
	pending_refresh = true

func _toggle_sound() -> void:
	sfx.enabled = not sfx.enabled
	_save_preferences()

func _toggle_motion() -> void:
	reduced_motion = not reduced_motion
	_save_preferences()

func _save_preferences() -> void:
	var preferences := ConfigFile.new()
	preferences.set_value("audio","enabled",sfx.enabled)
	preferences.set_value("display","reduced_motion",reduced_motion)
	preferences.save("user://preferences.cfg")
	pending_refresh = true

func _style(bg: Color, radius: int = 18, border: Color = Color.TRANSPARENT, width: int = 0, shadow: bool = false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(radius)
	style.border_color = border
	style.set_border_width_all(width)
	if shadow:
		style.shadow_color = Color(0.18,0.29,0.20,0.07)
		style.shadow_size = 5
		style.shadow_offset = Vector2(0,3)
	return style

func _panel(parent: Node, rect: Rect2, color: Color, radius: int = 18, border: Color = Color.TRANSPARENT, border_width: int = 0) -> Panel:
	var node := Panel.new()
	node.position = rect.position
	node.size = rect.size
	node.add_theme_stylebox_override("panel", _style(color,radius,border,border_width))
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

func _label(parent: Node, text: String, rect: Rect2, size_: int = 20, color: Color = INK, serif: bool = false, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var node := Label.new()
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.add_theme_font_override("font", title_font if serif else body_font)
	node.add_theme_font_size_override("font_size", size_)
	node.add_theme_color_override("font_color", color)
	node.horizontal_alignment = align
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

func _paragraph(parent: Node, text: String, rect: Rect2, size_: int = 18, color: Color = MUTED) -> Label:
	var node := Label.new()
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.add_theme_font_override("font",body_font)
	node.add_theme_font_size_override("font_size",size_)
	node.add_theme_color_override("font_color",color)
	node.text = text
	node.position = rect.position
	node.size = rect.size
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(node)
	return node

func _icon(parent: Node, path: String, rect: Rect2, opacity: float = 1.0) -> TextureRect:
	var node := TextureRect.new()
	node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if ResourceLoader.exists(path): node.texture = load(path)
	node.position = rect.position
	node.size = rect.size
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.modulate.a = opacity
	parent.add_child(node)
	return node

func _item(parent: Node, id: String, rect: Rect2, opacity: float = 1.0) -> TextureRect:
	return _icon(parent,"res://assets/items/%s.svg" % id,rect,opacity)

func _button(parent: Node, text: String, rect: Rect2, action: Callable, bg: Color = GREEN, fg: Color = WHITE, size_: int = 18, drops: bool = false) -> Button:
	var node: Button = DropButton.new() if drops else Button.new()
	node.position = rect.position
	node.size = rect.size
	node.text = text
	node.add_theme_font_override("font",body_font)
	node.add_theme_font_size_override("font_size",size_)
	node.add_theme_color_override("font_color",fg)
	node.add_theme_color_override("font_hover_color",fg)
	node.add_theme_color_override("font_pressed_color",fg)
	node.add_theme_color_override("font_disabled_color",MUTED)
	node.add_theme_stylebox_override("normal",_style(bg,14))
	node.add_theme_stylebox_override("hover",_style(bg.lightened(0.06),14))
	node.add_theme_stylebox_override("pressed",_style(bg.darkened(0.08),14))
	node.add_theme_stylebox_override("disabled",_style(Color("e5e6db"),14))
	node.add_theme_stylebox_override("focus",_style(Color.TRANSPARENT,14,CORAL,2))
	node.pressed.connect(func(): sfx.play(); action.call())
	parent.add_child(node)
	return node

func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()

func _render() -> void:
	if graduation_pending:
		modal = "graduation"
		graduation_pending = false
	for key in active_scrolls:
		if is_instance_valid(active_scrolls[key]): scroll_positions[key] = active_scrolls[key].scroll_horizontal if key == "orders_h" else active_scrolls[key].scroll_vertical
	active_scrolls.clear()
	_clear(content)
	_clear(overlay)
	_clear(guide_layer)
	timers.clear()
	_panel(content,Rect2(0,0,540,1080),CREAM,0)
	_panel(content,Rect2(0,-30,540,192),MINT,32)
	_label(content,"A LITTLE KITCHEN. A WORLD OF FLAVOR.",Rect2(27,18,405,23),11,GREEN)
	_label(content,"Little World Kitchen",Rect2(26,43,430,51),31,INK,true)
	var helper: Button = _button(content,"",Rect2(459,26,56,56),func(): _open_modal("career"),Color("d2e3ce"))
	helper.tooltip_text = "Chef levels, goals, and the tutorial"
	_icon(helper,"res://assets/characters/chef.svg",Rect2(0,0,56,56))
	_panel(helper,Rect2(35,37,26,22),GREEN,9)
	_label(helper,str(state.get_level()),Rect2(35,37,26,22),12,WHITE,false,HORIZONTAL_ALIGNMENT_CENTER)
	_resource("energy",str(state.energy),24,112,116,func(): _open_modal("gift"))
	_resource("coin",str(state.coins),150,112,122,func(): _open_modal("market"))
	_resource("star",str(state.stars),282,112,99,func(): _switch_tab("Bistro"))
	_resource("gift","Gift",391,112,125,func(): _open_modal("gift"))
	match current_tab:
		"Kitchen": _kitchen()
		"Cook": _cooking()
		"Bistro": _restaurant()
		"Travel": _travel()
		"Book": _journal()
	_nav()
	if not modal.is_empty(): _render_modal()
	else: _tutorial_guide()
	if transition_requested and not reduced_motion:
		content.modulate.a = 0.5
		create_tween().tween_property(content,"modulate:a",1.0,0.16)
	transition_requested = false
	pop_cells.clear()
	if OS.has_feature("web"):
		# A read-only snapshot for browser diagnostics; never a gameplay input.
		var snapshot: Dictionary = {"energy":state.energy,"coins":state.coins,"stars":state.stars,"board":state.board,"inventory":state.inventory,"jobs":state.jobs,"orders":state.orders,"tab":current_tab,"modal":modal,"merges":state.total_merges,"total_orders":state.total_orders,"city":state.city_index,"renovations":state.renovations,"level":state.get_level(),"xp":state.xp,"tutorial":state.tutorial_step,"tutorial_rewarded":state.tutorial_rewarded,"capacity":state.inventory_capacity,"discovered":state.discovered,"claimed_levels":state.claimed_levels,"claimed_goals":state.claimed_goals}
		JavaScriptBridge.eval("window.__LWK_STATE = " + JSON.stringify(snapshot) + ";",true)

func _resource(icon: String, value: String, x: float, y: float, w: float, action: Callable) -> void:
	var b: Button = _button(content,"",Rect2(x,y,w,40),action,WHITE)
	_icon(b,"res://assets/icons/%s.svg" % icon,Rect2(7,5,30,30))
	_label(b,value,Rect2(42,0,w-45,40),19,INK)

func _heading(kicker: String, title: String, subtitle: String = "") -> void:
	_label(content,kicker.to_upper(),Rect2(28,176,485,24),12,GREEN)
	_label(content,title,Rect2(27,204,487,51),34,INK,true)
	if not subtitle.is_empty(): _paragraph(content,subtitle,Rect2(28,261,480,48),17,MUTED)

func _kitchen() -> void:
	var city: Dictionary = KitchenState.CITIES[state.city_index]
	_label(content,"CHAPTER %02d" % (state.city_index+1),Rect2(28,170,100,23),11,GREEN)
	_label(content,city.name,Rect2(132,166,250,33),23,INK,true)
	_button(content,"Hint ✧",Rect2(410,165,105,36),_show_hint,MINT,GREEN,13)
	_label(content,"A table full of possibilities",Rect2(28,204,380,27),18,INK)
	_label(content,"GUESTS  %d" % state.orders.size(),Rect2(410,205,106,24),10,MUTED,false,HORIZONTAL_ALIGNMENT_RIGHT)
	var orders_scroll := ScrollContainer.new()
	orders_scroll.position = Vector2(20,240)
	orders_scroll.size = Vector2(520,83)
	orders_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	orders_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	content.add_child(orders_scroll)
	active_scrolls["orders_h"] = orders_scroll
	orders_scroll.set_deferred("scroll_horizontal",int(scroll_positions.get("orders_h",0)))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",10)
	orders_scroll.add_child(row)
	for i in state.orders.size():
		var order: Dictionary = state.orders[i]
		var ready: bool = state.is_order_ready(i)
		var card := Control.new()
		card.custom_minimum_size = Vector2(156,80)
		row.add_child(card)
		var touch_target: Button = _button(card,"",Rect2(0,0,156,80),func(): _order_clicked(i),Color.TRANSPARENT)
		touch_target.tooltip_text = "%s would like %s" % [order.customer,_name(order.item)]
		_panel(card,Rect2(0,0,156,78),WHITE,17,Color("d8e4d1") if ready else Color("edeade"),1)
		_icon(card,"res://assets/characters/customer_%d.svg" % (i%7),Rect2(3,5,45,45))
		_item(card,order.item,Rect2(53,4,49,49))
		_label(card,"+%d" % int(order.coins),Rect2(104,10,48,24),14,GREEN)
		_icon(card,"res://assets/icons/coin.svg",Rect2(115,33,18,18))
		_panel(card,Rect2(7,55,142,19),GREEN if ready else MINT,8)
		_label(card,"Serve ✓" if ready else "View order",Rect2(7,55,142,19),11,WHITE if ready else GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
	_panel(content,Rect2(29,333,482,598),Color("e6eadb"),24,Color("d8dfca"),1)
	for i in 63:
		var tile = Tile.new()
		tile.position = Vector2(41+(i%7)*66,341+(i/7)*66)
		tile.size = Vector2(62,62)
		tile.configure(i,state.board[i],selected == i)
		tile.highlighted = i in _highlight_cells()
		tile.tapped.connect(_tile_tapped)
		tile.dropped.connect(_tile_dropped)
		content.add_child(tile)
		if pop_cells.has(i) and not reduced_motion: tile.call_deferred("pop")
	_detail()

func _detail() -> void:
	var item_id: String = state.board[selected] if selected >= 0 else ""
	_panel(content,Rect2(27,940,486,49),WHITE,17)
	if item_id.is_empty() or item_id == "locked":
		_icon(content,"res://assets/icons/chef.svg",Rect2(34,945,38,38))
		_label(content,"Tap a crate. Merge a little magic.",Rect2(81,941,355,25),15,INK)
		_label(content,"Drag twins together, or tap one then the other.",Rect2(81,963,405,18),10,MUTED)
		_button(content,"Bag",Rect2(445,948,59,31),func(): _open_modal("storage"),MINT,GREEN,12)
	else:
		_button(content,"",Rect2(30,941,265,46),func(): _open_modal("item",str(selected)),Color.TRANSPARENT)
		_item(content,item_id,Rect2(31,941,46,46))
		_label(content,_name(item_id),Rect2(82,942,205,23),16,INK)
		var tip: String = "Tap a matching item to merge"
		if str(KitchenState.ITEMS[item_id].next).is_empty(): tip = "Ready to serve" if KitchenState.ITEMS[item_id].chain == "dish" else "Top tier · ready to cook"
		_label(content,tip,Rect2(82,965,216,17),10,MUTED)
		var cook: Button = _button(content,"Cook",Rect2(307,948,88,32),func(): _open_modal("ingredient",item_id),GREEN,WHITE,13,true)
		cook.ingredient_dropped.connect(_ingredient_dropped)
		_button(content,"Store",Rect2(403,948,98,32),func():
			if state.store_item(selected): selected = -1
		,MINT,GREEN,13)

func _tile_tapped(index: int) -> void:
	var id: String = state.board[index]
	if id.begins_with("produce_"):
		var empty_cell: int = state.board.find("")
		if state.generate(index):
			pop_cells.assign([index,empty_cell])
			sfx.play("tap")
			_burst(Vector2(72+(index%7)*66,372+(index/7)*66),GOLD)
		return
	if id == "locked":
		_toast("Merge beside a dusty tile to open it.")
		return
	if selected == index:
		selected = -1
	elif selected >= 0:
		if not id.is_empty() and state.board[selected] != id:
			selected = index
			pending_refresh = true
			return
		var same: bool = state.board[selected] == id and not id.is_empty() and not str(KitchenState.ITEMS[id].next).is_empty()
		if state.move_or_merge(selected,index):
			selected = index
			if same:
				pop_cells.assign([index])
				sfx.play("merge")
				_burst(Vector2(72+(index%7)*66,372+(index/7)*66),GOLD)
		else: selected = index if not id.is_empty() else -1
	else:
		selected = index if not id.is_empty() else -1
	pending_refresh = true

func _tile_dropped(from: int, to: int) -> void:
	var same: bool = state.board[from] == state.board[to] and not state.board[to].is_empty() and not str(KitchenState.ITEMS[state.board[to]].next).is_empty()
	if state.move_or_merge(from,to):
		selected = to
		sfx.play("merge" if same else "tap")
		if same:
			pop_cells.assign([to])
			_burst(Vector2(72+(to%7)*66,372+(to/7)*66),GOLD)

func _ingredient_dropped(index: int) -> void:
	selected = index
	_open_modal("ingredient",state.board[index])

func _order_clicked(index: int) -> void:
	if state.is_order_ready(index):
		if state.serve_order(index):
			sfx.play("reward")
			_burst(Vector2(270,280),GOLD)
	else: _open_modal("order",str(index))

func _nav() -> void:
	_panel(content,Rect2(0,1001,540,79),WHITE,0)
	_panel(content,Rect2(0,1000,540,1),Color("e5e9dd"),0)
	var ready_count: int = 0
	for i in state.jobs.size():
		if state.cooking_seconds_remaining(i) == 0: ready_count += 1
	content.set_meta("ready_count",ready_count)
	var names: Array = ["Kitchen","Cook","Bistro","Travel","Book"]
	var icons: Array = ["chef","pan","restaurant","globe","book"]
	for i in names.size():
		var tab: String = names[i]
		var active: bool = current_tab == tab
		var b: Button = _button(content,"",Rect2(9+i*105,1008,102,63),func(): _switch_tab(tab),MINT if active else Color.TRANSPARENT,INK,14,tab == "Cook")
		if tab == "Cook": b.ingredient_dropped.connect(_ingredient_dropped)
		var path: String = "res://assets/items/pan.svg" if i == 1 else "res://assets/icons/%s.svg" % icons[i]
		_icon(b,path,Rect2(36,4,30,30),1.0 if active else 0.64)
		_label(b,tab,Rect2(0,36,102,20),12,GREEN if active else MUTED,false,HORIZONTAL_ALIGNMENT_CENTER)
		if tab == "Cook" and ready_count > 0:
			_panel(b,Rect2(63,2,23,23),CORAL,11)
			_label(b,str(ready_count),Rect2(63,2,23,23),11,WHITE,false,HORIZONTAL_ALIGNMENT_CENTER)

func _switch_tab(tab: String) -> void:
	transition_requested = current_tab != tab
	current_tab = tab
	modal = ""
	pending_refresh = true

func _scroll(parent: Node, rect: Rect2, height_: float, key: String) -> Control:
	var scroller := ScrollContainer.new()
	scroller.position = rect.position
	scroller.size = rect.size
	scroller.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroller.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	parent.add_child(scroller)
	var inner := Control.new()
	inner.custom_minimum_size = Vector2(rect.size.x-4,height_)
	scroller.add_child(inner)
	active_scrolls[key] = scroller
	scroller.set_deferred("scroll_vertical",int(scroll_positions.get(key,0)))
	return inner

func _cooking() -> void:
	_heading("A pinch of patience","Made with love","Seven little stations. A whole world of recipes.")
	var inner: Control = _scroll(content,Rect2(24,323,496,664),850,"cooking")
	var ids: Array = KitchenState.STATIONS.keys()
	for i in ids.size():
		var id: String = ids[i]
		var station: Dictionary = KitchenState.STATIONS[id]
		var x: float = (i%2)*247
		var y: float = (i/2)*210
		_panel(inner,Rect2(x,y,235,196),WHITE,23,Color("e4e8da"),1)
		_item(inner,id,Rect2(x+72,y+4,91,82))
		_label(inner,station.name,Rect2(x+10,y+80,215,30),23,INK,true,HORIZONTAL_ALIGNMENT_CENTER)
		var job_index: int = _station_job(id)
		if job_index >= 0:
			var ready: bool = state.cooking_seconds_remaining(job_index) <= 0
			var label: Label = _label(inner,"Ready to plate!" if ready else "%ds · slow food, good mood" % state.cooking_seconds_remaining(job_index),Rect2(x+7,y+112,221,23),12,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
			timers.append({"label":label,"job":job_index,"ready":ready})
			_label(inner,_name(state.jobs[job_index].output),Rect2(x+8,y+3,219,23),11,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
			_item(inner,state.jobs[job_index].output,Rect2(x+172,y+44,43,43))
			_button(inner,"Collect dish" if ready else "Boost −5s · %d left" % state.boosts,Rect2(x+13,y+145,209,42),func():
				if ready:
					if state.collect_cooking(job_index): sfx.play("reward")
				else: state.boost_cooking(job_index)
			,GREEN if ready else MINT,WHITE if ready else GREEN,12)
		else:
			_label(inner,"Ready when you are",Rect2(x+9,y+112,217,23),13,MUTED,false,HORIZONTAL_ALIGNMENT_CENTER)
			_button(inner,"Choose a recipe  +",Rect2(x+13,y+145,209,42),func(): _open_modal("station",id),MINT,GREEN,13)

func _station_job(station: String) -> int:
	for i in state.jobs.size():
		if state.jobs[i].station == station: return i
	return -1

func _restaurant() -> void:
	var city: Dictionary = KitchenState.CITIES[state.city_index]
	_heading("MAKE YOURSELF AT HOME", "%s bistro" % city.name)
	_panel(content,Rect2(22,265,496,314),Color("dbe8d3"),25)
	var room_parts: Array[String] = []
	for part in KitchenState.PARTS:
		var choice: String = state.get_renovation(part)
		room_parts.append("none" if choice.is_empty() else choice)
	var room_path: String = "res://assets/rooms/%s.svg" % "_".join(room_parts)
	_icon(content,room_path if ResourceLoader.exists(room_path) else "res://assets/restaurant.svg",Rect2(22,265,496,314))
	var renovated: int = 0
	for part in KitchenState.PARTS:
		if not state.get_renovation(part).is_empty(): renovated += 1
	# Room art reflects each independently chosen material and furniture style.
	_icon(content,"res://assets/characters/assistant.svg",Rect2(28,595,59,59))
	_paragraph(content,city.story,Rect2(101,590,410,63),15,INK)
	_label(content,"%d of 3 finishing touches · earn stars by serving guests" % renovated,Rect2(29,650,480,25),13,MUTED)
	for i in KitchenState.PARTS.size():
		var part: String = KitchenState.PARTS[i]
		var style: String = state.get_renovation(part)
		var y: float = 677+i*91
		_panel(content,Rect2(25,y,490,80),WHITE,18)
		_icon(content,"res://assets/icons/%s.svg" % ["restaurant","chef","star"][i],Rect2(36,y+13,49,49))
		_label(content,["A fresh foundation","A seat at the table","A little personality"][i],Rect2(98,y+8,275,30),19,INK)
		_label(content,("Choose " + part) if style.is_empty() else style.capitalize() + " · completed",Rect2(98,y+40,275,24),13,MUTED)
		_button(content,"%d ★" % int(KitchenState.RENOVATION_COSTS[part]) if style.is_empty() else "Restyle",Rect2(406,y+21,96,37),func(): _open_modal("renovate",part),GREEN if style.is_empty() else MINT,WHITE if style.is_empty() else GREEN,14)
	if renovated == 3:
		_button(content,"Next stop, something delicious  →",Rect2(26,953,489,33),func(): _switch_tab("Travel"),CORAL,WHITE,15)

func _travel() -> void:
	_heading("THE FLAVOR PASSPORT","A world worth tasting.","Eight little kitchens. Eight delicious new beginnings.")
	var inner: Control = _scroll(content,Rect2(25,323,493,665),KitchenState.CITIES.size()*240,"travel")
	for i in KitchenState.CITIES.size():
		var city: Dictionary = KitchenState.CITIES[i]
		var unlocked: bool = i <= state.get_unlocked_city()
		var y: float = i*240
		_panel(inner,Rect2(0,y,489,225),WHITE,23)
		_icon(inner,"res://assets/cities/%s.svg" % city.art,Rect2(0,y,489,132),1.0 if unlocked else 0.6)
		_label(inner,"%02d  %s" % [i+1,city.name],Rect2(18,y+140,330,35),27,INK,true)
		_label(inner,city.subtitle,Rect2(19,y+179,324,24),12,MUTED)
		var b: Button = _button(inner,"You’re here" if i == state.city_index else ("Visit →" if unlocked else "Locked"),Rect2(355,y+162,120,45),func():
			if state.travel(i): _switch_tab("Kitchen"); sfx.play("reward")
		,GREEN if unlocked else MINT,WHITE if unlocked else MUTED,13)
		b.disabled = not unlocked or i == state.city_index

func _journal() -> void:
	_heading("THE RECIPE NOTEBOOK","A curious appetite.","%d / %d foods discovered · follow every delicious possibility." % [state.discovered.size()-3,KitchenState.ITEMS.size()-5])
	for i in 2:
		var mode: String = ["Recipes","Ingredients"][i]
		_button(content,mode,Rect2(26+i*247,316,239,39),func(): journal_mode = mode; pending_refresh = true,GREEN if journal_mode == mode else MINT,WHITE if journal_mode == mode else GREEN,15)
	if journal_mode == "Ingredients":
		var inner: Control = _scroll(content,Rect2(25,368,493,618),KitchenState.CHAINS.size()*156,"chains")
		for i in KitchenState.CHAINS.size():
			var chain: Dictionary = KitchenState.CHAINS[i]
			var y: float = i*156
			_panel(inner,Rect2(0,y,489,142),WHITE,19)
			_label(inner,chain.name,Rect2(16,y+7,320,29),21,INK,true)
			_label(inner,"LEVEL %d" % chain.level,Rect2(371,y+10,100,23),11,GREEN,false,HORIZONTAL_ALIGNMENT_RIGHT)
			for j in 6:
				var id: String = chain.items[j]
				_item(inner,id,Rect2(8+j*80,y+40,66,66),1.0 if state.discovered.has(id) else 0.45)
				_label(inner,_name(id),Rect2(2+j*80,y+111,79,21),10,MUTED,false,HORIZONTAL_ALIGNMENT_CENTER)
	else:
		for i in 3:
			var filter: String = ["All","Ready","Unlocked"][i]
			_button(content,filter,Rect2(27+i*164,366,157,33),func(): recipe_filter = filter; pending_refresh = true,MINT if recipe_filter == filter else Color.TRANSPARENT,GREEN,13)
		var recipes: Array[Dictionary] = []
		for recipe in KitchenState.RECIPES:
			if recipe_filter == "Ready" and not state.recipe_status(recipe).is_empty(): continue
			if recipe_filter == "Unlocked" and int(recipe.level) > state.get_level(): continue
			recipes.append(recipe)
		var inner: Control = _scroll(content,Rect2(25,411,493,575),maxi(200,recipes.size()*157),"journal_"+recipe_filter)
		if recipes.is_empty(): _paragraph(inner,"A little prep first! Merge ingredients, or stop by the market for fresh supplies.",Rect2(26,20,436,130),21,MUTED)
		for i in recipes.size(): _recipe_row(inner,recipes[i],i*157,true,481)

func _name(id: String) -> String:
	return str(KitchenState.ITEMS.get(id,{}).get("name",id.capitalize().replace("_"," ")))

func _open_modal(kind: String, arg: String = "") -> void:
	modal = kind
	modal_arg = arg
	pending_refresh = true

func _close_modal() -> void:
	if modal == "welcome": state.skip_tutorial()
	modal = ""
	pending_refresh = true

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if not modal.is_empty(): _close_modal()
		else: _switch_tab("Kitchen")
		get_viewport().set_input_as_handled()

func _render_modal() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.12,0.23,0.19,0.48)
	shade.size = Vector2(540,1080)
	shade.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed: _close_modal()
	)
	overlay.add_child(shade)
	var panel: Panel = _panel(overlay,Rect2(20,210,500,760),CREAM,30)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_button(panel,"×",Rect2(438,16,43,43),_close_modal,MINT,GREEN,25)
	match modal:
		"help": _help_modal(panel)
		"storage": _storage_modal(panel)
		"gift": _gift_modal(panel)
		"renovate": _renovate_modal(panel)
		"station", "ingredient": _recipe_modal(panel)
		"order": _order_modal(panel)
		"welcome", "graduation": _welcome_modal(panel)
		"career": _career_modal(panel)
		"market": _market_modal(panel)
		"item": _item_modal(panel)

func _help_modal(panel: Control) -> void:
	_icon(panel,"res://assets/characters/chef.svg",Rect2(24,24,85,85))
	_label(panel,"Welcome, chef.",Rect2(123,39,306,51),30,INK,true)
	_paragraph(panel,"I’m Lea. Let’s turn a few little ingredients into a place people love.",Rect2(26,131,448,73),21,INK)
	var tips: Array = [["01","Pick something fresh","Tap a crate at the top of the board. Each ingredient costs 1 energy."],["02","Better together","Drag matching ingredients together, or tap one and then its twin. Merge beside dusty tiles to clear them."],["03","A little kitchen magic","Select an ingredient and tap Cook. Choose a recipe, wait a moment, then collect your dish."],["04","Make someone’s day","Serve a ready guest to earn coins and stars. Spend stars in the Bistro, then travel somewhere new."]]
	for i in tips.size():
		var y: float = 220+i*106
		_label(panel,tips[i][0],Rect2(27,y,48,40),25,CORAL,true)
		_label(panel,tips[i][1],Rect2(87,y,378,28),20,INK)
		_paragraph(panel,tips[i][2],Rect2(87,y+29,374,66),15,MUTED)
	_button(panel,"Sound: on" if sfx.enabled else "Sound: off",Rect2(27,676,187,48),_toggle_sound,MINT,GREEN,16)
	_button(panel,"Replay tutorial",Rect2(227,676,247,48),func(): _open_modal("welcome"),GREEN,WHITE,16)
	_button(panel,"Gentle motion: on" if reduced_motion else "Gentle motion: off",Rect2(29,626,442,36),_toggle_motion,MINT,GREEN,14)

func _storage_modal(panel: Control) -> void:
	_label(panel,"A little room for later",Rect2(25,31,400,49),29,INK,true)
	_paragraph(panel,"Tap an ingredient to bring it back. Expand your pantry in the coin market.",Rect2(26,96,443,67),17,MUTED)
	_label(panel,"PANTRY  ·  %d / %d" % [state.inventory.size(),state.inventory_capacity],Rect2(28,182,436,29),13,GREEN)
	var inner: Control = _scroll(panel,Rect2(22,223,458,382),ceil(state.inventory_capacity/5.0)*99,"storage")
	for i in state.inventory_capacity:
		var x: float = 6+(i%5)*89
		var y: float = (i/5)*99
		_panel(inner,Rect2(x,y,81,91),MINT,17)
		if i < state.inventory.size():
			var b: Button = _button(inner,"",Rect2(x,y,81,91),func(): state.restore_item(i),WHITE)
			_item(b,state.inventory[i],Rect2(7,5,65,65))
			_label(b,"Return ↗",Rect2(0,67,81,20),11,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
		else: _label(inner,"+",Rect2(x,y,81,91),25,Color("b8c9b1"),false,HORIZONTAL_ALIGNMENT_CENTER)
	_button(panel,"Grow my pantry  →",Rect2(28,625,444,43),func(): _open_modal("market"),MINT,GREEN)
	_button(panel,"Back to the kitchen",Rect2(28,684,444,48),_close_modal)

func _gift_modal(panel: Control) -> void:
	_label(panel,"A gift for your apron",Rect2(25,37,418,54),30,INK,true)
	_icon(panel,"res://assets/icons/gift.svg",Rect2(164,130,172,172))
	_label(panel,"A fresh start, every day.",Rect2(26,329,448,46),27,INK,true,HORIZONTAL_ALIGNMENT_CENTER)
	_paragraph(panel,"A little energy, a few coins, and cooking boosts. Just a thank-you for stopping by.",Rect2(40,387,420,72),19,MUTED)
	_panel(panel,Rect2(43,486,414,82),MINT,20)
	_label(panel,"Your daily kitchen care package",Rect2(53,505,394,42),20,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
	var claim: Button = _button(panel,"Unwrap today’s gift" if state.can_claim_daily() else "See you tomorrow!",Rect2(42,614,416,59),func():
		if state.claim_daily(): sfx.play("reward"); _close_modal()
	,CORAL,WHITE,20)
	claim.disabled = not state.can_claim_daily()
	_label(panel,"Energy also refills naturally while you’re away.",Rect2(31,699,438,29),12,MUTED,false,HORIZONTAL_ALIGNMENT_CENTER)

func _recipe_modal(panel: Control) -> void:
	var title: String = "What shall we make?"
	if modal == "station": title = str(KitchenState.STATIONS[modal_arg].name)
	_label(panel,title,Rect2(25,33,408,49),30,INK,true)
	_paragraph(panel,"Gather your ingredients. Let’s make something lovely.",Rect2(27,96,437,55),18,MUTED)
	var recipes: Array = []
	for recipe in KitchenState.RECIPES:
		if (modal == "station" and recipe.station == modal_arg) or (modal == "ingredient" and recipe.input == modal_arg): recipes.append(recipe)
	if recipes.is_empty():
		_item(panel,modal_arg,Rect2(176,198,146,146))
		_paragraph(panel,"This ingredient needs a little more growing. Merge it with a twin to reach the next tier, or serve it to a guest.",Rect2(36,385,430,142),23,INK)
		_button(panel,"See ingredient chains",Rect2(32,631,437,59),func(): _switch_tab("Book"))
	else:
		var inner: Control = _scroll(panel,Rect2(14,176,473,470),recipes.size()*157,"recipes")
		for i in recipes.size():
			_recipe_row(inner,recipes[i],i*157,true)
		_label(panel,"Cooking keeps going while you explore.",Rect2(26,671,447,38),15,MUTED,false,HORIZONTAL_ALIGNMENT_CENTER)

func _recipe_row(parent: Node, recipe: Dictionary, y: float, actionable: bool, width_override: float = 0.0) -> void:
	var width_: float = width_override if width_override > 0 else 458.0
	_panel(parent,Rect2(0,y,width_,145),WHITE,18)
	_label(parent,_name(recipe.out),Rect2(13,y+7,width_-99,29),19,INK)
	_label(parent,"LV %d" % recipe.level,Rect2(width_-67,y+10,50,23),11,GREEN,false,HORIZONTAL_ALIGNMENT_RIGHT)
	_item(parent,recipe.input,Rect2(13,y+40,45,45))
	var extra: String = recipe.extra
	if not extra.is_empty():
		_label(parent,"+",Rect2(59,y+46,20,27),16,MUTED)
		_item(parent,extra,Rect2(78,y+40,45,45))
	_label(parent,"→",Rect2(128,y+47,26,28),22,MUTED)
	_item(parent,recipe.out,Rect2(158,y+37,53,53))
	_label(parent,KitchenState.STATIONS[recipe.station].name,Rect2(233,y+43,width_-244,25),14,GREEN)
	_label(parent,"%d seconds" % int(recipe.duration),Rect2(234,y+68,width_-245,19),11,MUTED)
	if actionable:
		var reason: String = state.recipe_status(recipe)
		var ready: bool = reason.is_empty()
		var b: Button = _button(parent,"Cook with " + _name(recipe.input) if ready else reason,Rect2(10,y+98,width_-20,38),func():
			var index: int = selected if selected >= 0 and state.board[selected] == recipe.input else state.board.find(recipe.input)
			if state.start_cooking(index,recipe.id):
				selected = -1
				sfx.play("cook")
				_switch_tab("Cook")
		,GREEN if ready else MINT,WHITE if ready else MUTED,14)
		b.disabled = not ready

func _renovate_modal(panel: Control) -> void:
	_label(panel,"A style that’s yours",Rect2(25,34,402,50),30,INK,true)
	_paragraph(panel,"Choose a look for your %s. Every detail makes this place feel more like you." % modal_arg,Rect2(28,98,438,75),18,MUTED)
	var styles: Array = ["sage","sunshine","rose"]
	var captions: Array = ["Leafy greens & warm oak","Peachy mornings & golden light","Soft pinks & little daydreams"]
	var colors: Array = [Color("c8dbb6"),Color("efc4a5"),Color("bdd9df")]
	for i in 3:
		var y: float = 211+i*139
		_panel(panel,Rect2(26,y,447,123),colors[i],23)
		_icon(panel,"res://assets/icons/restaurant.svg",Rect2(40,y+17,73,79))
		_label(panel,styles[i].capitalize(),Rect2(129,y+16,315,36),26,INK,true)
		_label(panel,captions[i],Rect2(129,y+54,315,24),14,INK)
		var chosen: String = styles[i]
		_button(panel,"Choose this look  →",Rect2(129,y+80,320,36),func():
			if state.renovate(modal_arg,chosen):
				sfx.play("reward")
				_close_modal()
		,GREEN,WHITE,13)
	_label(panel,"%d stars to renovate · restyling is free" % int(KitchenState.RENOVATION_COSTS[modal_arg]),Rect2(27,662,444,43),16,MUTED,false,HORIZONTAL_ALIGNMENT_CENTER)

func _order_modal(panel: Control) -> void:
	var index: int = int(modal_arg)
	if index >= state.orders.size(): return
	var order: Dictionary = state.orders[index]
	_icon(panel,"res://assets/characters/customer_%d.svg" % (index%7),Rect2(183,57,131,131))
	_label(panel,"A little something for %s" % order.customer,Rect2(19,206,462,58),25,INK,true,HORIZONTAL_ALIGNMENT_CENTER)
	_item(panel,order.item,Rect2(180,286,140,140))
	_label(panel,_name(order.item),Rect2(28,439,441,43),30,INK,true,HORIZONTAL_ALIGNMENT_CENTER)
	var recipe: Dictionary = {}
	for candidate in KitchenState.RECIPES:
		if candidate.out == order.item: recipe = candidate; break
	var hint: String = "Find this ingredient by merging matching items. The recipe book shows every chain."
	if not recipe.is_empty(): hint = "Make it with %s%s in the %s." % [_name(recipe.input),(" + " + _name(recipe.extra)) if not str(recipe.extra).is_empty() else "",KitchenState.STATIONS[recipe.station].name]
	_paragraph(panel,hint,Rect2(43,506,414,90),19,MUTED)
	_label(panel,"Your reward: %d coins + %d stars" % [int(order.coins),int(order.stars)],Rect2(28,602,444,35),18,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
	_button(panel,"Open recipe notebook",Rect2(33,665,435,57),func(): _switch_tab("Book"))

func _toast(message: String) -> void:
	if not is_instance_valid(toast_layer): return
	toast_serial += 1
	if toast_tween != null and toast_tween.is_valid(): toast_tween.kill()
	_clear(toast_layer)
	var box: Panel = _panel(toast_layer,Rect2(25,162,490,43),GREEN,20)
	var label: Label = _paragraph(box,message,Rect2(14,4,462,35),13,WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.modulate.a = 0.0
	var tween: Tween = create_tween()
	toast_tween = tween
	tween.tween_property(box,"modulate:a",1.0,0.16)
	tween.tween_interval(1.6)
	tween.tween_property(box,"modulate:a",0.0,0.35)
	tween.tween_callback(box.queue_free)

func _burst(at: Vector2, color: Color) -> void:
	if reduced_motion: return
	for i in 12:
		var star: Label = _label(canvas,"✦" if i%2 == 0 else "•",Rect2(at-Vector2(10,10),Vector2(20,20)),22,color)
		var angle: float = TAU*i/12.0
		var target: Vector2 = at+Vector2(cos(angle),sin(angle))*randf_range(38,79)-Vector2(10,10)
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(star,"position",target,0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(star,"modulate:a",0.0,0.55)
		tween.chain().tween_callback(star.queue_free)

func _progress(parent: Node, at: Rect2, value: int, maximum: int, color: Color = GREEN) -> void:
	_panel(parent,at,MINT,6)
	if value > 0: _panel(parent,Rect2(at.position,Vector2(at.size.x*clampf(float(value)/maxi(1,maximum),0.0,1.0),at.size.y)),color,6)

func _show_hint() -> void:
	hint_cells = state.find_merge()
	hint_seconds = 5.0
	pending_refresh = true
	_toast("These two belong together. Follow the golden tiles!" if not hint_cells.is_empty() else "No twins yet. Tap a supplier, or cook with what you have.")

func _highlight_cells() -> Array[int]:
	if not hint_cells.is_empty(): return hint_cells
	if not modal.is_empty(): return []
	match state.tutorial_step:
		1: return [0,1,2]
		2: return state.find_merge()
		3:
			for recipe in KitchenState.RECIPES:
				if state.recipe_status(recipe).is_empty(): return [state.board.find(recipe.input)]
	return []

func _tutorial_guide() -> void:
	if state.tutorial_step < 1 or state.tutorial_step > 6: return
	var titles: Array[String] = ["", "Fresh starts here", "Better together", "A little kitchen magic", "Good things take a moment", "Make someone’s day", "A place to call your own"]
	var tips: Array[String] = ["", "Tap a glowing basket to make an ingredient. It costs just one energy.", "Drag matching foods together, or tap one and then its twin. Look for the golden tiles!", "Select an ingredient, tap Cook, and choose a recipe. The banana makes a lovely smoothie.", "Open Cook. When a station says Ready, tap Collect dish. Your food will wait for you.", "Return to Kitchen. Tap a green Serve card to give a guest their food and earn stars.", "Visit the Bistro. Choose a room detail and a style, then spend your stars to make it yours."]
	var y: float = 812.0 if current_tab != "Bistro" else 430.0
	var panel: Panel = _panel(guide_layer,Rect2(24,y,492,116),WHITE,20,CORAL,2)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_icon(panel,"res://assets/characters/assistant.svg",Rect2(10,19,60,64))
	_label(panel,"%d / 6  ·  %s" % [state.tutorial_step,titles[state.tutorial_step]],Rect2(79,8,367,26),15,INK)
	_paragraph(panel,tips[state.tutorial_step],Rect2(80,35,393,54),13,MUTED)
	_button(panel,"×",Rect2(452,5,31,26),func(): state.skip_tutorial(),MINT,GREEN,17)
	_button(panel,"Show me →",Rect2(358,87,116,23),_tutorial_show_me,MINT,GREEN,11)
	for i in 6: _panel(panel,Rect2(81+i*18,99,11,5),CORAL if i < state.tutorial_step else MINT,3)

func _tutorial_show_me() -> void:
	match state.tutorial_step:
		1, 2: _switch_tab("Kitchen")
		3:
			for recipe in KitchenState.RECIPES:
				if state.recipe_status(recipe).is_empty():
					selected = state.board.find(recipe.input)
					_open_modal("ingredient",recipe.input)
					return
			_switch_tab("Kitchen")
			_show_hint()
		4: _switch_tab("Cook")
		5: _switch_tab("Kitchen")
		6: _switch_tab("Bistro")

func _welcome_modal(panel: Control) -> void:
	var finished: bool = modal == "graduation"
	_label(panel,"You’re a natural, chef." if finished else "Your apron is waiting.",Rect2(25,38,412,49),29,INK,true)
	_icon(panel,"res://assets/cities/new_york.svg",Rect2(15,113,470,195))
	_panel(panel,Rect2(193,223,115,115),CREAM,58)
	_icon(panel,"res://assets/characters/assistant.svg",Rect2(201,228,99,103))
	_label(panel,"A little help from Lea",Rect2(30,367,440,43),26,INK,true,HORIZONTAL_ALIGNMENT_CENTER)
	_paragraph(panel,"You’ve merged, cooked, served, and made a little place your own. Eight cities and a notebook full of recipes are waiting for you." if finished else "Welcome to your very own world kitchen. I’ll show you how to turn a few little ingredients into food, friendships, and a beautiful café.",Rect2(36,427,427,120),21,INK)
	_label(panel,"Your pace. Your place. No rush.",Rect2(28,569,444,36),17,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
	_button(panel,"Let’s explore!" if finished else "Let’s cook!",Rect2(30,643,284,57),func():
		if not finished: state.start_tutorial()
		_switch_tab("Kitchen")
	,GREEN,WHITE,21)
	_button(panel,"Later" if finished else "Skip guide",Rect2(328,648,142,47),func(): state.skip_tutorial(); _close_modal(),MINT,GREEN,15)

func _career_modal(panel: Control) -> void:
	_icon(panel,"res://assets/icons/medal.svg",Rect2(24,30,78,86))
	_label(panel,"Chef level %d" % state.get_level(),Rect2(115,35,302,49),31,INK,true)
	_button(panel,"Guide & settings",Rect2(118,92,235,32),func(): _open_modal("help"),MINT,GREEN,14)
	var xp_value: int = 100 if state.get_level() == KitchenState.MAX_LEVEL else state.xp % 100
	_progress(panel,Rect2(28,150,444,10),xp_value,100)
	_label(panel,"World-class chef!" if state.get_level() == KitchenState.MAX_LEVEL else "%d / 100 XP to your next level" % xp_value,Rect2(28,168,444,26),14,MUTED)
	var pending: int = state.pending_level_rewards()
	_button(panel,"Claim %d level rewards  ✦" % pending if pending > 0 else "Keep cooking. Good things are coming.",Rect2(28,208,444,43),func():
		if state.claim_level_rewards(): sfx.play("reward")
	,GREEN if pending > 0 else MINT,WHITE if pending > 0 else MUTED,15).disabled = pending == 0
	for i in 2:
		var mode: String = ["Goals","Chef levels"][i]
		_button(panel,mode,Rect2(28+i*228,270,217,34),func(): career_mode = mode; pending_refresh = true,GREEN if career_mode == mode else MINT,WHITE if career_mode == mode else GREEN,14)
	if career_mode == "Goals":
		var inner: Control = _scroll(panel,Rect2(23,322,460,408),KitchenState.GOALS.size()*115,"goals")
		for i in KitchenState.GOALS.size():
			var goal: Dictionary = KitchenState.GOALS[i]
			var y: float = i*115
			var value: int = state.goal_progress(goal)
			var claimed: bool = state.claimed_goals.has(goal.id)
			_panel(inner,Rect2(0,y,449,105),WHITE,17)
			_label(inner,goal.title,Rect2(13,y+8,425,26),18,INK)
			_progress(inner,Rect2(15,y+44,270,7),value,goal.target)
			_label(inner,"%d / %d  ·  +%d coins, %d stars" % [mini(value,goal.target),goal.target,goal.coins,goal.stars],Rect2(14,y+66,313,23),12,MUTED)
			_button(inner,"Done ✓" if claimed else "Claim",Rect2(336,y+55,98,36),func():
				if state.claim_goal(goal.id): sfx.play("reward")
			,MINT if claimed else GREEN,GREEN if claimed else WHITE,13).disabled = claimed or value < int(goal.target)
	else:
		var inner: Control = _scroll(panel,Rect2(23,322,460,408),20*84,"levels")
		for i in 20:
			var level: int = i+1
			var y: float = i*84
			_panel(inner,Rect2(0,y,449,75),WHITE if level <= state.get_level() else MINT,17)
			_label(inner,"%02d" % level,Rect2(16,y+10,56,49),31,CORAL if level <= state.get_level() else MUTED,true)
			var title: String = {1:"Your first little kitchen",2:"Fresh new recipes",3:"The fish market opens",4:"More flavor, more possibilities",5:"The patisserie opens",6:"A confident kitchen",7:"Special occasion dishes",8:"The full recipe collection",10:"Neighborhood favorite",15:"A taste of the world",20:"World-class chef"}.get(level,"Growing your chef story")
			_label(inner,title,Rect2(84,y+8,350,29),16,INK)
			_label(inner,"Welcome, chef!" if level == 1 else "+%d coins · 10 energy · 1 boost" % (level*25),Rect2(84,y+43,350,23),12,MUTED)

func _market_modal(panel: Control) -> void:
	_label(panel,"The little market",Rect2(25,31,400,49),30,INK,true)
	_label(panel,"%d coins  ·  %d / 100 energy" % [state.coins,state.energy],Rect2(28,90,414,31),17,GREEN)
	for i in KitchenState.CHAINS.size():
		var chain: Dictionary = KitchenState.CHAINS[i]
		var unlocked: bool = state.get_level() >= int(chain.level)
		var y: float = 139+i*81
		var b: Button = _button(panel,"",Rect2(24,y,452,72),func():
			if state.generate_from(chain.generator): sfx.play("tap")
		,WHITE)
		b.disabled = not unlocked
		_item(b,chain.generator,Rect2(7,3,63,63),1.0 if unlocked else 0.4)
		_label(b,chain.name,Rect2(85,9,263,29),20,INK,true)
		_label(b,"Tap for fresh ingredients" if unlocked else "Opens at chef level %d" % chain.level,Rect2(86,42,288,20),12,MUTED)
		_label(b,"1 ⚡" if unlocked else "LV %d" % chain.level,Rect2(365,19,78,31),16,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
	_label(panel,"A FEW LITTLE EXTRAS",Rect2(29,558,443,24),11,GREEN)
	var kinds: Array = ["energy","boost","storage"]
	var names: Array = ["30 energy","3 boosts","+1 slot"]
	var prices: Array = [120,75,250]
	for i in 3:
		var b: Button = _button(panel,"",Rect2(27+i*152,596,140,117),func():
			if state.buy_supply(kinds[i]): sfx.play("reward")
		,MINT)
		_icon(b,"res://assets/icons/%s.svg" % ["energy","star","bag"][i],Rect2(52,7,36,36))
		_label(b,names[i],Rect2(2,46,136,27),16,INK,false,HORIZONTAL_ALIGNMENT_CENTER)
		_label(b,"%d coins" % prices[i],Rect2(2,83,136,23),13,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)

func _item_modal(panel: Control) -> void:
	var index: int = int(modal_arg)
	if not state.can_move(index): _close_modal(); return
	var id: String = state.board[index]
	_label(panel,_name(id),Rect2(25,35,400,49),29,INK,true)
	_item(panel,id,Rect2(164,140,173,173))
	var next: String = KitchenState.ITEMS[id].next
	if not next.is_empty():
		_label(panel,"Two of these become…",Rect2(26,334,448,38),23,INK,true,HORIZONTAL_ALIGNMENT_CENTER)
		_item(panel,next,Rect2(202,386,95,95))
		_label(panel,_name(next),Rect2(30,480,440,33),18,GREEN,false,HORIZONTAL_ALIGNMENT_CENTER)
	else: _paragraph(panel,"A beautiful finished ingredient. Cook something special, serve a guest, or save it for later.",Rect2(36,350,430,139),22,INK)
	_button(panel,"Find recipes",Rect2(28,555,444,50),func(): _open_modal("ingredient",id))
	_button(panel,"Store for later",Rect2(28,617,444,43),func():
		if state.store_item(index): selected = -1; _close_modal()
	,MINT,GREEN)
	_button(panel,"Sell this item · %d coins" % (int(KitchenState.ITEMS[id].tier)*2),Rect2(28,672,444,43),func():
		if state.sell_item(index): selected = -1; _close_modal()
	,Color("f3e4d7"),Color("9e6d50"),15)
