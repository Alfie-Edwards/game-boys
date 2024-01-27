pico-8 cartridge // http://www.pico-8.com
version 41

__lua__
max_line_len = 30
max_lines = 6

function _init()
    pal_light_red()

	init_people()

	print("current person is "..current_person().name)

	choose({
			speed = 2,
			pitch = 2,
			fun = 0,
			length = 0,
	})

	choose({
			speed = 2,
			pitch = 0,
			fun = 0,
			length = 1,
	})

	choose({
			speed = 2,
			pitch = 0,
			fun = 2,
			length = 1,
	})

	-- win
	choose({
			speed = 2,
			pitch = 0,
			fun = 1,
			length = 1,
	})

	-- -- lose
	-- choose({
	-- 		speed = 1,
	-- 		pitch = 0,
	-- 		fun = 1,
	-- 		length = 1,
	-- })

    saying = wrap("ADUHIUFHEI HFIJFNLKJSDNKLJFNSKLJFNFSEHFKSJENFKJSENFKJENKFNSJENF Lorem Ipsum \nis simply dummy text of the printing and typesetting industry.")
end

function _update60()
    if not saying.done then
    end
end

function _draw()
    cls(4)

    color(5)
    rectfill(5, 87, 122, 125)
    rectfill(2, 90, 125, 122)
    circfill(5, 90, 3)
    circfill(122, 90, 3)
    circfill(5, 122, 3)
    circfill(122, 122, 3)

    color(1)
    print(saying, 4, 89)
end

function wrap(text)
    local lines = {}
    for _, para in ipairs(split(text, "\n")) do
        add(lines, "")
        for _, word in ipairs(split(para, " ")) do
            if (#lines[#lines] + #word + 1) > max_line_len then
                if #word > max_line_len then
                    local i = max_line_len - #lines[#lines]
                    lines[#lines] = lines[#lines]..sub(word, 1, i).." "
                    i = i + 1
                    while i <= #word do
                        add(lines, sub(word, i, i + max_line_len - 1))
                        i = i + max_line_len
                    end
                else
                    add(lines, word)
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

function pal_light_red()
    pal(0, 0)
    pal(1, 2)
    pal(2, -8)
    pal(3, 8)
    pal(4, 14)
    pal(5, 7)
end

function lose()
	print("lose!!!!!!!!!!!!!!!!!!")
	print("your score was "..score)
end

function show_face(face_idx, skin_tone)
	print("set face to idx "..face_idx..", skin tone "..skin_tone)
end

function show_name(name)
	print("set name to "..name)
end

function show_initial_prompt(prompt, initial_laugh)
	print("set prompt to initial: "..prompt)
end

function show_adjustment_prompt(prompt, chosen_laugh)
	print("set prompt to adjustment: "..prompt)
end

function show_accepted(text, correct_laugh)
	print(text)
end

#include people.lua

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000