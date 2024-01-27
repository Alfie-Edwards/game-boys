sprite_info = {
	priest = {
		collar_sprite = 101,
	}
}

function draw_rotated_anticlockwise(x, y, w_tiles, h_tiles, map_x, map_y, flip_y)
	if (flip_y == nil) flip_y = false

	local w_px = w_tiles * 8 - 1
	local h_px = h_tiles * 8 - 1

	for i = 0, h_px do
		local map_y_idx = flip_y and (h_px - i)/8 or i/8
		tline(
			x + i, (y + w_px),
			x + i, (y + w_px) - w_px,
			map_x, map_y + map_y_idx
		)
	end
end

function draw_rotated_clockwise(x, y, w_tiles, h_tiles, map_x, map_y, flip_y)
	if (flip_y == nil) flip_y = false

	local w_px = w_tiles * 8 - 1
	local h_px = h_tiles * 8 - 1

	for i = 0, h_px do
		local map_y_idx = flip_y and (h_px - i)/8 or i/8
		tline(
			x + i, y,
			x + i, y + w_px,
			map_x, map_y + map_y_idx
		)
	end
end

function draw_base_left(x, y)
	draw_rotated_anticlockwise(x, y,
	                           10, 4,
	                           0, 0)
	-- local w_tiles = 10
	-- local h_tiles = 4

	-- local w = w_tiles * 8
	-- local h = h_tiles * 8
	-- local x = 64 - h
	-- local y = 10

	-- for i = 0, h do
	-- 	tline(
	-- 		x + i, (y + w),
	-- 		x + i, (y + w) - w,
	-- 		0,     i/8
	-- 	)
	-- end

	-- for i = 0, h do
	-- 	tline(
	-- 		x,     y + i,
	-- 		x + w, y + i,
	-- 		0,     i/8
	-- 	)
	-- end
end

function draw_base_right(x, y)
	draw_rotated_anticlockwise(x, y,
	                           10, 4,
	                           0, 0, true)
end

function draw_ear_left(x, y)
	draw_rotated_anticlockwise(x, y,
	                           3, 1,
	                           10, 0)
end

function draw_ear_right(x, y)
	draw_rotated_anticlockwise(x, y,
	                           3, 1,
	                           10, 0, true)
end

function draw_collar_left(x, y)
	spr(101, x, y, 5, 2, false, false)
end

function draw_collar_right(x, y)
	spr(101, x, y, 5, 2, true, false)
end

function tiles(x)
	return x * 8
end

function draw_collar(sprite_idx, head_bottom)
	draw_collar_left(64 - tiles(5), head_bottom - tiles(1))
	draw_collar_right(64 - 1,       head_bottom - tiles(1))
end

function draw_head(name)
	-- TODO #temp
	name = "priest"

	pal()
	palt(0, false)
	palt(13, true)

	local head_left = 64 - tiles(4)
	local head_right = (64 - 1) + tiles(4)
	local head_top = 1
	local head_bottom = head_top + tiles(10)

	draw_base_left(head_left, head_top)
	draw_base_right(head_right - tiles(4), head_top)

	draw_ear_left(head_left - tiles(1) + 1, head_top + tiles(3))
	draw_ear_right(head_right - 1,          head_top + tiles(3))

	draw_collar(sprite_info[name].collar_sprite, head_bottom)
end
