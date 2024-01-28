sprite_info = {
	neutral_eyes = 80,
	neutral_mouth = 83,
	["big beardy man"] = {
		beard = 139,
		collar = 122,
		hair = 74,
		moustache = 71,
	},
	priest = {
		collar = 101,
	},
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

function tiles(x)
	return x * 8
end

function draw_neutral_eyes(head_top, head_left, head_right)
	function draw_neutral_eyes_left(x, y)
		spr(sprite_info.neutral_eyes, x, y, 3, 3, true, false)
	end
	function draw_neutral_eyes_right(x, y)
		spr(sprite_info.neutral_eyes, x, y, 3, 3, false, false)
	end

	draw_neutral_eyes_left(head_left + 3,             head_top + tiles(3))
	draw_neutral_eyes_right(head_right - tiles(3) - 3, head_top + tiles(3))
end

function draw_neutral_mouth(head_bottom, head_left, head_right)
	function draw_neutral_mouth_left(x, y)
		spr(sprite_info.neutral_mouth, x, y, 2, 3, false, false)
	end
	function draw_neutral_mouth_right(x, y)
		spr(sprite_info.neutral_mouth, x, y, 2, 3, true, false)
	end

	draw_neutral_mouth_left(head_left + tiles(2),  head_bottom - tiles(4))
	draw_neutral_mouth_right(head_right - tiles(4), head_bottom - tiles(4))
end

function draw_priest(head_left, head_right, head_top, head_bottom)
	function draw_collar_left(x, y)
		spr(sprite_info.priest.collar, x, y, 5, 2, false, false)
	end
	function draw_collar_right(x, y)
		spr(sprite_info.priest.collar, x, y, 5, 2, true, false)
	end

	draw_collar_left(64 - tiles(5), head_bottom - tiles(1))
	draw_collar_right(64 - 1,        head_bottom - tiles(1))
end

function draw_big_beardy_man(head_left, head_right, head_top, head_bottom)
	function draw_collar_left(x, y)
		spr(sprite_info["big beardy man"].collar, x, y, 5, 1, false, false)
	end
	function draw_collar_right(x, y)
		spr(sprite_info["big beardy man"].collar, x, y, 5, 1, true, false)
	end
	function draw_beard_left(x, y)
		spr(sprite_info["big beardy man"].beard, x, y, 5, 4, false, false)
	end
	function draw_beard_right(x, y)
		spr(sprite_info["big beardy man"].beard, x, y, 5, 4, true, false)
	end
	function draw_hair_left(x, y)
		spr(sprite_info["big beardy man"].hair, x, y, 3, 3, false, false)
	end
	function draw_hair_right(x, y)
		spr(sprite_info["big beardy man"].hair, x, y, 3, 3, true, false)
	end
	function draw_moustache_left(x, y)
		spr(sprite_info["big beardy man"].moustache, x, y, 3, 2, true, false)
		-- draw_rotated_anticlockwise(x, y, 3, 2, 10, 1)
	end
	function draw_moustache_right(x, y)
		spr(sprite_info["big beardy man"].moustache, x, y, 3, 2, false, false)
		-- draw_rotated_anticlockwise(x, y, 3, 2, 10, 1, true)
	end

	draw_collar_left(64 - tiles(5) + 5, head_bottom)
	draw_collar_right(64 - 1 - 4,       head_bottom)
	draw_beard_left(64 - tiles(5),      head_bottom - tiles(4))
	draw_beard_right(64 - 1,            head_bottom - tiles(4))
	draw_hair_left(64 - tiles(3),       head_top - tiles(1))
	draw_hair_right(64 - 1,             head_top - tiles(1))
	draw_moustache_left(64 - tiles(3),  head_bottom - tiles(4) - 4)
	draw_moustache_right(64 - 1,        head_bottom - tiles(4) - 4)
	-- draw_moustache_left(64 - tiles(2),  head_bottom - tiles(4))
	-- draw_moustache_right(64 - 1,        head_bottom - tiles(4))
end

function draw_head(name, emotion)
	if (emotion == nil) emotion = "neutral"

	-- TODO #temp
	name = "big beardy man"
	-- name = "priest"

	-- setup
	pal()
	palt(0, false)
	palt(13, true)

	local laughing_y_offset = 0
	if emotion == "laughing" and current_laugh ~= nil then
		local laugh_speed = 3 * (current_laugh.speed + 1)
		laughing_y_offset = flr((t() * laugh_speed) % 2)
	end

	local head_left = 64 - tiles(4)
	local head_right = (64 - 1) + tiles(4)
	local head_top = 11 - laughing_y_offset
	local head_bottom = head_top + tiles(10)

	-- base
	draw_base_left(head_left,              head_top)
	draw_base_right(head_right - tiles(4), head_top)

	draw_ear_left(head_left - tiles(1) + 1, head_top + tiles(3))
	draw_ear_right(head_right - 1,          head_top + tiles(3))

	-- generic features
	draw_neutral_eyes(head_top, head_left, head_right)
	draw_neutral_mouth(head_bottom, head_left, head_right)

	-- specific features
	if name == "priest" then
		draw_priest(head_left, head_right, head_top, head_bottom)
	elseif name == "big beardy man" then
		draw_big_beardy_man(head_left, head_right, head_top, head_bottom)
	end
end
