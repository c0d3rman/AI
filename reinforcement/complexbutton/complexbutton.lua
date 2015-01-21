require 'xlua'
local Brain = require 'deepqlearn'

Brain.init(1, 2)

nb_train = 5000
nb_test  = 1000

currentState = 1
correctActions = {2, 2, 1, 2}
rightInARow = 1

print("Training")
for k = 1, nb_train do
	xlua.progress(k, nb_train)

	state = {1}

	newstate = table.copy(state) -- make a deep copy
	action = Brain.forward(newstate) -- returns index of chosen action

	if correctActions[currentState] == action then
		reward = 1
		currentState = (currentState) % #correctActions + 1
		rightInARow = rightInARow + 1
	else
		reward = -rightInARow
		rightInARow = 1
	end

	Brain.backward(reward) -- learning magic happens
end

Brain.epsilon_test_time = 0.0 -- don't make any more random choices
Brain.learning = false

print("Testing")
-- get an optimal action from the learned policy
local cnt = 0
for k = 1, nb_test do
	--xlua.progress(k, nb_test)

	state = {1}

	newstate = table.copy(state)
	output = Brain.forward(newstate)
	print(output .. " | " .. currentState .. " | " .. correctActions[currentState])
	if correctActions[currentState] == output then
		cnt = cnt + 1
		currentState = (currentState) % #correctActions + 1
	end
end

print("Test cases correct: " .. tostring(100 * cnt/nb_test) .. " %")

