extends RichTextLabel

## Procedural textured ASCII frame with per-character BBCode color.

@export var frame_title: String = "STORAGE ROOM"
@export_range(10, 24) var char_rows: int = 15
@export_range(40, 80) var char_cols: int = 64
@export var title_row: int = 2

## 0 storage 1 garage 2 apartment 3 hospital 4 lighthouse 5 subway 6 power 7 house
@export var palette_id: int = 0

const BORDER_TOP := "#%@&*+=~^"
const SIDE_CHARS := "|!:."
const INNER_DUST := " .'`,:;~-"


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
	add_theme_font_size_override("normal_font_size", 15)
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
		var n := _nhash(x, y)
		return BORDER_TOP[n % BORDER_TOP.length()]
	if x == 0 or x == char_cols - 1:
		var n2 := _nhash(x * 2, y * 3)
		return SIDE_CHARS[n2 % SIDE_CHARS.length()]
	var d := _nhash(x * 3, y * 5) % 1000
	if d < 34:
		return INNER_DUST[d % INNER_DUST.length()]
	if d < 42:
		return String.chr(96)
	return " "


func _nhash(ix: int, iy: int) -> int:
	var s := sin(float(ix) * 0.71 + float(iy) * 0.53) * 43758.5453
	return int(abs(sin(s + float(ix * iy)) * 10000.0)) % 10000


func _pick_color(x: int, y: int, ch: String, is_title: bool) -> Color:
	var base := _palette_base()
	var edge := x == 0 or x == char_cols - 1 or y == 0 or y == char_rows - 1
	var t := float(x + y) / float(char_cols + char_rows)
	var pulse := 0.5 + 0.5 * sin(float(x) * 0.31 + float(y) * 0.27)

	if is_title:
		var hi := base.lightened(0.62 + 0.12 * pulse)
		hi = hi.lerp(Color(0.95, 0.88, 0.45, 1.0), 0.42)
		return hi

	if edge:
		var stone := base.lerp(Color(0.52, 0.44, 0.34, 1.0), t * 0.65)
		stone = stone.lerp(Color(0.88, 0.74, 0.52, 1.0), pulse * 0.5)
		return stone

	var void_c := base.darkened(0.58)
	void_c = void_c.lerp(base, pulse * 0.1)
	if ch != " ":
		void_c = void_c.lerp(Color(0.32, 0.4, 0.48, 1.0), 0.22)
	return void_c


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
