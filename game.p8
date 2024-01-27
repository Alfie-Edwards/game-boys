pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

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

function show_accepted(text)
	print(text)
end

#include people.lua

function _init()
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

end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
