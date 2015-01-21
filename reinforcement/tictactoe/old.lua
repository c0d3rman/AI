require 'xlua'
local Brain = require 'deepqlearn'

Brain.init(9, 9)

nb_train = 1000
nb_test  = 1000

torch.setnumthreads(100)
before = os.time()

function initField()
	field = {
		0, 0, 0,
		0, 0, 0,
		0, 0, 0
	}
end

initField()

-- all possible winning states
lookup = {
	{1,2,3},
	{4,5,6},
	{7,8,9},
	{1,4,7},
	{2,5,8},
	{3,6,9},
	{1,5,9},
	{3,5,7}
}

-- checks if game is over, rewards winner, and resets field
function isGameOver()
	-- lets check each state
	local winner
	for i, v in ipairs(lookup) do
		if field[v[1]] == field[v[2]] and field[v[1]] == field[v[3]] then
			winner = field[v[1]]
		end
	end
	if winner == 1 then
		local reward = 10
		Brain.backward(reward) -- learning magic happen
		initField()
		return true
	elseif winner == 2 then
		local reward = -10
		Brain.backward(reward) -- learning magic happens
		initField()
		return true
	else
		fieldFull = true
		for i = 1, #field do
			if field[i] == 0 then
				fieldFull = false
				break
			end
		end
		if fieldFull then
			local reward = -1
			Brain.backward(reward) -- learning magic happens
			initField()
			return true
		end
	end
	return false
end

function isGameOverTest()
	-- lets check each state
	local winner
	for i, v in ipairs(lookup) do
		if field[v[1]] == field[v[2]] and field[v[1]] == field[v[3]] then
			winner = field[v[1]]
		end
	end
	if winner == 1 then
		wins = wins + 1
		local reward = 10
		Brain.backward(reward) -- doesn't learn but needs the shock
		initField()
		return true
	elseif winner == 2 then
		losses = losses + 1
		local reward = -10
		Brain.backward(reward) -- doesn't learn but needs the shock
		initField()
		return true
	else
		fieldFull = true
		for i = 1, #field do
			if field[i] == 0 then
				fieldFull = false
				break
			end
		end
		if fieldFull then
			ties = ties + 1
			local reward = -1
			Brain.backward(reward) -- doesn't learn but needs the shock
			initField()
			return true
		end
	end
	return false
end

function displayField()
	print(field[1] .. " | " .. field[2] .. " | " .. field[3])
	print("---------")
	print(field[4] .. " | " .. field[5] .. " | " .. field[6])
	print("---------")
	print(field[7] .. " | " .. field[8] .. " | " .. field[9])
	print("")
end


print("Training")
for k = 1, nb_train do
	xlua.progress(k, nb_train)
	--print("*****   " .. k .. "   *****")
	while not isGameOver() do
		local state = table.copy(field) -- make a deep copy
		local moved = false
		for i=1,100 do	-- loop until it plays correctly or runs out of tries
			local location = Brain.forward(state) -- returns index of chosen action
			--print(location)
			if field[location] == 0 then
				field[location] = 1
				moved = true
				break
			end
			reward = -1
			Brain.backward(reward) -- learning magic happens 
		end
		if not moved then
			reward = -5
			Brain.backward(reward) -- learning magic happens 
			initField()
			break
		end
		--displayField()

		if isGameOver() then break end	

		--have opponent play
		while true do	-- loop until it plays correctly
			local location = math.random(1, 9)
			if field[location] == 0 then
				field[location] = 2
				break
			end
		end
		--displayField()
	end
end

Brain.epsilon_test_time = 0.0; -- don't make any more random choices
Brain.learning = false;
initField()

print("Testing")
-- get an optimal action from the learned policy
wins = 0
ties = 0
losses = 0
stuck = 0
for k = 1, nb_test do
	xlua.progress(k, nb_test)
	--print("*****   " .. k .. "   *****")
	while not isGameOverTest() do
		local state = table.copy(field) -- make a deep copy
		local moved = false
		for i=1,100 do	-- loop until it plays correctly or runs out of tries
			local location = Brain.forward(state) -- returns index of chosen action
			--print(location)
			if field[location] == 0 then
				field[location] = 1
				moved = true
				break
			end
			reward = -1
			Brain.backward(reward) -- learning magic happens
		end
		if not moved then
			stuck = stuck + 1
			reward = -5
			Brain.backward(reward) -- learning magic happens 
			initField()
			break
		end
		--displayField()

		if isGameOverTest() then break end	

		--have opponent play
		while true do	-- loop until it plays correctly
			local location = math.random(1, 9)
			if field[location] == 0 then
				field[location] = 2
				break
			end
		end
		--displayField()
	end
end

print("\n\n")
print("Wins: " .. wins)
print("Ties: " .. ties)
print("Losses: " .. losses)
print("Stuck: " .. stuck)
print("Time: " .. (os.time() - before) .. "s")