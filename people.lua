-- setup -----------------------
people = {
	{
		name = "big beardy man",
		face = 0,
		skin_tone = 1,
		initial_laugh = {
			speed = 0,
			pitch = 0,
			fun = 0,
			length = 0,
		},
		desired_laugh = {
			speed = 2,
			pitch = 2,
			fun = 2,
			length = 0,
		},
		initial_prompt = {
			"hey there hahaha",
			"oops, hope i didn't scare you!",
			"my laugh scares everyone away...",
			"i want a cute, sweet little laugh, one that doesn't sound so scary",
		},
		adjustment_prompts = {
			pitch = {
				more = "well that just sounds like my old laugh!",
			},
			speed = {
				more = "i can't spend all my time laughing, i need to seize the moment",
			},
			length = {
				less = {"i was hoping my laugh wouldn't stick around",
				        "in and out like a flash!"},
			},
			fun = {
				more = "where's the verve! folks should know i'm enjoying myself",
			},
		},
		acceptance_text = "wow, that's perfect!! Now no one will know i'm a threat",
		rejection_text = "that's too bad, i really needed a new laugh. i hope they don't catch me",
		screen_pal = { [12] = -2, [14] = -7, [15] = 9 },
	},
	{
		name = "priest",
		face = 0,
		skin_tone = 1,
		initial_laugh = {
			speed = 2,
			pitch = 1,
			fun = 1,
			length = 0,
		},
		desired_laugh = {
			speed = 0,
			pitch = 0,
			fun = 0,
			length = 2,
		},
		initial_prompt = {
			"greetings my child",
			"may the lord bless you, as he blesses us all. hahaha",
			"i require a laugh, a powerful laugh, one to shake old lucifer's bones!"},
		adjustment_prompts = {
			pitch = {
				less = "give me something deep, to shake the very walls of jericho",
			},
			speed = {
				less = "calm yourself child, there's no need to rush",
			},
			length = {
				more = "i'm afraid that's not enough, child. i need a sermon, not a prayer!",
			},
			fun = {
				less = "please, some gravitas. immortal souls are at stake",
			},
		},
		acceptance_text = "a thousand blessings upon you!! now i can terrify everyone at the rectory",
		rejection_text = "god tests us all child, and we cannot always succeed",
		screen_pal = { [12] = 2, [14] = -7, [15] = -16 },
	},
	{
		name = "diver",
		face = 0,
		skin_tone = 1,
		initial_laugh = {
			speed = 1,
			pitch = 1,
			fun = 2,
			length = 0,
		},
		desired_laugh = {
			speed = 2,
			pitch = 2,
			fun = 0,
			length = 0,
		},
		initial_prompt = {
			"hey there! you're the first human i've seen in months, hahaha",
			"sure is dry up here",
			"i need a laugh for a dolphin comedy show, dolphin comedy is no laughing matter!"},
		adjustment_prompts = {
			pitch = {
				more = "i'm not going to a show for whales!",
			},
			speed = {
				more = "dontcha think that sounds more like a fire alarm than a dolphin?",
			},
			length = {
				less = "this feels too wild. i'm just the audience, it's not about me",
			},
			fun = {
				less = "please. this is very important to me. not just some joke",
			},
		},
		acceptance_text = {"that's amazing! I'll fit right in", "they'll never call me land lubber again"},
		rejection_text = {"no, no... this won't do at all...", "well, i guess there's always catfish cabaret"},
		screen_pal = { [15] = 12, [14] = -16 },
	},
	{
		name = "bobo the clown",
		face = 0,
		skin_tone = 1,
		initial_laugh = {
			speed = 2,
			pitch = 1,
			fun = 2,
			length = 2,
		},
		desired_laugh = {
			speed = 1,
			pitch = 1,
			fun = 1,
			length = 1,
		},
		initial_prompt = {
			"hey hey! i'm bobo, world famous entertainer and fun for all the family!",
			"no one takes me seriously! i need a sensible, reasonable laugh. a real goldilocks! hahaha"},
		adjustment_prompts = {
			pitch = {
				more = "i always felt more like a tenor than a baritone",
				less = "no no, that's squeakier than my nose!",
			},
			speed = {
				more = "is that dragging? i think it was dragging. don't drag my laugh, rupaul",
				less = "is that rushing? it sounds like rushing to me. don't rush my laugh, salman",
			},
			length = {
				more = "not much of a laugh, is it. more like a bark. could i have a little more?",
				less = "wow, that really goes on huh. on and on... just... keeps... going...",
			},
			fun = {
				more = "c'mon, it's a laugh. it's gotta be a little jovial!",
				less = "i want to laugh at the joke. not be the joke.",
			},
		},
		acceptance_text = {"finally! now i can do what i've always wanted", "be an undertaker, like my father"},
		rejection_text = "well, i guess everyone will keep laughing at ol' bobo...",
		screen_pal = { [12] = 8, [14] = -9, [15] = 12 },
	},
	-- {
	-- 	name = "bob",
	-- 	face = 0,
	-- 	skin_tone = 1,
	-- 	initial_laugh = {
	-- 		speed = 0,
	-- 		pitch = 2,
	-- 		fun = 1,
	-- 		length = 0,
	-- 	},
	-- 	desired_laugh = {
	-- 		speed = 2,
	-- 		pitch = 0,
	-- 		fun = 1,
	-- 		length = 1,
	-- 	},
	-- 	initial_prompt = "i want big laugh, yes, very big",
	-- 	adjustment_prompts = {
	-- 		pitch = {
	-- 			less = "i hate high-pitched laughs!!!!",
	-- 		},
	-- 	},
	-- 	acceptance_text = "wow so funny!!! thx bby",
	-- },
}

generic_adjustment_prompts = {
	speed = {
		more = "faster!",
		less = "slower!",
	},
	pitch = {
		more = "higher!",
		less = "lower!",
	},
	fun = {
		more = "more fun!",
		less = "more serious!",
	},
	length = {
		more = "longer!",
		less = "shorter!",
	},
}


-- state -----------------------
current_person_index = 0
adjustment_number = 0 -- 0 == 'initial prompt'
people_sequencing = {}
ready_for_next_person = false
current_emotion = "neutral"


-- functions -------------------
function shuffle_people_sequence()
	for i = #people_sequencing, 2, -1 do
		local j = flr(rnd(i - 1)) + 1
		people_sequencing[i], people_sequencing[j] = people_sequencing[j], people_sequencing[i]
	end
end

function current_person()
	return people[people_sequencing[current_person_index]]
end

function next_person()
	current_person_index = (current_person_index % #people) + 1
	if (current_person_index == 1) shuffle_people_sequence()
	adjustment_number = 0
	person_state = "entering"
	current_emotion = "neutral"
end

function init_people()
    head_y_offset = -128
	people_sequencing = {}
	current_person_index = 0
	adjustment_number = 0

	for i,_ in ipairs(people) do
		add(people_sequencing, i)
	end

	next_person()
end

function score_choice(choice)
	local person = current_person()

	local scores = {}
	for k,v in pairs(choice) do
		scores[k] = person.desired_laugh[k] - v
	end

	return scores
end

function biggest_error(scores)
	local largest_diff = 0
	local diff_params  = {}
	for k,v in pairs(scores) do
		local diff = abs(scores[k]) - abs(largest_diff)
		if diff > 0 then
			largest_diff = diff
			diff_params = {k}
		elseif diff == 0 then
			add(diff_params, k)
		end
	end

	return {abs_amount=largest_diff,
	        params=diff_params}
end

function get_adjustment_prompt(choice)
	local scores = score_choice(choice)
	local err = biggest_error(scores)
	local param = rnd(err.params)
	local direction = scores[param] < 0 and "less" or "more"
	local person = current_person()

	if person.adjustment_prompts[param] ~= nil and
	   person.adjustment_prompts[param][direction] ~= nil then
		return person.adjustment_prompts[param][direction]
	end

	return generic_adjustment_prompts[param][direction]
end

function accept()
	score += 1
	show_accepted(current_person().acceptance_text,
	              current_person().desired_laugh)
	person_state = "leaving"
	current_emotion = "laughing"
end

function reject()
	health -= 1
	if health == 0 then
		lose()
	end
	person_state = "leaving"
	current_emotion = "angry"
end

function choose(choice)
	if biggest_error(score_choice(choice)).abs_amount == 0 then
		accept()
		return
	end

	adjustment_number += 1
	if adjustment_number > max_adjustments then
		show_rejected(current_person().rejection_text)
		reject()
	else
		show_adjustment_prompt(get_adjustment_prompt(choice), choice)
	end
end
