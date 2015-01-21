require 'xlua'
local Brain = require 'deepqlearn'

Brain.init(1, 10)

nb_train = 1000
nb_test  = 100000

print("Training")
for k = 1, nb_train do
	xlua.progress(k, nb_train)

	state = {math.random(1, 10)}

	newstate = table.copy(state) -- make a deep copy
	action = Brain.forward(newstate) -- returns index of chosen action

	if action == math.random(1, 10) then
		reward = 1
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
	xlua.progress(k, nb_test)

	state = {math.random(1, 10)}


	newstate = table.copy(state)
	output = Brain.forward(newstate)
	
	if output == math.random(1, 10) then
		cnt = cnt + 1
	end
end

print("Test cases correct: " .. tostring(100 * cnt/nb_test) .. " %")

