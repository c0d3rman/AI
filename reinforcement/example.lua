require 'xlua'
local Brain = require 'deepqlearn'

Brain.init(1, 2)

-- Number of past state/action pairs input to the network. 0 = agent lives in-the-moment :)
Brain.temporal_window = 2
-- Maximum number of experiences that we will save for training
Brain.experience_size = 30000
-- experience necessary to start learning
Brain.start_learn_threshold = 300
-- gamma is a crucial parameter that controls how much plan-ahead the agent does. In [0,1]
-- Determines the amount of weight placed on the utility of the state resulting from an action.
Brain.gamma = 0.9
-- number of steps we will learn for
Brain.learning_steps_total = 100000
-- how many steps of the above to perform only random actions (in the beginning)?
Brain.learning_steps_burnin = 300
-- controls exploration exploitation tradeoff. Will decay over time
-- a higher epsilon means we are more likely to choose random actions
Brain.epsilon = 1.0
-- what epsilon value do we bottom out on? 0.0 => purely deterministic policy at end
Brain.epsilon_min = 0.05
-- what epsilon to use when learning is turned off. This is for testing
Brain.epsilon_test_time = 0.01

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

