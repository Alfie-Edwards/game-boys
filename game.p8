pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

#include people.lua


-- setup -----------------------
max_health = 3
max_adjustments = 3


-- state -----------------------
health = max_health
score = 0
lost = false


function _init()
	poke(0x5F2D, 1)
	pal_light_red()
	update_mouse()

	init_people()

    sliders = {
        length = { name_x = 8, y = 100, value = 1, grabbed = false },
        speed = { name_x = 12, y = 107, value = 1, grabbed = false },
        pitch = { name_x = 12, y = 114, value = 1, grabbed = false },
        fun = { name_x = 20, y = 121, value = 1, grabbed = false },
    }

    buttons = {
        submit = { x = 110, y = 113, r = 7, on_click = function()
            choose({
                speed = sliders.speed.value - 1,
                pitch = sliders.pitch.value - 1,
                fun = sliders.fun.value - 1,
                length = sliders.length.value - 1, })
            end
        },
    }
end

function restart()
	health = max_health
	score = 0
	lost = false
	_init()
end

function _update60()
    update_mouse()

    if lost and btn(5) then
        restart()
    elseif saying then
        if saying_para_done() then
            if any_input() then
                saying.para += 1
                saying.char = 1
                if saying.para > #saying.paras then
                    saying = nil
                end
            end
        else
            saying.char = saying.char + 1
            if saying.char == #saying.paras then
                t_para_completed = t()
            end
        end
    else
        -- Grab and ungrab slider handles.
        if mouse.pressed then
            for _, slider in pairs(sliders) do
                local handle = slider_handle_pos(slider)
                if sqdst(mouse.x, mouse.y, handle.x, handle.y) <= 8 then
                    slider.grabbed = true
                end
            end
        elseif mouse.released then
            for _, slider in pairs(sliders) do
                slider.grabbed = false
            end
        end

        -- Move grabbed slider handles to the nearest point to the mouse.
        for _, slider in pairs(sliders) do
            if slider.grabbed then
                local nearest = {}
                local nearest_dist = 32000
                for value=1, 3 do
                    local handle = slider_handle_pos(slider, value)
                    local dst = sqdst(mouse.x, mouse.y, handle.x, handle.y)
                    if dst < nearest_dist then
                        nearest_dist = dst
                        nearest = value
                    end
                end
                slider.value = nearest
            end
        end

        -- Press buttons.
        if mouse.pressed then
            for _, button in pairs(buttons) do
                if sqdst(mouse.x, mouse.y, button.x, button.y) <= (button.r * button.r) + 2 then
                    button.on_click()
                end
            end
        end
    end
end

function lnpx(text) -- length of text in pixels
	return print(text, 0, 999999)
end

function draw_lose_screen()
	local lost_text = "you lost!"
	local lost_text_y = 40

	local score_start_text = "you made "
	local score_end_text = " laughs"
	local score_text_y = 60
	local score_col = 10

	local replay_start_text = "press "
	local replay_button = "❎"
	local replay_end_text = " to play again"
	local replay_text_y = 80
	local replay_col = -5

	color(7)
	print(lost_text, 64 - lnpx(lost_text) / 2, lost_text_y)

	local score_text_length = lnpx(score_start_text..score..score_end_text)
	print(score_start_text, 64 - score_text_length / 2, score_text_y)
	color(score_col)
	print(score, (64 - score_text_length / 2) + lnpx(score_start_text), score_text_y)
	color(7)
	print(score_end_text, (64 - score_text_length / 2) + lnpx(score_start_text..score), score_text_y)

	local replay_text_length = lnpx(replay_start_text..replay_button..replay_end_text)
	print(replay_start_text, 64 - replay_text_length / 2, replay_text_y)
	color(replay_col)
	print(replay_button, (64 - replay_text_length / 2) + lnpx(replay_start_text), replay_text_y)
	color(7)
	print(replay_end_text, (64 - replay_text_length / 2) + lnpx(replay_start_text..replay_button), replay_text_y)
end

max_line_len = 30
max_lines = 6
function wrap(text)
    local lines = {}
    for _, para in ipairs(split(text, "\n")) do
        add(lines, "")
        for _, word in ipairs(split(para, " ", false)) do
            if (#lines[#lines] + #word + 1) > max_line_len then
                if #word > max_line_len then
                    local i = max_line_len - #lines[#lines]
                    lines[#lines] = lines[#lines]..sub(word, 1, i).." "
                    i += 1
                    while i <= #word do
                        add(lines, sub(word, i, i + max_line_len - 1))
                        i += max_line_len
                    end
                else
                    add(lines, word.." ")
                end
            else
                lines[#lines] = lines[#lines]..word.." "
            end
        end
    end
    local result = ""
    for i, line in ipairs(lines) do
        if i > 1 then
            result = result.."\n"
        end
        result = result..line
    end
    assert(#lines <= max_lines)
    return result
end

function _draw()
	cls(4)

	if lost then
		draw_lose_screen()
		return
	end

    -- Head

    -- Laugh maker
    pal_dark_blue()
    color(1)
    rectfill(0, 98, 127, 127)
    for name, slider in pairs(sliders) do
        color(5)
        print(name, slider.name_x, slider.y)
        color(4)
        line(40, slider.y + 2, 80, slider.y + 2)
        color(5)
        local h = slider_handle_pos(slider)
        rectfill(h.x - 1, h.y - 1, h.x + 1, h.y + 1)
    end
    color(5)
    circfill(buttons.submit.x, buttons.submit.y, buttons.submit.r)

    -- Speech bubble
    if saying then
        pal_light_red()
        color(5)
        rectfill(5, 87, 122, 125)
        rectfill(2, 90, 125, 122)
        circfill(5, 90, 3)
        circfill(122, 90, 3)
        circfill(5, 122, 3)
        circfill(122, 122, 3)
        print("◆", 8, 84)

		color(1)
		print(sub(saying.paras[saying.para], 1, saying.char), 4, 89)

		if saying_para_done() and strobe(0.66, t_para_completed) then
			color(5)
			print("♥", 111, 124)
			color(4)
			print("♥", 111, 122)
		end
	end

	draw_base()

	-- health
	color(8)
	local health_str = ""
	for i = 0, health - 1 do
		health_str = health_str.."♥"
	end
	print(health_str, 128 - (lnpx(health_str) + 2), 4)
	color(7)

    -- Cursor
    color(0)
    circfill(mouse.x, mouse.y, 1)
end

function slider_handle_pos(slider, value)
    value = value or slider.value
    if value == 1 then
        return { x = 42, y = slider.y + 2}
    elseif value == 2 then
        return { x = 60, y = slider.y + 2}
    else
        return { x = 78, y = slider.y + 2}
    end
end

function sqdst(x1, y1, x2, y2)
    return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

function say(paras)
	if type(paras) == "string" then
		paras = {paras}
	end

	for i,v in ipairs(paras) do
		paras[i] = wrap(v)
	end

	saying = {
		char = 1,
		para = 1,
		paras = paras,
	}
end

function saying_para_done()
	return (not saying) or saying.char == #saying.paras[saying.para]
end

function pal_light_red()
    pal({[0] = 0, 2, -8, 8, 14, 7})
end

function pal_dark_blue()
    pal({[0] = 0, -15, 1, -4, 12, 7})
end

function lose()
	say("lose!!!!!!!!!!!!!!!!!!")
	say("your score was "..score)
	lost = true
end

function play_laugh(laugh_params)
	--
end

function show_person(face_idx, skin_tone, name)
	say("set person to "..name..", idx "..face_idx..", skin tone "..skin_tone)
end

function show_initial_prompt(prompt, initial_laugh)
	say(prompt)
	play_laugh(initial_laugh)
end

function show_adjustment_prompt(prompt, chosen_laugh)
	say(prompt)
	play_laugh(chosen_laugh)
end

function show_accepted(text, correct_laugh)
	say(text)
	play_laugh(correct_laugh)
end

function strobe(period, offset)
    return (t() - (offset or 0) + period) % (period * 2) < period
end

function any_input()
    return btn(4) or btn(5) or mouse.pressed
end

function update_mouse()
    local down_last = mouse ~= nil and mouse.down
    local down = (stat(34) & 1) != 0
    mouse = {
        x = stat(32) - 1,
        y = stat(33) - 1,
        pressed = (down and not down_last),
        released = (down_last and not down),
        down = down,
    }
end

__gfx__
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111dddddddd
dddddddddddddddddddddddddddd111111ffff1111111122fff72222dddddddddddddddddddddddddddddddddddddddddddddddddddddddd11111111dddddddd
dddddddddddddddddddddddddd11122222fffffffffffffff2222222222dddddddddddddddddddddddddd22222222222dddddddddddddddd11111111dddddddd
dddddddddddddddddddddddd11122222fffffffffffffffffff2222222222ddddddddddddddddddddd1222fffffffffff77ddddddddddddd11111111dddd333d
ddddddddddddddddddddddd1122222ffffffffffffffffffffffffffff22222dddddddddddddddddd122ffffffffffffff77dddddddddddd11111111ddd13333
ddddddddddddddddddddd11122222ffffffffffffffffffffffffffffffff2222ddddddddddddddd122fffff722222fffff77ddddddddddd11111111ddd13333
dddddddddddddddddddd1122222fffffffffffffffffffffffffffffffffffff22dddddddddddddd122ffff777111222ffff7ddddddddddd11111111ddd11331
ddddddddddddddddddd1122222ffffffffffffffffffffffffffffffffffffffff22dddddddddddd122fffff771111122fff77dddddddddd11111111dddd111d
dddddddddddddddddd1122222fffff77777ffffffffffffffffffffffffffffffff22ddddddddddddddddddddd555ddddddddddddddddddddddddddddddddddd
ddddddddddddddddd1122222fffff7777777fffffffffffffffffffffffffffffffff2dddddddddddddddddddd5555dddddddddddddddddddddddddddddddddd
dddddddddddddddd112222ffffff7f7f77777ffffffffffffffffffffffffffffffffffddddddddddddddddddd25555ddddddddddd9dddddd2ddddddddddddd9
ddddddddddddddd112222ffffff7f77f777777ffffffffffffffffffffffffffffffffffdddddddddddddd5d22222255999ddddddd9ddddddd21ddddddddddd9
dddddddddddddd112222ffffff7f7f7f7777777ffffffffffffffffffffffffffffffffffdddddddddddd5555522222955a9ddddddd9ddddd11d9ddddddddd9d
ddddddddddddd1112222ffffff7fff7f7777777fffffffffffffffffffffffffffffffffffdddddddddd25552252222dd25a9dddddd9dddd12d9a9dddddddd9d
dddddddddddd1112222fffffff7fffff7777777fffffffffffffffffff7fffffffffffffff7ddddddddd225552222222dd22dddddddd9dd2dd9aaa9dddddd9dd
ddddddddddd11122222fffffff7fffff777777ffffffffffffffffffff7ffffffffffffffff7ddddddddd2255522251111dddddddd111999999aaaa999999ddd
dddddddddd11112222ffffffffffffff777777ffffffffffffffffffff77fffffffffffffff7ddddddddddd225555177771dddddd11111d9aaaaaaaaaaaa9ddd
dddddddd111112222fffffffffffffff77777fffffffffffffffffffff77ffffffffffffff777dddddddddddd22217777771dddd11221119aaaaaaaaaaaa9ddd
ddddddd111112222fffffffffffffffff77fffffffffffffffffffffff777ffffffffffffff77dddddddddddddd1777717771ddd1dddd119aaaaaaaaaaaa9ddd
dddddd1111222222ffffffffffffffffffffffffffffffffffffffffff777fffffffffffff7f77dddddddddddd177777117771dd1dddd219aaaaaaaaaaaa9ddd
ddddd1111222222ffffffffffffffffffffffffffffffffffffffffff7f77ffffffffffffff777ddddddddddd17777771177771ddddddd19aaaaaaaaaaaa9ddd
ddddd112222222fffffffffffffffffffffffffffffffffffffffffff77777fffffffffffffff7ddddddddddd17777771177771ddddddd29aaaaaaaaaaaa9ddd
dddd112222222ffffffffffffffffffffffffffffffffffffffffffff777777fffffffffffff777dddddddddd17777771177771ddddddd29aaaaaaaaaaaa9ddd
ddd11222222fffffffffffffffffffffffffffffffffffffffffffff7f77777ffffffffffffff77dddddddddd17777771177771dddddddd9aaaaaaaaaaaa9ddd
dd1122222ffffffffffffffffffffffffffffffffffffffffffffff777777777fffffffffffff77ddddddddddd177777117771ddddddddd9aaaaaaaaaaaa9ddd
dd122222fffffffffffffffffffffffff22222fffffffffffffffff7f7777777ffffffffff7f777dddddddddddd1777717771dddddddddd9aaaaaaaaaaaa9ddd
d112222fffffffffffffffffffffffff2122222222222222fffff7fff7777777ffffffffff7f7777dddddddddddd17777771ddddddddddd9a333333333aa9ddd
d11222fffffffffffffffffffffffff112ffffffffffffffffffff77777777777fffffffff7f7777ddddddddddddd177711dddddddddddd93bbb333bbbba9ddd
112222fffffffffffffffffffffffff12fffffffffffffffffff7777777777777fffffffff777777dddddddddddddd111dddddddddddddd93bbbb3bbbbbb9ddd
112222ffffffffffffffffffffffff112f7ffffffffffff777777777777777777fffffff7f7f7777dddddddddddddddddddddddddddddddd93bbb3bbbbb9dddd
11222fffffffffffffffffffffffff11277f77777777777777777777777777777fffffff7f7f7777ddddddddddddddddddddddddddddddddd9bbbbbbbb9ddddd
11222fffffffffffffffffffffffff11277777777777777777777777777777777fffffff7f7f7777ddddddddddddddddddddddddddddddddd999999999dddddd
dddddddddddddddddddddddddddddddddddddddddddddccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddccccccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ddddddddddddddddddddddddddddddddddddddddddccccccccccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddccc777ccc77cccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddcc7ccc7c7cc7ccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddd4cc7ccc7c7cc7cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddd4cc7ccccc7cc7cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddd4cc7ccccc7cc7cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
f77ffffffffffffffffffff2ddddfffffff555554cc7c777c7cc7cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
fffffffffffffffffffffff2dddd7ffffffff5554cc7ccc7c7cc7cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
7fffff55555555555ffffff2ddddf7ffffffff224cc7ccc7c7cc7cccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ffff55522222222221fffff2ddddf77fffffff22d4cc7777cc77cccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff555222222ffffffffffff2ddddfffffffffff2d4cccccccccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff552222ffffffffffffffffddddfffffffffff2dd4cccccccccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff222fffff77ffffffffffffddddfffffffffff2ddd44ccccccccddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
ff2222777777772fffffffffddddffffffffff22ddddd4444444dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
2222225555555522ffffffffddddffffffffffffdddddddddddddddddddddddddd11122222ffffffdddddddddddddddddddddddddddddddddddddddddddddddd
22222555557522222fffffffddddffffffff222fdddddddddddddddddddddd5000011122222fffffdddddddddddddddddddddddddddddddddddddddddddddddd
2222255575752fffffffffffddddfffff2555555dddddddddddddddddddddd5000001112222222ffdddddddddddddddddddddddddddddddddddddddddddddddd
222225555522ffffffffffffddddfffff2277777dddddddddddddddddddddd500000001122222222dddddddddddddddddddddddddddddddddddddddddddddddd
22222255522fffffffffffffddddffff22f2ffffdddddddddddddddddddddd500000000112222222dddddddddddddddddddddddddddddddddddddddddddddddd
22ffffffffffffffffffffffddddffffffff2222dddddddddddddddddddddd500000000011112222dddddddddddddddddddddddddddddddddddddddddddddddd
22ffffffffffffffffffffffddddfffffffffff2dddddddddddddddddddddd500000000000111111dddddddddddddddddddddddddddddddddddddddddddddddd
2fffffffffffffffffffffffddddfffffffffff2dddddddddddddddddddd00500000000000661111dddddddddddddddddddddddddddddddddddddddddddddddd
2ffffffffffff7ffffffffffddddffffffffff22dddddddddddddddd000000050000000000666666dddddddddddddddddddddddddddddddddddddddddddddddd
2fffffffff77777fffffffffdddd2ffffff77777dddddddddddd0000000000005500000000667777dddddddddddddddddddddddddddddddddddddddddddddddd
22ffffff77777777ffffffffdddd22ffff777777ddddddddd0000000000000000555000000677777dddddddddddddddddddddddddddddddddddddddddddddddd
22ffffff777777777fffffffdddd222ff7fff777ddddddd000000000000000000000500000677777dddddddddddddddddddddddddddddddddddddddddddddddd
22ffffff7777777777ffffffdddd222fffffffffddddd00000000000000000000000050000677777dddddddddddddddddddddddddddddddddddddddddddddddd
22ffffff77777777777fffffdddd2222ffffffffddddd00000000000000000000000000500666777dddddddddddddddddddddddddddddddddddddddddddddddd
12fffff777777777777fffffdddd2222ffffffffddddd00000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd
2ffffff777777777777fffffdddd12222fffffffddddd00000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d00000d99999dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d00000d90009dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d00000d90009dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d00000d90009dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d00000d99999dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d11111daaaaadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d1eee1da222adddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d1eee1da222adddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d1eee1da222adddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d11111daaaaadddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d22222dbbbbbdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d2eee2db333bdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d2eee2db333bdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d2eee2db333bdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d22222dbbbbbdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d33333dcccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d3eee3dcccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d3eee3dcccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d3eee3dcccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d33333dcccccdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d44444deeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d43334deeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d43334deeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d43334deeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d44444deeeeedddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d55555dfffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d50005dfffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d50005dfffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d50005dfffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d55555dfffffdddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d66666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d66666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d66666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d66666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d66666dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d77777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d77777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d77777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d77777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d77777dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d88888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d81118dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d81118dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d81118dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
d88888dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
__map__
1001020304050607080900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1011121314151617181900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2021222324252627282900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3031323334353637383900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
