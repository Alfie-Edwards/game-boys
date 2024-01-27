-- setup -----------------------
people = {
	{
		name = "bob",
		face = 0,
		skin_tone = 1,
		current_laugh = {
			speed = 0,
			pitch = 2,
			fun = 1,
			length = 0,
		},
		desired_laugh = {
			speed = 2,
			pitch = 0,
			fun = 1,
			length = 1,
		},
		initial_prompt = "i want big laugh, yes, very big",
		adjustment_prompts = {
			pitch = {
				less = "i hate high-pitched laughs!!!!",
			},
		},
	},
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

max_health = 3
max_adjustments = 3

-- state -----------------------
health = max_health
score = 0
current_person_index = -1
adjustment_number = 0 -- 0 == 'initial prompt'

people_sequencing = {}


-- functions -------------------
function shuffle_people_sequence()
	for i = #people_sequencing, 2, -1 do
		local j = flr(rnd(i - 1)) + 1
		people_sequencing[i], people_sequencing[j] = people_sequencing[j], people_sequencing[i]
	end
end

function current_person()
	return people[current_person_index]
end

function set_person(person)
	set_face(person.face, person.skin_tone)
	set_name(person.name)
	set_prompt(person.initial_prompt)
end

function next_person()
	current_person_index = ((current_person_index + 1) % #people) + 1
	if (current_person_index == 1) shuffle_people_sequence()
	set_person(current_person())
end

function init_people()
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

function win()
	score += 1
	print("you did it! score is now "..score)
	adjustment_number = 0

	next_person()
end

function lose_health()
	health -= 1
	print("ouch! health is now "..health)
	if health == 0 then
		lose()
	else
		next_person()
	end
end

function choose(choice)
	if biggest_error(score_choice(choice)).abs_amount == 0 then
		win()
		return
	end

	adjustment_number += 1
	if adjustment_number > max_adjustments then
		lose_health()
	else
		set_prompt(get_adjustment_prompt(choice))
	end
end
