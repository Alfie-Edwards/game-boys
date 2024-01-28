sprites = {
	neutral_eyes =
		function(x_left, x_right, y)
			spr(80, x_left,  y, 3, 3, true,  false)
			spr(80, x_right, y, 3, 3, false, false)
		end,
	neutral_mouth =
		function(x, y)
			spr(83, x, y, 2, 3, false, false)
			spr(83, x + tiles(2) - 1, y, 2, 3, true, false)
		end,
	base =
		function(x, y)
			draw_rotated_anticlockwise(x, y,
			                           10, 4,
			                           0, 0)
			draw_rotated_anticlockwise(x + tiles(4) - 1, y,
			                           10, 4,
			                           0, 0, true)
		end,
	ears =
		function(x_left, x_right, y)
			draw_rotated_anticlockwise(x_left, y,
			                           3, 1,
			                           10, 0)
			draw_rotated_anticlockwise(x_right, y,
			                           3, 1,
			                           10, 0, true)
		end,
	beardy = {
		beard =
			function(x, y)
				map(26, 0, x, y, 5, 4)
				draw_flipped_y_axis(x + tiles(5) - 1, y, 5, 4, 26, 0)
			end,
		collar =
			function(x, y)
				spr(122, x, y, 5, 1, false, false)
				spr(122, x + tiles(5), y, 5, 1, true, false)
			end,
		hair =
			function(x, y)
				spr(74, x, y, 3, 3, false, false)
				spr(74, x + tiles(3), y, 3, 3, true, false)
			end,
		hair_edge =
			function(x_left, x_right, y)
				draw_rotated_anticlockwise(x_left,  y, 3, 2, 10, 1)
				draw_rotated_anticlockwise(x_right, y, 3, 2, 10, 1, true)
			end,
		eyes =
			function(x_left, x_right, y)
				spr(206, x_left,  y, 2, 3, false, false)
				spr(206, x_right, y, 2, 3, true, false)
			end,
		mouth =
			function(x, y)
				spr(93, x, y, 3, 2, false, false)
			end,
	},
	priest = {
		collar =
			function(x, y)
				map(5, 4, x, y, 5, 2)
				draw_flipped_y_axis(x + tiles(5), y, 5, 2, 5, 4)
			end,
		eyes =
			function(x_left, x_right, y)
				spr(26, x_left, y, 3, 3, true, false)
				spr(26, x_right, y, 3, 3, false, false)
			end,
		mouth =
			function(x, y)
				spr(29, x, y, 3, 3, false, false)
			end,
	},
	diver = {
		helmet =
			function(x, y)
				draw_rotated_anticlockwise(x, y,
				                           11, 4,
				                           13, 0)
				draw_rotated_anticlockwise(x + tiles(4), y,
				                           11, 4,
				                           13, 0,
				                           true)
			end,
		helmet_side =
			function(x_left, x_right, y)
				draw_rotated_anticlockwise(x_left, y,
				                           6, 2,
				                           13, 4)
				draw_rotated_anticlockwise(x_right, y,
				                           6, 2,
				                           13, 4,
				                           true)
			end,
		bubbles = {
			function (x, y)
				palt(15, false)
				palt(1, true)
				spr(64, x, y, 1, 1, false, false)
				reset_palt()
			end,
			function (x, y)
				palt(15, false)
				palt(1, true)
				spr(65, x, y, 1, 1, false, false)
				reset_palt()
			end,
			function (x, y)
				palt(15, false)
				palt(1, true)
				spr(224, x, y - tiles(1), 2, 2, false, false)
				reset_palt()
			end,
			function (x, y)
				palt(15, true)
				palt(1, false)
				pal({[1] = 15, [15] = 1})
				spr(224, x, y - tiles(1), 2, 2, false, false)
				pal(0)
				reset_palt()
			end,
			function (x, y)
				palt(15, false)
				palt(1, true)
				spr(226, x, y - tiles(1), 2, 2, false, false)
				reset_palt()
			end,
			function (x, y)
				palt(15, true)
				palt(1, false)
				pal({[1] = 15, [15] = 1})
				spr(64, x, y, 1, 1, false, false)
				pal(0)
				reset_palt()
			end,
		},
	},
	clown = {
		collar =
			function(x, y)
				spr(171, x,            y,     1, 2, false, false)
				spr(171, x + tiles(1), y + 3, 1, 2, false, false)
				spr(171, x + tiles(2), y + 6, 1, 2, false, false)
				spr(171, x + tiles(3), y + 6, 1, 2, false, false)
				spr(171, x + tiles(4), y + 6, 1, 2, false, false)
				spr(171, x + tiles(5), y + 3, 1, 2, false, false)
				spr(171, x + tiles(6), y,     1, 2, false, false)
			end,
		eyes =
			function(x_left, x_right, y)
				spr(198, x_left,  y, 3, 3, true, false)
				spr(198, x_right, y, 3, 3, false, false)
			end,
		mouth =
			function(x, y)
				spr(201, x, y, 3, 3, false, false)
			end,
		nose =
			function(x, y)
				spr( 77, x,            y,            2, 1, false, false)
				spr( 79, x,            y + tiles(1), 2, 1, false, false)
				spr(127, x + tiles(1), y + tiles(1), 2, 1, false, false)
			end,
		hair =
			function(x_left, x_right, y)
				draw_scaled(x_left,  y, 2, 2, 24, 0, 2)
				draw_scaled(x_right, y, 2, 2, 24, 0, 2)
			end
	},
}

function get_person(name)
	for p in all(people) do
		if (p.name == name) return p
	end
	return nil
end

function set_display_pal(name)
	local dpal = get_person(name).screen_pal

	pal(dpal, 1)
end

function tiles(x)
	return x * 8
end

function draw_flipped_y_axis(x, y, w_tiles, h_tiles, map_x, map_y)
	local w_px = w_tiles * 8 - 1
	local h_px = h_tiles * 8 - 1

	for i = 0, h_px do
		tline(
			x + w_px, y + i,
			x,        y + i,
			map_x, map_y + i/8
		)
	end
end

function draw_scaled(x, y, w_tiles, h_tiles, map_x, map_y, scale)
	local w_px = w_tiles * 8 - 1
	local h_px = h_tiles * 8 - 1

	for i = 0, h_px do
		for j = 0, scale - 1 do
			tline(
				x,                      y + (i * scale + j),
				x + (w_px + 1) * scale, y + (i * scale + j),
				map_x, map_y + i/8,
				1/(8 * scale), 0
			)
		end
	end
end

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


function draw_ears(head_left, head_right, head_top)
	sprites.ears(head_left - tiles(1) + 1, head_right - 1,
	             head_top + tiles(3))
end

function draw_neutral_eyes(head_top, head_left, head_right)
	sprites.neutral_eyes(
		head_left + 3, head_right - tiles(3) - 3,
		head_top + tiles(3))
end

function draw_neutral_mouth(head_bottom, head_left, head_right)
	sprites.neutral_mouth(head_left + tiles(2), head_bottom - tiles(4))
end

function draw_priest(emotion, head_left, head_right, head_top, head_bottom)
	set_display_pal("priest")

	-- base layer
	sprites.base(head_left, head_top)
	draw_ears(head_left, head_right, head_top)

	if emotion == "neutral" then
		draw_neutral_eyes(head_top, head_left, head_right)
		draw_neutral_mouth(head_bottom, head_left, head_right)
	else
		if emotion == "angry" then
			palt(13, true)
			palt(0, false)
			palt(7, true)
			palt(-15, true)
		else
			palt(13, true)
			palt(0, false)
			palt(7, false)
			palt(5, true)
			palt(2, true)
		end
		sprites.priest.eyes(head_left + 4, head_right - tiles(3) - 4,
		                    head_top + tiles(3))
		reset_palt()

		if emotion == "angry" then
			palt(13, true)
			palt(0, false)
			palt(3, true)
			palt(9, true)
			palt(10, true)
			palt(11, true)
		else
			palt(13, true)
			palt(0, false)
			palt(1, true)
			palt(2, true)
		end
		sprites.priest.mouth(head_left + tiles(2.5) - 1, head_bottom - tiles(4) - 1)
		reset_palt()
	end

	-- features
	sprites.priest.collar(head_left - tiles(1), head_bottom - tiles(1))
end

function draw_big_beardy_man(emotion, head_left, head_right, head_top, head_bottom)
	set_display_pal("big beardy man")

	-- base layer
	sprites.base(head_left, head_top)
	draw_ears(head_left, head_right, head_top)

	if emotion == "neutral" then
		draw_neutral_eyes(head_top, head_left, head_right)
	else
		if emotion == "angry" then
			palt(13, true)
			palt(0, true)
			palt(-16, true)
		else
			palt(13, true)
			palt(1, true)
			palt(2, true)
			palt(3, true)
		end
		sprites.beardy.eyes(
			head_left + tiles(2) - 5,
			head_right - tiles(3) - 3,
			head_top + tiles(3))
		reset_palt()
	end

	-- features
	sprites.beardy.collar(head_left - tiles(1), head_bottom)
	sprites.beardy.hair(64 - tiles(3), head_top - 1)
	sprites.beardy.hair_edge(head_left - tiles(1) + 1, head_right - tiles(1) - 1,
	                         head_top + tiles(1))
	sprites.beardy.beard(64 - tiles(5), head_bottom - tiles(4))

	if emotion ~= "neutral" then
		palt(5, true)
		palt(6, true)
		palt(10, true)
		if emotion == "angry" then
			palt(0, true)
			palt(14, true)
			palt(-16, true)
		else
			palt(3, true)
			palt(4, true)
		end
		sprites.beardy.mouth(64 - tiles(1.5), head_bottom - tiles(3))
		reset_palt()
	end
end

function draw_diver(emotion, head_left, head_right, head_top, head_bottom)
	set_display_pal("diver")

	sprites.diver.helmet(head_left, head_top)
	sprites.diver.helmet_side(
		head_left - tiles(2) + 1,
		head_right,
		head_top + tiles(2) + 1)

	local bubbles_x = head_left + tiles(3.5)
	local bubbles_y = head_top

	local bubbles_stage = flr((t() * 5) % #sprites.diver.bubbles) + 1

	sprites.diver.bubbles[bubbles_stage](bubbles_x, bubbles_y)
end

function draw_clown(emotion, head_left, head_right, head_top, head_bottom)
	set_display_pal("bobo the clown")

	-- underneath features
	sprites.clown.collar(head_left + tiles(0.5), head_bottom - tiles(2))

	-- base layer
	sprites.base(head_left, head_top)
	draw_ears(head_left, head_right, head_top)

	-- features
	if emotion == "neutral" then
		draw_neutral_eyes(head_top, head_left, head_right)
	else
		if emotion == "angry" then
			palt(2, true)
			palt(3, true)
			palt(5, true)
			palt(6, true)
			palt(7, true)
		else
			palt(0, true)
		end
		sprites.clown.eyes(
			head_left + tiles(1) - 5,
			head_right - tiles(3) - 3,
			head_top + tiles(3))
		reset_palt()
	end

	if emotion == "neutral" then
		draw_neutral_mouth(head_bottom, head_left, head_right)
	else
		if emotion == "angry" then
			palt(3, true)
			palt(11, true)
			palt(12, true)
			palt(6, true)
			palt(14, true)
			palt(15, true)
			palt(10, true)
			palt(2, true)
			palt(5, true)
		elseif emotion == "laughing" then
			palt(5, true)
			palt(6, true)
			palt(14, true)
			palt(15, true)
			palt(10, true)
			palt(2, true)
			palt(0, true)
			palt(8, true)
		end
		sprites.clown.mouth(head_left + tiles(2.5), head_bottom - tiles(3.5))
		reset_palt()
	end

	sprites.clown.nose(head_left + tiles(3), head_top + tiles(4.5))

	sprites.clown.hair(
		head_left - tiles(1.5),
		head_right - tiles(2.5),
		head_top - tiles(1))
end

function reset_palt()
	palt()
	palt(0, false)
	palt(13, true)
end

function draw_head(name, emotion)
	if (emotion == nil) emotion = "neutral"

	-- setup
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

	-- specific features
	if name == "priest" then
		draw_priest(emotion, head_left, head_right, head_top, head_bottom)
	elseif name == "big beardy man" then
		draw_big_beardy_man(emotion, head_left, head_right, head_top, head_bottom)
    elseif name == "diver" then
		draw_diver(emotion, head_left, head_right, head_top, head_bottom)
	elseif name == "bobo the clown" then
		draw_clown(emotion, head_left, head_right, head_top, head_bottom)
	end
end
