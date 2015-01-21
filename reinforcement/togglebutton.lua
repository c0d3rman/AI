require 'xlua'
local Brain = require 'deepqlearn'

Brain.init(1, 2)

nb_train = 1000
nb_test  = 1000

currentState = 1

print("Training")
for k = 1, nb_train do
	xlua.progress(k, nb_train)

	state = {1}

	newstate = table.copy(state) -- make a deep copy
	action = Brain.forward(newstate) -- returns index of chosen action

	if currentState == action then
		reward = 1
		if currentState == 1 then
			currentState = 2
		else
			currentState = 1
		end
	else
		reward = -1
	end

	Brain.backward(reward) -- learning magic happens 
end

Brain.epsilon_test_time = 0.0; -- don't make any more random choices
Brain.learning = false;

print("Testing")
-- get an optimal action from the learned policy
local cnt = 0
for k = 1, nb_test do
	--xlua.progress(k, nb_test)

	state = {1}


	newstate = table.copy(state)
	output = Brain.forward(newstate)
	print(output .. " | " .. currentState)
	if currentState == output then
		cnt = cnt + 1
		if currentState == 1 then
			currentState = 2
		else
			currentState = 1
		end
	end
end

print("Test cases correct: " .. tostring(100 * cnt/nb_test) .. " %")

