extends Node2D

const ROWS := 5
const COLS := 9
const GRID_LEFT := 250.0
const GRID_TOP := 120.0
const CELL_W := 105.0
const CELL_H := 100.0

var cells: Array = []
var defenders: Array = []
var enemies: Array = []
var projectiles: Array = []

var credits := 150
var score := 0
var selected_type := ""
var game_over := false
var victory := false
var elapsed := 0.0
var credit_timer := 0.0
var spawn_timer := 3.0
var spawn_index := 0

func _ready() -> void:
	for row in ROWS:
		cells.append([])
		for col in COLS:
			cells[row].append(null)

func _process(delta: float) -> void:
	if game_over:
		return

	elapsed += delta
	credit_timer += delta
	spawn_timer -= delta

	if credit_timer >= 5.0:
		credit_timer = 0.0
		credits = min(999, credits + 25)

	if spawn_timer <= 0.0:
		spawn_enemy()
		spawn_index += 1
		spawn_timer = max(0.8, 2.8 - elapsed * 0.018)

	for defender in defenders:
		defender["cooldown"] -= delta
		var lane_has_enemy := false
		for enemy in enemies:
			if int(enemy["lane"]) == int(defender["lane"]) and enemy["x"] > defender["x"]:
				lane_has_enemy = true
				break
		if lane_has_enemy and defender["cooldown"] <= 0.0:
			defender["cooldown"] = 1.0
			projectiles.append({"x": defender["x"] + 24.0, "y": defender["y"], "lane": defender["lane"], "damage": 20.0})

	for i in range(projectiles.size() - 1, -1, -1):
		var projectile = projectiles[i]
		projectile["x"] += 280.0 * delta
		var hit := false
		for j in range(enemies.size() - 1, -1, -1):
			var enemy = enemies[j]
			if int(enemy["lane"]) == int(projectile["lane"]) and abs(enemy["x"] - projectile["x"] ) < 25.0:
				enemy["health"] -= projectile["damage"]
				projectiles.remove_at(i)
				hit = true
				if enemy["health"] <= 0:
					score += 100
					enemies.remove_at(j)
				break
		if hit:
			continue
		if projectile["x"] > 1280.0:
			projectiles.remove_at(i)

	for i in range(enemies.size() - 1, -1, -1):
		var enemy = enemies[i]
		enemy["attack_timer"] -= delta
		var enemy_attacking := false

		for j in range(defenders.size() - 1, -1, -1):
			var defender = defenders[j]
			if int(defender["lane"]) == int(enemy["lane"]) and abs(defender["x"] - enemy["x"] ) < 42.0:
				enemy_attacking = true
				if enemy["attack_timer"] <= 0.0:
					enemy["attack_timer"] = 0.9
					defender["health"] -= 18.0
					if defender["health"] <= 0:
						cells[defender["lane"]][defender["col"]] = null
						defenders.remove_at(j)
				break

		if not enemy_attacking:
			enemy["x"] -= enemy["speed"] * delta

		if enemy["x"] < 105.0:
			enemies.remove_at(i)
			game_over = true

	if elapsed >= 75.0:
		victory = true
		game_over = true

	queue_redraw()

func spawn_enemy() -> void:
	var lane := randi_range(0, ROWS - 1)
	var health := 100.0 + elapsed * 1.2
	var speed := 12.0 + elapsed * 0.05
	enemies.append({"x": 1250.0, "lane": lane, "health": health, "max_health": health, "speed": speed, "attack_timer": 0.0})

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if game_over:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_restart()
			return
		if event.button_index != MOUSE_BUTTON_LEFT:
			return

		var mouse: Vector2 = event.position

		if mouse.x >= 20.0 and mouse.x <= 120.0:
			if mouse.y >= 120.0 and mouse.y <= 210.0:
				selected_type = "compiler"
				return
			if mouse.y >= 225.0 and mouse.y <= 315.0:
				selected_type = "firewall"
				return

		if selected_type == "":
			return

		var col := int(floor((mouse.x - GRID_LEFT) / CELL_W))
		var row := int(floor((mouse.y - GRID_TOP) / CELL_H))
		if row < 0 or row >= ROWS or col < 0 or col >= COLS:
			return
		if cells[row][col] != null:
			return

		var cost := 50 if selected_type == "compiler" else 75
		if credits < cost:
			return

		credits -= cost
		var x := GRID_LEFT + col * CELL_W + CELL_W * 0.5
		var y := GRID_TOP + row * CELL_H + CELL_H * 0.5
		defenders.append({"x": x, "y": y, "lane": row, "col": col, "type": selected_type, "health": 100.0, "cooldown": 0.2})
		cells[row][col] = selected_type
		selected_type = ""

func _restart() -> void:
	cells.clear()
	for row in ROWS:
		cells.append([])
		for col in COLS:
			cells[row].append(null)
	defenders.clear()
	enemies.clear()
	projectiles.clear()
	credits = 150
	score = 0
	selected_type = ""
	game_over = false
	victory = false
	elapsed = 0.0
	credit_timer = 0.0
	spawn_timer = 3.0
	spawn_index = 0

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color("101827"))
	draw_rect(Rect2(Vector2(0, 80), Vector2(1280, 560)), Color("18324a"))

	for row in ROWS:
		for col in COLS:
			var rect := Rect2(GRID_LEFT + col * CELL_W, GRID_TOP + row * CELL_H, CELL_W, CELL_H)
			var color := Color("2a4c45") if (row + col) % 2 == 0 else Color("314f50")
			draw_rect(rect, color)
			draw_rect(rect, Color("92cbb0", 0.22), false, 1.0)

	# Resource panel and cards
	draw_rect(Rect2(20, 20, 210, 48), Color("26384d"))
	draw_string(ThemeDB.fallback_font, Vector2(35, 51), "CYCLES: %d" % credits, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("70e5ff"))
	draw_string(ThemeDB.fallback_font, Vector2(250, 50), "SCORE: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
	draw_string(ThemeDB.fallback_font, Vector2(480, 50), "SURVIVE: %.0f / 75s" % elapsed, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("ffcf70"))

	_draw_card(20, 120, "COMPILER", 50, Color("55b9ff"), selected_type == "compiler")
	_draw_card(20, 225, "FIREWALL", 75, Color("f49b55"), selected_type == "firewall")

	for defender in defenders:
		if defender["type"] == "compiler":
			draw_circle(Vector2(defender["x"], defender["y"]), 28.0, Color("55b9ff"))
			draw_string(ThemeDB.fallback_font, Vector2(defender["x"] - 22.0, defender["y"] + 7.0), "</>", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("10253a"))
		else:
			draw_rect(Rect2(defender["x"] - 27.0, defender["y"] - 27.0, 54.0, 54.0), Color("f49b55"))
			draw_string(ThemeDB.fallback_font, Vector2(defender["x"] - 18.0, defender["y"] + 7.0), "DEF", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("40220d"))
		_draw_health_bar(defender["x"], defender["y"] - 38.0, defender["health"] / 100.0)

	for enemy in enemies:
		draw_circle(Vector2(enemy["x"], GRID_TOP + enemy["lane"] * CELL_H + CELL_H * 0.5), 30.0, Color("ec6071"))
		draw_string(ThemeDB.fallback_font, Vector2(enemy["x"] - 23.0, GRID_TOP + enemy["lane"] * CELL_H + 57.0), "BUG", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color.WHITE)
		_draw_health_bar(enemy["x"], GRID_TOP + enemy["lane"] * CELL_H + 10.0, enemy["health"] / enemy["max_health"])

	for projectile in projectiles:
		draw_circle(Vector2(projectile["x"], GRID_TOP + projectile["lane"] * CELL_H + CELL_H * 0.5), 7.0, Color("f2f7aa"))

	if game_over:
		draw_rect(Rect2(390, 260, 500, 200), Color("101827", 0.94))
		var title := "SYSTEM SECURED!" if victory else "SYSTEM CRASHED"
		draw_string(ThemeDB.fallback_font, Vector2(510, 330), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color("70e5ff") if victory else Color("ff7777"))
		draw_string(ThemeDB.fallback_font, Vector2(528, 375), "Score: %d" % score, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(530, 420), "Click to restart", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("b4c0cc"))

func _draw_card(x: float, y: float, label: String, cost: int, color: Color, selected: bool) -> void:
	draw_rect(Rect2(x, y, 100, 90), Color("0b111b") if selected else Color("26384d"))
	draw_rect(Rect2(x + 8, y + 8, 84, 54), color)
	draw_string(ThemeDB.fallback_font, Vector2(x + 14, y + 40), label.left(7), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("101827"))
	draw_string(ThemeDB.fallback_font, Vector2(x + 28, y + 78), "%d cycles" % cost, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)

func _draw_health_bar(x: float, y: float, ratio: float) -> void:
	draw_rect(Rect2(x - 25.0, y, 50.0, 5.0), Color("3b1c23"))
	draw_rect(Rect2(x - 25.0, y, 50.0 * clamp(ratio, 0.0, 1.0), 5.0), Color("72dd88"))
