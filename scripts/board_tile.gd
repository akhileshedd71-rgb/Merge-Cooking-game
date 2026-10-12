class_name BoardTile
extends Control
## A small, touch-friendly ingredient tile. The board owns all game rules.

signal tapped(index: int)
signal dropped(from: int, to: int)
signal hovered(index: int)

var index: int = -1
var item_id: String = "":
	set(value):
		item_id = value
		_update_description()
		queue_redraw()
var selected: bool = false:
	set(value):
		selected = value
		queue_redraw()
var highlighted: bool = false:
	set(value):
		highlighted = value
		queue_redraw()

static var _textures: Dictionary = {}
var _pressed: bool = false
var _dragging: bool = false
var _glow: float = 0.0
var _pop_tween: Tween
var _label_font: Font


func _ready() -> void:
	custom_minimum_size = Vector2(56.0, 56.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_label_font = ThemeDB.fallback_font
	if ResourceLoader.exists("res://assets/fonts/Quicksand.ttf"):
		_label_font = load("res://assets/fonts/Quicksand.ttf") as Font
	mouse_entered.connect(_on_mouse_entered)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)
	resized.connect(_on_resized)
	_on_resized()
	_update_description()


func configure(index_: int, item_id_: String, selected_: bool = false) -> void:
	index = index_
	item_id = item_id_
	selected = selected_
	queue_redraw()


func _on_resized() -> void:
	pivot_offset = size * 0.5
	queue_redraw()


func _on_mouse_entered() -> void:
	hovered.emit(index)


func _info() -> Dictionary:
	return KitchenState.ITEMS.get(item_id, {})


func _is_generator() -> bool:
	return item_id.begins_with("produce_")


func _update_description() -> void:
	# Emulated touch must not leave a desktop hover tooltip over the board.
	if DisplayServer.is_touchscreen_available():
		tooltip_text = ""
		return
	if item_id.is_empty():
		tooltip_text = "Empty space · move an ingredient here"
	elif item_id == "locked":
		tooltip_text = "Dusty space · merge beside it to clear it"
	else:
		var info: Dictionary = _info()
		var display_name: String = str(info.get("name", item_id.capitalize()))
		if _is_generator():
			tooltip_text = display_name + " · tap to discover an ingredient"
		else:
			tooltip_text = "%s · Level %d · drag onto a matching ingredient" % [display_name, int(info.get("tier", 1))]


func _gui_input(event: InputEvent) -> void:
	# Touch is translated to mouse by the project. Handling both event families
	# here would spend energy twice for a single tap on a phone.
	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if button.button_index != MOUSE_BUTTON_LEFT:
			return
		if button.pressed:
			_pressed = true
			_dragging = false
			grab_focus()
		else:
			if _pressed and not _dragging and Rect2(Vector2.ZERO, size).has_point(button.position):
				tapped.emit(index)
			_pressed = false
		accept_event()
	elif event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		if key.pressed and not key.echo and (key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER or key.keycode == KEY_SPACE):
			tapped.emit(index)
			accept_event()


func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_id.is_empty() or item_id == "locked" or _is_generator():
		return null
	_dragging = true
	var texture: Texture2D = _item_texture()
	var preview: Control = Control.new()
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon: TextureRect = TextureRect.new()
	icon.texture = texture
	icon.position = Vector2(-32.0, -40.0)
	icon.size = Vector2(64.0, 64.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.modulate = Color(1.0, 1.0, 1.0, 0.94)
	preview.add_child(icon)
	set_drag_preview(preview)
	return {"board_index": index}


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if item_id == "locked" or _is_generator() or not data is Dictionary:
		return false
	var payload: Dictionary = data as Dictionary
	return payload.has("board_index") and payload["board_index"] is int and int(payload["board_index"]) != index


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var payload: Dictionary = data as Dictionary
	dropped.emit(int(payload["board_index"]), index)


func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		_pressed = false
		_dragging = false
		queue_redraw()


func pop() -> void:
	if _pop_tween != null and _pop_tween.is_valid():
		_pop_tween.kill()
	scale = Vector2(0.84, 0.88)
	_glow = 0.7
	_pop_tween = create_tween()
	_pop_tween.set_parallel(true)
	_pop_tween.tween_property(self, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_pop_tween.tween_method(_set_glow, 0.7, 0.0, 0.45)


func _set_glow(value: float) -> void:
	_glow = value
	queue_redraw()


func _item_texture() -> Texture2D:
	var asset: String = str(_info().get("icon", item_id))
	if not asset.begins_with("res://"):
		asset = "res://assets/items/" + asset
		if not asset.ends_with(".svg") and not asset.ends_with(".png"):
			asset += ".svg"
	if _textures.has(asset):
		return _textures[asset] as Texture2D
	if ResourceLoader.exists(asset):
		var texture: Texture2D = load(asset) as Texture2D
		_textures[asset] = texture
		return texture
	return null


func _box(rect: Rect2, fill: Color, border: Color = Color.TRANSPARENT, width: int = 0, radius: int = 11) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(radius)
	style.anti_aliasing = true
	draw_style_box(style, rect)


func _draw() -> void:
	var bounds: Rect2 = Rect2(Vector2(1.0, 1.0), size - Vector2(2.0, 3.0))
	var center: Vector2 = bounds.get_center()
	var alternate: bool = (index + int(index / 7)) % 2 == 0
	var base: Color = Color("e9eee5") if alternate else Color("f1f2e9")
	if item_id == "locked":
		base = Color("d8ddcd")
	elif _is_generator():
		base = Color("dce7bd")
	elif highlighted:
		base = Color("ecedbc")
	_box(Rect2(bounds.position + Vector2(0.0, 2.0), bounds.size), Color(0.24, 0.34, 0.22, 0.12))
	_box(bounds, base, Color(1.0, 1.0, 0.97, 0.78), 1)
	if _glow > 0.0:
		_box(bounds, Color(1.0, 0.92, 0.59, _glow))
	if selected or has_focus():
		_box(bounds.grow(-0.5), Color.TRANSPARENT, Color("cb753e") if selected else Color("85a280"), 2)
	elif highlighted:
		_box(bounds.grow(-0.5), Color.TRANSPARENT, Color("c4ae61"), 2)
	if item_id.is_empty():
		draw_circle(center, 1.8, Color(0.4, 0.5, 0.37, 0.10))
		return
	if item_id == "locked":
		_draw_locked(center)
		return

	# Every ingredient keeps its own SVG aspect ratio inside a generous hit area.
	var icon: Texture2D = _item_texture()
	if icon != null:
		var art_size: Vector2 = icon.get_size()
		var limit: float = minf(size.x, size.y) - 8.0
		var ratio: float = minf(limit / art_size.x, limit / art_size.y)
		var rendered_size: Vector2 = art_size * ratio
		draw_set_transform(center + Vector2(0.0, limit * 0.32), 0.0, Vector2(1.0, 0.22))
		draw_circle(Vector2.ZERO, limit * 0.28, Color(0.32, 0.37, 0.22, 0.09))
		draw_set_transform(Vector2.ZERO)
		draw_texture_rect(icon, Rect2(center - rendered_size * 0.5 - Vector2(0.0, 1.0), rendered_size), false)
	else:
		# Keeps a usable tile during the first asset import or for future content.
		draw_circle(center, minf(size.x, size.y) * 0.23, Color("b8ca97"))
		var initial: String = str(_info().get("name", item_id)).left(1).to_upper()
		_draw_centered_text(initial, center + Vector2(0.0, 6.0), 20, Color("425845"))
	if _is_generator():
		_draw_generator_pip(Vector2(size.x - 12.0, size.y - 12.0))
	else:
		var tier: int = int(_info().get("tier", 1))
		var pip: Vector2 = Vector2(size.x - 10.0, size.y - 10.0)
		draw_circle(pip, 6.7, Color("fbf9ee"))
		draw_arc(pip, 6.7, 0.0, TAU, 24, Color(0.53, 0.60, 0.45, 0.25), 1.0, true)
		_draw_centered_text(str(tier), pip + Vector2(0.0, 3.6), 10, Color("677b54"))


func _draw_centered_text(value: String, baseline: Vector2, font_size: int, color: Color) -> void:
	var font: Font = _label_font if _label_font != null else ThemeDB.fallback_font
	var width: float = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	draw_string(font, baseline - Vector2(width * 0.5, 0.0), value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)


func _draw_generator_pip(at: Vector2) -> void:
	draw_circle(at, 8.5, Color("f8edab"))
	draw_arc(at, 8.5, 0.0, TAU, 24, Color("e2cd77"), 1.0, true)
	var lightning: PackedVector2Array = PackedVector2Array([
		at + Vector2(0.0, -6.0), at + Vector2(-4.0, 1.0),
		at + Vector2(-0.6, 1.0), at + Vector2(-1.5, 6.0),
		at + Vector2(4.0, -1.0), at + Vector2(0.5, -1.0),
	])
	draw_colored_polygon(lightning, Color("a87632"))


func _draw_locked(center: Vector2) -> void:
	var dust: Color = Color(0.63, 0.66, 0.54, 0.36)
	draw_line(Vector2(9.0, 12.0), Vector2(18.0, 10.0), dust, 2.0, true)
	draw_line(Vector2(size.x - 18.0, size.y - 10.0), Vector2(size.x - 10.0, size.y - 12.0), dust, 2.0, true)
	draw_circle(Vector2(size.x - 11.0, 13.0), 1.5, dust)
	draw_circle(Vector2(12.0, size.y - 13.0), 1.2, dust)
	var texture: Texture2D = _item_texture()
	if texture != null:
		draw_texture_rect(texture, Rect2(center - Vector2(16.0, 16.0), Vector2(32.0, 32.0)), false, Color(1.0, 1.0, 1.0, 0.58))
	else:
		var lock_color: Color = Color("98a48b")
		draw_arc(center - Vector2(0.0, 3.0), 6.0, PI, TAU, 18, lock_color, 3.0, true)
		_box(Rect2(center + Vector2(-9.0, -3.0), Vector2(18.0, 14.0)), lock_color, Color.TRANSPARENT, 0, 4)
		draw_circle(center + Vector2(0.0, 2.0), 1.8, Color("d8ddcd"))
		draw_line(center + Vector2(0.0, 3.0), center + Vector2(0.0, 6.0), Color("d8ddcd"), 2.0, true)
