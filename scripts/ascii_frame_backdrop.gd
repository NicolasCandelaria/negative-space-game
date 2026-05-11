extends RichTextLabel

## Uniform ASCII frame: consistent border glyphs, smooth edge shading, sparse structured interior.

@export var frame_title: String = "STORAGE ROOM"
@export_range(10, 24) var char_rows: int = 15
@export_range(40, 80) var char_cols: int = 64
@export var title_row: int = 2

## 0 storage 1 garage 2 apartment 3 hospital 4 lighthouse 5 subway 6 power 7 house
@export var palette_id: int = 0


func _ready() -> void:
	bbcode_enabled = true
	scroll_active = false
	fit_content = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	context_menu_enabled = false
	shortcut_keys_enabled = false
	var sf := SystemFont.new()
	sf.font_names = ["Consolas", "Courier New", "monospace"]
	add_theme_font_override("normal_font", sf)
	add_theme_font_size_override("normal_font_size", 14)
	text = _build_frame()


func _build_frame() -> String:
	var grid: Array[PackedStringArray] = []
	grid.resize(char_rows)
	for y in char_rows:
		var row := PackedStringArray()
		row.resize(char_cols)
		for x in char_cols:
			row[x] = _pick_char(x, y)
		grid[y] = row

	var title_cells: Dictionary = {}
	var t := frame_title.strip_edges().to_upper()
	var inner_w := char_cols - 2
	if t.length() > inner_w:
		t = t.substr(0, inner_w)
	var pad := inner_w - t.length()
	var left_pad := pad / 2
	var tr := clampi(title_row, 1, char_rows - 2)
	for i in t.length():
		var cx := 1 + left_pad + i
		grid[tr][cx] = t[i]
		title_cells[Vector2i(cx, tr)] = true

	var lines: PackedStringArray = []
	for y in char_rows:
		var row_s := ""
		for x in char_cols:
			var ch: String = grid[y][x]
			var is_title: bool = title_cells.has(Vector2i(x, y))
			var col := _pick_color(x, y, ch, is_title)
			row_s += "[color=#" + col.to_html(false) + "]" + _bb_esc(ch) + "[/color]"
		lines.append(row_s)
	var out := ""
	for i in lines.size():
		if i > 0:
			out += "\n"
		out += lines[i]
	return out


func _bb_esc(ch: String) -> String:
	if ch == "[":
		return "[["
	return ch


func _pick_char(x: int, y: int) -> String:
	if (x == 0 or x == char_cols - 1) and (y == 0 or y == char_rows - 1):
		return "+"
	if y == 0 or y == char_rows - 1:
		return "#"
	if x == 0 or x == char_cols - 1:
		return "|"
	# Interior: mostly empty; one faint vertical guide + rare dots on a fixed grid
	if x == char_cols / 2 and (y + y / 3) % 2 == 0:
		return ":"
	if (x * 5 + y * 7) % 17 == 0 and (x + y) % 2 == 0:
		return "."
	return " "


func _edge_shade(x: int, y: int) -> float:
	if y == 0:
		return float(x) / float(maxi(1, char_cols - 1))
	if y == char_rows - 1:
		return float(char_cols - 1 - x) / float(maxi(1, char_cols - 1))
	if x == 0:
		return float(y) / float(maxi(1, char_rows - 1))
	if x == char_cols - 1:
		return float(char_rows - 1 - y) / float(maxi(1, char_rows - 1))
	return 0.5


func _pick_color(x: int, y: int, ch: String, is_title: bool) -> Color:
	var base := _palette_base()
	var edge := x == 0 or x == char_cols - 1 or y == 0 or y == char_rows - 1

	if is_title:
		var gold := Color(0.92, 0.86, 0.48, 1.0)
		return base.lightened(0.48).lerp(gold, 0.35)

	if edge:
		var sh := _edge_shade(x, y)
		var stone_a := base.darkened(0.12)
		var stone_b := base.lightened(0.18)
		return stone_a.lerp(stone_b, sh * 0.85)

	# Interior: nearly flat with tiny horizontal drift
	var drift := float(x) / float(maxi(1, char_cols)) * 0.04
	var c := base.darkened(0.52)
	c = c.lightened(drift)
	if ch == ":":
		c = c.lightened(0.08)
	elif ch == ".":
		c = c.lightened(0.05)
	return c


func _palette_base() -> Color:
	match clampi(palette_id, 0, 7):
		0:
			return Color(0.22, 0.32, 0.38, 1.0)
		1:
			return Color(0.32, 0.22, 0.18, 1.0)
		2:
			return Color(0.38, 0.28, 0.22, 1.0)
		3:
			return Color(0.28, 0.34, 0.36, 1.0)
		4:
			return Color(0.18, 0.28, 0.42, 1.0)
		5:
			return Color(0.2, 0.22, 0.32, 1.0)
		6:
			return Color(0.25, 0.3, 0.22, 1.0)
		7:
			return Color(0.26, 0.22, 0.3, 1.0)
		_:
			return Color(0.25, 0.3, 0.35, 1.0)
