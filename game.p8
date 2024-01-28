pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

#include face.lua
#include people.lua

-- set mem flags ---------------
poke(0x5F2D, 1)

-- setup -----------------------
max_health = 3
max_adjustments = 3

-- laughs ----------------------
-- speed, pitch, fun
laughs = {
    {
        {23, 58, 59},
        {50, 56, 57},
        {49, 54, 55},
    },
    {
        {30, 26, 29},
        {51, 38, 52},
        {21, 22, 53},
    },
    {
        {25, 46, 47},
        {43, 44, 45},
        {40, 41, 42},
    },
}

-- laugh durations -------------
laugh_durations = { 2, 1.25, 0.75 }

-- slide anim scale
slide_anim_scale = 0.02

-- Speech bubble dimensions ----
max_line_len = 28
max_lines = 4

-- fixed palette ---------------
pal({[0]=7, 0, -14, -12, -10, -1, 4, 5, 6, 15, 14, -8, [13] = -11}, 1)

function _init()
	update_mouse()
    timers = {}
    laughing = false
    animating = false
    current_laugh = nil
    started = false
    health = max_health
    score = 0
    lost = false

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

    -- Update timers.
    local i = 1
    while i <= #timers do
        if ((t() - timers[i].t0) >= timers[i].length) and (timers[i].cond == nil or timers[i].cond()) then
            timers[i].action()
            deli(timers, i)
        else
            i += 1
        end
    end

    if not started then
        if any_input() then
            started = true
            init_people()
        end
        return
    end

    if lost then
        if any_input() then
            restart()
        end
        return
    end

    if not (animating or saying) then

        if person_state == "entering" and head_y_offset == -128 then
            local frames = {}
            for i=-127, 0, 1 do
                frames[(128+i) * slide_anim_scale] = function() head_y_offset = i end
            end
            frames[129 * slide_anim_scale] = function()
                person_state = "in_shop"
                local person = current_person()
                show_initial_prompt(person.initial_prompt, person.initial_laugh)
            end
            animate(frames, 129 * slide_anim_scale)
            sfx(62)
        end

        if person_state == "leaving" and head_y_offset == 0 then
            local frames = {}
            for i=1,-128,-1 do
                frames[-i * slide_anim_scale] = function() head_y_offset = i end
            end
            frames[129 * slide_anim_scale] = function()
                next_person()
            end
            animate(frames, 129 * slide_anim_scale)
            sfx(63)
        end

        -- Grab and ungrab slider handles.
        if mouse.pressed then
            for _, slider in pairs(sliders) do
                local _, _, dist_to_bar = nearest_slider_value(slider)
                if dist_to_bar <= 3 then
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
                local v = nearest_slider_value(slider)
                if slider.value != v then
                    sfx(60)
                    slider.value = v
                end
            end
        end

        -- Press buttons.
        if mouse.pressed then
            for _, button in pairs(buttons) do
                if mouse_is_over_button(button) then
                    button.on_click()
                    -- sfx(61)
                end
            end
        end
    end

    if saying then
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
    end
end

function nearest_slider_value(slider)
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
    local dst_to_bar = max(max(
        abs(mouse.y -slider_handle_pos(slider, 1).y),
        max(slider_handle_pos(slider, 1).x - mouse.x)),
        max(mouse.x - slider_handle_pos(slider, 3).x))

    return nearest, nearest_dist, dst_to_bar
end

function animate(stages, t_end)  -- {delay(s) = action, ...}, delay(s) to set animating back to false
    animating = true
    for t, action in pairs(stages) do
        add_timer(t, action)
    end
    add_timer(t_end, function() animating = false end)
end

function lnpx(text) -- length of text in pixels
	return print(text, 0, 999999)
end

function mouse_is_over_button(button)
    return sqdst(mouse.x, mouse.y, button.x, button.y) <= (button.r * button.r) + 2
end

function draw_lose_screen()
    cls(11)
	local lost_text = "you lost!"
	local lost_text_y = 40

	local score_start_text = "you made "
	local score_end_text = " laughs"
	local score_text_y = 60
	local score_col = 0

	local replay_start_text = "PRESS "
	local replay_button = "ANY BUTTON"
	local replay_end_text = " TO CONTINUE..."
	local replay_text_y = 80
	local replay_col = 0

	color(10)
	print(lost_text, 64 - lnpx(lost_text) / 2, lost_text_y)

	local score_text_length = lnpx(score_start_text..score..score_end_text)
	print(score_start_text, 64 - score_text_length / 2, score_text_y)
	color(score_col)
	print(score, (64 - score_text_length / 2) + lnpx(score_start_text), score_text_y)
	color(10)
	print(score_end_text, (64 - score_text_length / 2) + lnpx(score_start_text..score), score_text_y)

	local replay_text_length = lnpx(replay_start_text..replay_button..replay_end_text)
	print(replay_start_text, 64 - replay_text_length / 2, replay_text_y)
	color(replay_col)
	print(replay_button, (64 - replay_text_length / 2) + lnpx(replay_start_text), replay_text_y)
	color(10)
	print(replay_end_text, (64 - replay_text_length / 2) + lnpx(replay_start_text..replay_button), replay_text_y)
end

function draw_start_screen()
    cls(11)

    color(14)
    print_centered("make m'laff", 60)
    color(0)
    print_centered("make m'laff", 59)

    color(14)
    if strobe(0.66) then
        print_centered("PRESS ANY BUTTON...", 100)
    end
end

function print_centered(text, y, offset)
    print(text, (128 - lnpx(text)) / 2 + (offset or 0), y)
end

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

    if not started then
        draw_start_screen()
        return
    end

	if lost then
		draw_lose_screen()
		return
	end

    draw_bg()

	-- health
    rectfill(9, 23, 22, 43, 0)
	local health_str = ""
	for i = 0, health - 1 do
		health_str = health_str.."♥\n"
	end
	print(health_str, 13, 25, 11)

    -- score
    rectfill(9, 2, 22, 20, 0)
	color(3)
    local offset = lnpx(score) + 12
    pset(offset + 1, 5)
    pset(offset + 3, 5)
    pset(offset, 7)
    line(offset + 1, 8, offset + 3, 8)
    pset(offset + 4, 7)
    print(score, 11, 4)

	-- Head
    camera(0, head_y_offset)
	draw_head(current_person().name, current_emotion)
    camera()

    -- Laugh maker
    rectfill(0, 98, 127, 127, 11)
    for name, slider in pairs(sliders) do
        print(name, slider.name_x, slider.y, 0)
        line(40, slider.y + 2, 80, slider.y + 2, 0)
        local h = slider_handle_pos(slider)
        rectfill(h.x - 1, h.y - 1, h.x + 1, h.y + 1, 10)
    end

    spr(69, buttons.submit.x - 8, buttons.submit.y - 8, 2, 2)
    if (mouse_is_over_button(buttons.submit)) then
        camera(0, 1)
        spr(69, buttons.submit.x - 8, buttons.submit.y - 8, 2, 2)
        camera(0, 0)
    end
    

    -- Speech bubble
    if saying then
        color(0)
        rectfill(7, 93, 120, 123)
        rectfill(4, 96, 123, 120)
        circfill(7, 96, 3)
        circfill(120, 96, 3)
        circfill(7, 120, 3)
        circfill(120, 120, 3)
        print("◆", 12, 90)

		print(sub(saying.paras[saying.para], 1, saying.char), 8, 97, 2)

		if saying_para_done() and strobe(0.66, t_para_completed) then
			print("♥", 109, 121, 5)
		end
	end

    -- person name
    local name = current_person().name
	color(2)
    print_centered(name, 3)
    print_centered(name, 3, -1)
    print_centered(name, 3, 1)
    print_centered(name, 4)
	color(0)
    print_centered(name, 2)

    -- Cursor
    color(1)
    circfill(mouse.x, mouse.y, 1)
end

function draw_45(x, y, col_top, col_bot, flip)
    if flip then
        for i = 0, 7 do
            line(x + i, y + i, x + 7, y + i, col_top)
        end
        for i = 0, 7 do
            line(x, y + i, x + i, y + i, col_bot)
        end
    else
        for i = 0, 7 do
            line(x, y + i, x + 7 - i, y + i, col_top)
        end
        for i = 0, 6 do
            line(x + 7 - i, y + i + 1, x + 7, y + i + 1, col_bot)
        end
    end
end

function draw_bg()
	cls(7)

    circfill(6.5 * 8, 0.5 * 8, 2, 2) -- handle
    circfill(6.5 * 8 + 1, 0.5 * 8 - 1, 1, 7)
    pset(6.5 * 8 + 1, 0.5 * 8 - 1, 9)
    rectfill(7 * 8, 0, 16 * 8 - 1, 4 * 8 - 1, 9) -- wall
    rectfill(7 * 8, 0, 8 * 8 - 1, 3 * 8 - 1, 7)
    rectfill(8 * 8, 3 * 8, 14 * 8 - 1, 4 * 8 - 1, 4)
    draw_45(14 * 8, 3 * 8, 9, 4, true)
    draw_45(15 * 8, 4 * 8, 4, 7, true)
    rectfill(8 * 8, 0, 14 * 8 - 1, 3 * 8 - 1, 8) -- window
    rect(8 * 8 - 1, -1, 14 * 8, 3 * 8 - 1, 7)
    rect(8 * 8, -1, 14 * 8 - 1, 3 * 8 - 2, 4)
    rect(8 * 8 + 1, -1, 14 * 8 - 2, 3 * 8 - 3, 9)
    pset(14 * 8 - 1, 3 * 8 - 2, 9)
    pset(14 * 8, 3 * 8 - 1, 4)
    line(8 * 8 + 1, 0, 8 * 8 + 1, 3 * 8 - 4, 4)
    line(8 * 8, 0, 8 * 8, 3 * 8 - 3, 7)
    line(8 * 8 - 1, 0, 8 * 8 - 1, 3 * 8 - 1, 2)

    -- floor
    rectfill(4 * 8, 4 * 8, 6 * 8 - 1, 5 * 8 - 1, 2)
    rectfill(4 * 8, 5 * 8, 5 * 8 - 1, 6 * 8 - 1, 2)
    draw_45(7 * 8, 3 * 8, 7, 4)
    draw_45(6 * 8, 4 * 8, 2, 7)
    draw_45(5 * 8, 5 * 8, 2, 7)
    draw_45(4 * 8, 6 * 8, 2, 7)

    rectfill(1 * 8, 7 * 8, 3 * 8 - 1, 8 * 8 - 1, 2)
    rectfill(1 * 8, 8 * 8, 2 * 8 - 1, 9 * 8 - 1, 2)
    draw_45(2 * 8, 8 * 8, 2, 7)
    draw_45(1 * 8, 9 * 8, 2, 7)

    rectfill(4 * 8, 0, 7 * 8 - 1, 4 * 8 - 1, 9) -- door
    line(4 * 8, 0, 4 * 8, 4 * 8 - 1, 7)
    line(4 * 8 + 1, 0, 4 * 8 + 1, 4 * 8 - 1, 4)
    pset(4 * 8 + 2, 4 * 8 - 9, 5)
    line(4 * 8 + 2, 4 * 8 - 3, 4 * 8 + 2, 4 * 8 - 7, 5)
    line(4 * 8 + 2, 4 * 8 - 3, 4 * 8 + 3, 4 * 8 - 3, 5)
    line(4 * 8 + 2, 4 * 8 - 2, 5 * 8 + 1, 4 * 8 - 2, 5)
    line(4 * 8 + 2, 4 * 8 - 1, 7 * 8 - 1, 4 * 8 - 1, 5)
    line(7 * 8 + 1, 0, 7 * 8 + 1, 4 * 8 - 1, 2)
    pset(7 * 8, 4 * 8, 2)
    line(7 * 8, 4 * 8 - 1, 7 * 8, 4 * 8 - 3, 2)
    line(7 * 8 + 2, 0, 7 * 8 + 2, 4 * 8 - 3, 9)

    -- shelves
    draw_rotated_clockwise(0, 0, 12, 1, 64, 0, true)
    rectfill(1 * 8, 0, 3 * 8 - 1, 8 * 8 - 1, 4)
    map(64, 1, 3 * 8, 0, 1, 8)
    spr(0, 3 * 8, 0)
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

function lose()
	lost = true
end

function play_laugh(laugh_params)
    if (laughing == false) current_laugh = laugh_params

    laughing = true
    local sound = laughs[laugh_params.speed + 1][laugh_params.pitch + 1][laugh_params.fun + 1]
    sfx(sound)
    local action = {}
    local length = laugh_durations[laugh_params.speed + 1]

    -- If length > 1, queue up laugh to replay again after it's over (with length - 1).
    if laugh_params.length > 0 then
        action = function()
            play_laugh({
                speed = laugh_params.speed,
                pitch = laugh_params.pitch,
                fun = laugh_params.fun,
                length = laugh_params.length - 1,
            })
        end
        length *= 0.75
    else
        -- If length = 1, queue up setting laughing = false after it's over.
        action = function()
            if laughing then
                music(1, 1000, 0)
            end
            laughing = false
            current_laugh = nil
        end
    end
    add_timer(length, action)

end

function add_timer(length, action, cond)
    add(timers, {
        t0 = t(),
        length = length,
        action = action,
        cond = cond,
    })
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

function show_rejected(text)
	say(text)
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
93333339ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddbbaa1ddddddddddddddd
96666339dddddddddddddddddddd6666669999666666665599905555ddddddddddddddddddddddddddddddddddddddddddddddddddaabbaa1ddddddddddddddd
95555669dddddddddddddddddd666555559999999999999995555555555dddddddddddddddddddddddddd55555555555dddddddddbaabbba11d1d1d11d2d2d22
99999999dddddddddddddddd6665555599999999999999999995555555555ddddddddddddddddddddd65559999999999900ddddddbbaabbadddddddddddddddd
93333999ddddddddddddddd6655555999999999999999999999999999955555dddddddddddddddddd6559999999999999900ddddabbbaddddddddddddddddddd
93333339ddddddddddddd66655555999999999999999999999999999999995555ddddddddddddddd655999990555559999900dddaaabdddddddddddddddddddd
93333339dddddddddddd6655555999999999999999999999999999999999999955dddddddddddddd655999900066655599990dddbaaadddddddddddddddddddd
93333339ddddddddddd6655555999999999999999999999999999999999999999955dddddddddddd6559999900666665599900ddbbbbdddddddddddddddddddd
93366669dddddddddd665555599999000009999999999999999999999999999999955ddddddddddddddddddddd555ddddddddddddddddddddddddddddddddddd
96655559ddddddddd66555559999900000009999999999999999999999999999999995dddddddddddddddddddd5555dddddddddddddddddddddddddddddddddd
95599999dddddddd6655559999990909000009999999999999999999999999999999999ddddddddddddddddddd25555ddddddddddd9dddddd2ddddddddddddd9
99999999ddddddd665555999999090090000009999999999999999999999999999999999dddddddddddddd5d22222255999ddddddd9ddddddd21ddddddddddd9
99955559dddddd66555599999909090900000009999999999999999999999999999999999dddddddddddd5555522222955a9ddddddd9ddddd11d9ddddddddd9d
95533339ddddd6665555999999099909000000099999999999999999999999999999999999dddddddddd25552252222dd25a9dddddd9dddd12d9a9dddddddd9d
93333339dddd666555599999990999990000000999999999999999999909999999999999990ddddddddd225552222222dd22dddddddd9dd2dd9aaa9dddddd9dd
93333369ddd66655555999999909999900000099999999999999999999099999999999999990ddddddddd2255522251111dddddddd111999999aaaa999999ddd
dddddddddd666655559999999999999900000099999999999999999999009999999999999990ddddddddddd225555177771dddddd11111d9aaaaaaaaaaaa9ddd
dddddddd666665555999999999999999000009999999999999999999990099999999999999000dddddddddddd22217777771dddd11221119aaaaaaaaaaaa9ddd
ddddddd6666655559999999999999999900999999999999999999999990009999999999999900dddddddddddddd1777717771ddd1dddd119aaaaaaaaaaaa9ddd
dddddd666655555599999999999999999999999999999999999999999900099999999999990900dddddddddddd177777117771dd1dddd219aaaaaaaaaaaa9ddd
ddddd6666555555999999999999999999999999999999999999999999090099999999999999000ddddddddddd17777771177771ddddddd19aaaaaaaaaaaa9ddd
ddddd6655555559999999999999999999999999999999999999999999000009999999999999990ddddddddddd17777771177771ddddddd29aaaaaaaaaaaa9ddd
dddd665555555999999999999999999999999999999999999999999990000009999999999999000dddddddddd17777771177771ddddddd29aaaaaaaaaaaa9ddd
ddd6655555599999999999999999999999999999999999999999999909000009999999999999900dddddddddd17777771177771dddddddd9aaaaaaaaaaaa9ddd
dd66555559999999999999999999999999999999999999999999999000000000999999999999900ddddddddddd177777117771ddddddddd9aaaaaaaaaaaa9ddd
dd65555599999999999999999999999995555599999999999999999090000000999999999909000dddddddddddd1777717771dddddddddd9aaaaaaaaaaaa9ddd
d6655559999999999999999999999999565555555555555599999099900000009999999999090000dddddddddddd17777771ddddddddddd9a333333333aa9ddd
d6655599999999999999999999999996659999999999999999999900000000000999999999090000ddddddddddddd177711dddddddddddd93bbb333bbbba9ddd
66555599999999999999999999999996599999999999999999990000000000000999999999000000dddddddddddddd111dddddddddddddd93bbbb3bbbbbb9ddd
66555599999999999999999999999966590999999999999000000000000000000999999909090000dddddddddddddddddddddddddddddddd93bbb3bbbbb9dddd
66555999999999999999999999999966500900000000000000000000000000000999999909090000ddddddddddddddddddddddddddddddddd9bbbbbbbb9ddddd
66555999999999999999999999999966500000000000000000000000000000000999999909090000ddddddddddddddddddddddddddddddddd999999999dddddd
dddddddddddfddffbdd1dddbddd7dddddddddddddddddaaaaaaddddddddddddddddddddddddddddddddddddddddddddddfffeddddddddaaaaaadddddbccccccc
ddddd1ddddddddffddd1ddddd7ddd7dddddddddddddaaaaaaaaaaddddddddddddddddddddddddddddddddddddddfdfefeffeefeedddaaaccccaaadddbccccccc
ddddddfdddddfddddd171dddddddddddddddddddddaaaaaaaaaaaadddddddddddddddddddddddddddddddddfddffdeeeeeeeeeefddacacccccaaaaddbccbcccc
dddddddddddfdfdd1177711d7ddddd7ddddd333ddaaa000aaa00aaaddddddddddddddddddddddddddddddddfdfeeefeefffeeeeedaaccccacaaccaaddbcccccc
dddffdddddddfddddd171dddddddddddddd13333daa0aaa0a0aa0aadddd6ddddddedddddddddddddddfddfffefeeeeeeeeeeefeedaccccccccccccaddbbbcbcc
dddffddddddddddfddd1ddddd7ddd7ddddd13333baa0aaa0a0aa0aaadddd66d6eeeddfdddddddddddfedeeeeeeeeeeeeeeeeeeeeacccacccccaacccaddbbbccc
d1ddddddddfdddddddd1ddddddd7ddddddd11331baa0aaaaa0aa0aaadddd66666eeeefdddddddddddeeeeeeeeeeeffeeeeeeeeeeacccccccccccccbadddbbbbb
1dddf1dddddfddddbddddddbdddddddddddd111dbaa0aaaaa0aa0aaaddddd666e6eeeedddddddddddeeeefeefeeeeeeeeeeeeeeeaccccccccccccccadddddbbb
900999999999999999999995dddd999999955555baa0a000a0aa0aaaddddd66eeee6eeefdfddddddefeefeeefeeeeeeeeeeeeeeeddddd9dddddddddddd9ddddd
999999999999999999999995dddd099999999555baa0aaa0a0aa0aaaddddd66666eeeeeeeefdddddeeeeeeeeeeeefeeeeeeeeeeedddddd999dd99dd999dddddd
099999111111111119999995dddd909999999955baa0aaa0a0aa0aaaddddddd66eeeeeeeeffdddddeeeeeeeeeeeeeeeeeeeeeeeedddddddd00000000dddddddd
999911155555555556999995dddd900999999955dbaa0000aa00aaadddddddddd66eeeeeeeefddddeeeeeeeeeeeeeeeeeeeeeeeeddddddadd0eeee0ddadddddd
991115555559999999999995dddd999999999995dbaaaaaaaaaaaaadddddddddd6666eeeeeefddddefeeeefeeeeeeeee6eeeeeeeddddd6ddd0eeee0d3333dddd
991155559999999999999999dddd999999999995ddbaaaaaaaaaaadddddddddddd6deeeeefeeddfdeeeeeeeeeeeeeeeeeeeeeeeeddddddd6650ee033334433dd
995555999900999999999999dddd999999999995dddbbaaaaaaaaddddddddddddddd6eeeeeeeeeffeeeeeeeeeeeeeeeeeeee6e6eddddddddddd00334dddd533d
995555500000000999999999dddd999999999955dddddbbbbbbbdddddddddddddddd66eeeeeeeeffeeeeeeeeeeeeeeeeee6edd6ddddddddd333334ddd5dddd53
555555111111115599999999dddd999999999999bbbbbbbaaaaaaaaadddddddddd66655555999999eeeeeeeeeeeee6ee6d6dddddddddddd334444dddddd5dddd
555551111101555559999999dddd999999995559dbbbbbbbbbbbbbbbddddddf11116665555599999eeeeee6eeeeeee6ed999999ddddddd334ddddddddddddddd
555551110101599999999999dddd999995666666ddbbaabbaaaaaaaaddddddf11111666555555599ee6e6eeee6e6edd99999999ddddddddddd5d55dddddddddd
555551111155999999999999dddd999995500000dddbbaabaaaaaaaaddddddf11111116655555555e66de6e6eee6999999999ddddddddddddddddddddddddddd
555555111559999999999999dddd999955959999ddddbbaabaaaaaaaddddddf11111111665555555d6dddd66d66d999999dddddddddddddddddddddddddddddd
559999999999999999999999dddd999999995555dddddbbaaaaaaaaaddddddf11111111166665555ddddd9ddd999999ddddddddddddddddddddddddddddddddd
559999999999999999999999dddd999999999995ddddddbbaaaaaaaaddddddf11111111111666666dddd9999999ddddddddddddddddddddddddddddddddddddd
599999999999999999999999dddd999999999995dddddddbbaaaaaaadddd11f11111111111886666dddddd999ddddddddddddddddddddddddddddddddddddddd
599999999999909999999999dddd999999999955dddddddddddddddd1111111f1111111111888888dddddddddddddddd000000776766eeeeeee66efecccbccba
599999999900000999999999dddd599999900000dddddddddddd111111111111ff11111111880000ddddddddddddd00000008887776766e6eeeeeee6bccccccb
559999990000000099999999dddd559999000000ddddddddd1111111111111111fff111111800000dddddddddd000000000888888777767766eee6eeccccccbb
559999990000000009999999dddd555990999000ddddddd111111111111111111111f11111800000ddddddd000000888888888888888877777667666cccbcbbd
559999990000000000999999dddd555999999999ddddd111111111111111111111111f1111800000ddddd88088888888888888888888888887777777cbbbbbbd
559999990000000000099999dddd555599999999ddddd11111111111111111111111111f11888000ddddd88888888888888888888888888888777888bcbbbbdd
659999900000000000099999dddd555599999999ddddd11111111111111111111111111111111111ddddd88888888888888888888888888888877888bbbbbddd
599999900000000000099999dddd655559999999ddddd11111111111111111111111111111111111ddddd88888888888888888888888888888877888bbbddddd
3333dddddddddddddddd22233677774744444444444444444444444444444444223366dddddddddddddddddddddddddd66fddddd900dd0d0000ddddddddddddd
33333dddddddddddddd22336677774444444444444444444444444444444444442233366dddddddddddddddddddddde6ffefff999999999dd0dddddddddddddd
333633dddddddddddd2233677774444444444444444444444444444444444444444223366ddddddddddddddddddddeeeefeeeeff9999dddddddddddddddddd66
3333633dddddddddd223367774474444444444444444444444444444444444444444223366ddddddddddddddddddddeeeefeeefeffed9dddddddddddefded66e
33363663dddddddd22336777444444444444444444444444444444444444444444444223366dddddddddddddddddddeeeeeeefeeeeefedddddddddffffef6ee6
333366363dddddd1233677747444444444444444444444444444444444444444444444223366dddddddddddddddddddeffeeeeefeeeeeeeeedddfeffffffeee6
3366666633dddd113367747444444444444444444444444444444444444444444444444223366ddddddddddddddddd6eeeeeeeeeeeeeffffefeefeefeeeeeee6
3336666663dddd1336774744444444444444444444444444444444444444444444444444223366ddddddddddddddd66eeeeefefeeefeeeeeffffeeeeeeeeee6e
3366666663dd111367747444444444444444444444444444444444444444444444444444422366dddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeefe
3366666633311136777744444444444333366666633444444444444444444444444444444423366ddddddddddddddd6eeeeefeeeeeeeeeeeeeeeeeeeefeeeffe
36666663633113367744444444443333333333366633344444444444444444444444444444223366ddddddddddddddddeeeeeeeeeeeeeeeeeeeffffffffffffe
36666666331133677474444443332222222222223366634444444444444444444444444444422366ddddddddddddddd6eeeeeefeeeeeeeeeeeeeeeeeeefffffe
366666633113367777444444322222388888888882336632444444444444444444444444444423366dddddddddddddd6eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
336666632113367744444432222388888888888888823366244444444444444444444444444422366ddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeef666
366666331133677474444222288888888888888888277423624444444444444444444444444442336dddddddddddddddeee66eeefeeeeeeeeeeeeeeeeeeeef66
3666663211336777444422237777448888888888227227723624444444444444444444444444422366dddddddddddddd66eeeeeeeeeeeeeeeeeeeeeeeeeeefff
3666633211367747444222227222274888888882774882272363244444444444444444444444472366ddddddddaacddddd6eeeeeeeeeeeeeeeeeeeeeeeeeeefe
3666332213367774442222274888827888888827788888827236324444444444444444444444772222222ddddaaaacddddd6eeeeeeeeeeeeeeeeeeeeeeeeeeee
36663221133674444222227888888827888882778888888274236324444444444444444444447722224447ddaabaacddddeeeeeee6eeeeeeeeeeeeeeeeeeeeee
36633221336777444223274888888882788882788888888824823632444444444444444444444772244447ddabbbaccadd6ee6eeeeeeeeeeeeeeeeeeeeeeeeee
366332213667444422382788888888882788278888888888248826632444444444444444444447724477447dbbbbaccadddd6eeeeeeeefeeeeeeeeeeeeeeeeee
366322113677744223888248888888888272748888888882748823663444444444444444444447724782747dbbbaaccadddd6eeeeeeeeeeeeeeeeeeeeeeeeeee
366322113674744226888278888888888227488888888882788882363244444444444444444477244782744dbaaacccaddddd6eeefeeeeeeeeeeeeeeeeeeeeee
366322133677442238888824888888888877888888888827488882366344444444444444444477247888274dbaccccaadddddd6eeeeeeeeee6eeeeefefeeefee
3663221336744422688888278888888882727888888882748888882363444444444444444447772478882747acccbbacdddddd6eeeeeeeeeeeeeeeeeeeffffff
3633211366774423888888824888888827482488888827488888882363244444444444444447772478882744ccbbbaacddddddd66eeeeeeeeeeeeeeeeeeeefff
3632211367744226888888827488888274882788888274888888882363244444444444444447724788888274ccbbbaccddddddddde6ee6eeeeeeefeeefeeeeff
3632213367744238888888882748888248888278888248888888888363324444444444444447724788888274ccbbaaccddddddddd6eeeeeeeeeeeffeeeffefee
3632213367744238888888888278882788888827882788888888888366324444444444444447724788888274ccaaaacddddddddddd6deeeeee66e6eeefeefeee
3332213367744238888888888827827488888882424888888888888366324444444444444447724788888274ccaaaccdddddddddddddd6eeeefe6ee6eeeeeeee
2222213367744238888888888827427888888882777888888888888366324444444444444447724788888274dcccccdddddddddddddddddeeefeeeeeee6e6e66
2222213367744238888888888882778888888888274888888888888366324444444444444447724788888274dccccddddddddddddddd7776eeeeeee66e66eee6
dddddddddddddddddddddddddddddddddddddddddddddddddd00dddddddddddddddddddddddddddddddddddddddddddd9333365993336922dddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddd000ddddddddd3333ddddddddd888888888888888888ddd9333659993336922dddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddd000dddddd3dddd333dddd8800000000000000000088d9336599993335922dddddddddddddddd
dddddddddddddddddddddddddddddddddddddddddddddddddddddd000ddd3dddddddd3ddd8008888888888888888008d9365999993365922dddddddddddddddd
dddddddddddddddddd2227777777774ddddddddddddddddddddddddddddddddddddddd3d8008ddddddddddddd33380089655553953369222dddddddd000ddddd
dddddddddddddddd22244444444444447dddddddddddddddd00ddd00dddddddddddddddd808dddddddddd3333bbb38089555533953369222ddddddd00d00dddd
ddddddddddddddd2277774444444444447dddddddddddddddd00d00ddddddddddddddddd808ddddddddd3bbbbbff38089555336953359222ddddddd0ddd0dd0d
dddddddddddddd227777774444444444447dddddddddddddddd0d0dddddddddddddddddd808ddddd55dd3bbbffffd8089553336953659222dddddd003330000d
dddddddddddddd277777777777777774447ddddddddddddddddd0ddddd6666dddddddddd808dddd55ddd2333333fd8089533365953692222dddddd0d111d00d0
dddddddddd22222272222222222236777766ddddddddddddddd0d0ddd622266ddddddddd808dddd566666666666fd8089333369953692222ddddd00ddd1d0000
ddddddd22222eeeeeee22222222222333333666ddddddddddd00d00d65555266d6dddddd808dddd56aaaaaaaaa6fd8089333659956592222ddddd0ddddddd00d
dddd222222eee6666677777777772222222333666dddddddd00ddd005777752666dddddd808ddd5566666666666ff8089333699956592222dddddddddd1ddddd
ddd2222eee666777777777777777777772222333666dddddddddddd577777752666ddddd808ddd5d6eeeeeeeee6ff8089336599956922222dddddddddddddddd
d2222ee6677777777774744744444444447722233366dddddddddd5777777775dddddddd808ddd5d6eeeeeeeee6ff8089336553956922222dddddddddd1ddddd
222ee66777777774444444444444444444444422233366dddddddd5777777775dddddddd808ddd5dd6eeeeeee62ff8089365533955922222dddddddddd1ddddd
22ee6777777744444444444444444444444444442223366ddddddd5777777775dddddddd808ddd5dd2688e8886dff8089365536955522222dddddddddddddddd
ddddddddddddddddddddddfdddddddddaaaaaaaadddddddddddddd5777777775dddddddd808ddd5ddd26888862dff8089655336955222222dddddddddd1ddddd
ddddddddddddddddddddddddddddfdddbbbbbbbddddddddddddddd5777777775dddddddd808dd55dd55268862ddff8089655336955222227dddddddddddddddd
dddd1dddddd1dddddddddddddddfdfddaaaaaaddddddddddddddddd57777775ddddddddd808dd5dd55dd2662dddff8089553335955222277dddddddddd1ddddd
dddddddddd1d1dddddddddddddddfdddaaaaaddddddddddddddddddd577775dddddddddd808dd5555dddddddddddf8089553365955222777dddddddddd2ddddd
dddddfddddf1dddddddddddffdddddddaaaaddddddddddddddddddd5d5555ddddddddddd808dddd5ddddddddddddf8089533369252227777dddddddddddddddd
dddddd111fdfddddddddddfddfddddddaaaddddddddddddddddddddd5ddddddddddddddd808dddd55ddd2222ddddd8089533369252277777dddddddddd2ddddd
dddddd1d1dfdddddddddddfddfddddddaaddddddddddddddddddddddd555eeeedddddddd888ddddddd22dddd2dddd8889333359252777777dddddddddddddddd
dddddf111dddddddddddfddffdddddddadddddddddddddddddddddddddeeeeeeeddddddddddddddddddddddddddddddd9333659257777777dddddddddddddddd
ddddfdfddddddddddddfdfdddddfdddd599999999999999999999999999999999999999999999999999999999999999999992222222222222777777777777777
dddddfddddddddddddddfddddddddddd599333365999333659993333659999333365999993336666599999999333336665599999222222222277777777777777
dddddddddd1ddddddddddddddddddddd599333365999333659993333659999333336599995333336665999999553333336666559999922222227777777777777
dddfddddfdddddddddddddfddddddddd593333365999333659993333665999533333659995533333366659999555533333333666655999992222777777777777
dddddddddddddddddddddfdfdddddddd553333365999333659993333365999533333365995553333333666599555555333333333366665599999577777777777
dddddfddddddddddddddddfddddddddd553333365999333369995333366599553333336595555333333336665555555553333333333336666559995577777777
ddddd1ddddddddddddddfddddddddddd533333665999333369995333336599553333333655555533333333366655555555533333333333333666655555557777
dddddddddddddddddddddddddddddddd533333665999333369995333336659555333333365555553333333333666555555555333333333333333366665555555
__label__
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooo777o777o7o7o777ooooo777oo7oo7ooo777o777o777ooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooo777o7e7o7o7o7eeooooo777o7eoo7ooo7e7o7eeo7eeooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooo7e7o777o77eo77oooooo7e7oeooo7ooo777o77oo77oooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooo7o7o7e7o7e7o7eoooooo7o7ooooo7ooo7e7o7eoo7eoooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooo7o7o7o7o7o7o777ooooo7o7ooooo777o7o7o7ooo7ooooooooooooooooooooooooooooooooooooooooooooo
ooooooooooooooooooooooooooooooooooooooooooeoeoeoeoeoeoeeeoooooeoeoooooeeeoeoeoeoooeooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooeeoeeooeeeooeeooeeooooooeeoeeooeoeoooooeeooeoeoeeeoeeeooeeoeeoooooooooooooooooooooooooooooooooooooooo
ooooooooooooooooooooooooooeoeoeoeoeeooeoooeoooooooeoeoeoeoeeeoooooeeooeoeooeoooeooeoeoeoeooooooooooooooooooooooooooooooooooooooo
ooooooooooooooooooooooooooeeeoeeooeoooooeoooeoooooeeeoeoeoooeoooooeoeoeoeooeoooeooeoeoeoeooooooooooooooooooooooooooooooooooooooo
ooooooooooooooooooooooooooeoooeoeooeeoeeooeeooooooeoeoeoeoeeooooooeeeooeeooeoooeooeeooeoeooeoooeoooeoooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

__map__
010102030405060708090a0b0c808182838485868788898a4d4e8b8c8d8e8f000000000000000000000000000000000000000000000000000000000000000000f4f5f6f7f8f9fafbfcfdfeff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111213141516171819474849909192939495969798999a4f7f9b9c9d9e9f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
20212223242526272829575859a0a1a2a3a4a5a6a7a8a9aa00008aacadaeaf00000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30313233343536373839000000b0b1b2b3b4b5b6b7b8b9ba00008abcbdbebf000000000000000000000000000000000000000000000000000000000000000000cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50515253540101676869000000c0c1c2c3c4c5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
60616263647576777879000000d0d1d2d3d4d5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ec000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70717273740000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ed000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e1000200302000000270202c0001d0201b02005000160200000000000110201102000000140200000000000030200000027020390001d0201b020050001602000000000000d0200d0200a0000f0200f02000000
0e1000200302000000270202c0001d0201b02005000160200000000000110201102000000140200000000000030200000027020390001d0201b02005000160200000000000110201102000000140000000000000
921000203a62002200046000b6403a6203a6000020003300107000c6000b6403a6003a6200000000000000003a62002200046000b6403a6203a600002000330000000000000b6403a6003a620376003d6103b600
721000200a3100c3101031016310073100a3100e310123100a3100d3100f31013310073100a3100f310123100c31010310153101c31011310153101a3102131015310183101c31022310173101a3101e31025310
4a1000203a62002200046000b6403a6203a6003060021600256000c6000b6403a6003a6200000035620336003a62002200046000b6403a6203a600002000330000000000000b6403a6003a620000003d61000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
490800201b040240001d040000002104023000170402500023040320000f0400500020040160001d0402200020040240001804024000200400000014040000001f04021000230401500016040000001c04000000
4110000017550245001e550000001755000000327000050000000000000d500000000000011550357000c5501150014550155000a50000000000001e55000000000000b5001c500000001c550000000000000000
30100000000000300006000090000c0000d00010000110002832011000100000d0000a00008320050000400004000040000400004000060001132008000090000900008000080002132005000040000100001000
000400000000003010080200b0200c0300c0400b0400a05006050080500a0500c0500c050070500a0500b05007050060500b0500f0500f0500f0500d05006050060500c0500c05006050060500b0400403003010
0004000005010090200d02009030080400a0500b0500a050070500a0500c0500c0500b05009050090500b0500c0500b0500605008050090500a0500905007050070500805006050050500b040090300402003010
90040000200101f0102003024040200501f0502205025050210502305026050220501f0502005022050230502005021050210501f0501e050200502005020050220502405022050230502304021030200101f010
480400001f010200101d0301c0401d0501c0501c050200501d0501c05020050210501f0502205022050200501e050220502405023050210501e05021050220502105022050220502305022040210301f0101f010
9004000030010330103302030030320403405033050310503305035050320502f05032050310502f0503005034050310502f05033050360503305030050310503305031050300502f04030030320103201031010
900400003001031010300202e0402f05031050330502f0503105031050310503505037050370502f0503205034050310502c0502f0502f0503305036050350503505037050350503404034030310203601032010
080200001f110201202313025120281202b1102d1102e1102e1202e1202b12028120261202412023120231102411026110281102a1202c1302d1302b130281302612025120241202412024120241202412023120
010800001b1001d1002010022100261102a1402e1503315035140371403713036120347103271000000000001e1002210025120291502c1502e150301503015031150301502f1302d1302c1202b1102911028110
480200000f3001230014300173001b3001f3002230026330263502535023350213501e3501e3401d320193001830018310183201a3401c3401e3501f350213502235022350203501f3501d3401b3301832017310
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
480200002e720317303674038740397503875037750317402e7302b7202a7402d740307403375034750357503475032750307502d7502b750287402774027730287402b7502e7502f7402d730297202771026710
00050000353002e7502e7502d7501f30010300043002d7502c7502b7502e3001f300013002a75029750287502a700003002875027750267503f300323002a300277502675025750257001d7001f3001a70019700
080500002a7502d7502e7502e7502b7000f4002b7002b7502b750297502d7002c70027700287002675025750247502a7002a7002970024700217502275020750077002870028700287001f750207501f7501e700
4c08000011770107700000000000000000000007700067000b7700a77007700077000000007700097700877000000000000000000000077700677005700057000000000000067600576004760000000000000000
000600001305015050140501305011050100500000000000000000000000000090500a0500b0500b05008050000000000000000000000000000000060000600009000090000a0000605007050080500605000000
00030000093500a3500a3500935000000063000735007350063500000000000063000635005350043500000000000003000435004350043500530001300013000435003350033500330000300000000000000000
9c0500000a3500a3500a350093500740000000083500a3500835008350000000d4000d40007350073500635005350054000640005350043500335003350034000340004350043500335002350044000000000000
010400000000034250322503125030200332503125030250302500000031250302502f250000002f2502e2502d250000002f2502d2502c250302002d2502c2502b250292002b2502a250292502d2002b2002b200
140a000017650136500e6500b6002a600256000f6500e6500d650000000000000000000000b6500b6500b6500a6500a6500965008650086500765007650076500765008650096500965009650000000000000000
58060000093500b3500c3500b35009450000000940004350073500435003450000000c3500d350093500245001400000000000000000034000235001450014500000000000024000240001350004500000000000
480500000616007160071600616006100091000910006100061000416005160051600416004100041000310005160051600416004100031000310004160031600316002100021000210002160021600116000000
080300003755036550365003350028500345503255032500305002f50031550305502d5002b5002f500305502e55000000000002e5002d5502c5500000000000000002c5002b50000000000002a5002950000000
00060000311502f1502e7502d100000002b15029150277502b1002b10028150271502675026100000002715025150241502315023150227502210022100221002210000000000000000000000000000000000000
0003000021250202501f2501d2301e1001f100201002625025250232502325000000000002925027250272500000000000302502f2502d2502c25000000000002d200292502a2402924028250252002220022200
00050000394503845036450144002240033400364503545032450344003340032400334003245031450304502e4002e400000002e4502d4502d450000002e4002d4502c4502b4500000000000000000000000000
000300001b4001b4001b4001c4501e4501c25019250162502c7002c70016450164501845019450172501625029700000000000016450194501a4501c450192501625015250297002870027700267000000000000
000400000d250212501025013200000000000000000000000b250222501125000000000000000000000000000000009250212500c250000000000000000000000000000000000000000000000000000000000000
000700001b0501a050190502c2001a150181501815018100192501825018250180001835017350163500000018450164501645000000175501555015550197001770017750167501575000000000000000000000
50050000164501745018450152501425000000000000000000000114501245013450112501025000000000000f45010450114500e2500c250000000000000000094500b4500c4500925007250000000000000000
580500000c0000d0001745016450144500e2500c25006200000000900017450164500e2500d2500b25000000000000000015450134500c2500b250092500000006400064500d2500925007250062500000000000
000300003655035550354000000000000345503355000000000000000033550325500000000000000003355032550000000000031550305502b50019500015000000000000000000000000000000000000000000
080300003b2503925038250000003f2003c2503b2503925000000000003a250382503725030200000000000033250322503125033200000003325032250302503220030200302000000000000000000000000000
1603000038440363403434000000364003540000000314402f3402f340364003540000000000000000000000314402f3402d340000000000039400394403a4403b4403934038340334002e4002f4402d3402c340
0003000024570235702357000000000000000022560215602550000000000001f5601e5601e50023500225001e5501d5501b50000000215001b5601a5601a5001950000000205001e5001d500000000000000000
080300001d2601f2701e250000001f2001d2001d2501b25000000000001e2001d2301a2301820000000000001a250192501a20000000182501725017250152501620015200142000000000000000000000000000
140300001f4502345024450203501e35000000000001d4501f4501a35019350163000000016450184501535014350164001845014350123501230016450194501535013350133501235012350143500000000000
08030000054500a4500d350093300d5000d50008500064300a350083300b500095000950003430053500435004330000000000006500014500335002340065000650006500004500135000330013000000000000
140300000b250102501325015250102500b4500645004200000000a2500925006450034000820008200092500825006250092000c2000a2000820007250062500625003250052000720007250042500325002250
000600003475036750330503105032500000000000000000327503375031050300502f0002e500305000000000000000000000033500347503575033050310503100032000000000000000000000000000000000
4808000034050330503100000000000000000000000330403204031000310000000000000000000000032040310402f0002f0000000000000000000000032040310402f000000000000000000000003103030030
480800001f7701e7701d7000000000000047001d7501c7501d700000000000000000000001b7501a7501b70000000000000000000000000001a750197501c700000000000000000000001a760197601b70000000
480500001f4001445015450142501325012250152001a4001a400134501445013250122501125018200000001240012450134501325012250112501b400184001a400114501245011250102500f2501220000000
10050000174501a4501d45016250142501225010400124001245014450164501325011250102500000012400144501645019450142501225011250000000c4000f4000c45011450154500f2500b2500a25000000
10050000310503205035050387503875038750000002e7002e7502d7502b700000002d7002c7502a7502970029700000002b75029750287502470000000277502675025750257502570000000000000000000000
0808000034050330503000030000000003000031050300502e000000002f000300502e0502d0500000000000000002c0002f0502e0502d0502d000000000000000000000002d0402c0402b050280000000000000
1008000039050380503873038720397103a70033020350503505033000000000000035000310503305033050000000000000000000003100032050330502f0002e0003005032050390002f000300503105000000
080900001e0501f7502370021700000001d0501c0501b750197001b7000000000000000001b7501a7501970000000000001a7001a750197501875000000000000000018750177501670000000000000000000000
100800001c0501b0501b7501c750197001e7000000000000000001c7501b0501a050000000000000000000001a000190001b75019050000001900019750180500000000000187501705000000000000000000000
9c08000013750190501a05018030167100000000000000000f7500e7500d7500f7000000000000000000c7500b7500000000000000000b7500a75000000000000000009750087500000000000000000000000000
a4090000185301a7601a760187601674000000000001775016740147300000000000000001703017760167501475013700000000000013740127301370012700137301172012700127201172000000107100f710
5e0500000c64002340185400a7001070032700000001ff000000000000000001e800000000000021b000000000000000001fd000000000000000001fe00000002ef0000000000000000000000000000000000000
4a0600000c660003600a36020760186600d760265602d560345703b570285002c5003150031500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4802000001750017500275003750047500575007750087500a7500b7500c7500d7500f750107501275013750147501675017750197501a7501c7501f750227502375025750287502a7502c7502f7503275035750
48020000377503775037750367503675035750347503475033750327503275031750307502f7502e7502d7502c7502a750287502675023750207501d7501a7501875015750117500f7500b750087500575002750
__music__
01 01420344
02 4102034a
01 4107053d
03 08070509
01 0a4e4f44
02 0b505152
03 14424344
00 18424344

