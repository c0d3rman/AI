require 'xlua'
export Brain = require 'deepqlearn'


Brain.init 9, 9

nb_train = 1000
nb_test  = 1000

rightReward = 1
wrongReward = -10

torch.setnumthreads 100
before = os.time!

export field = {}

initField = ->
	field = {
		0, 0, 0,
		0, 0, 0,
		0, 0, 0
	}

initField!

fieldIsFull = ->
	fieldFull = true
	for square in *field
		if square == 0
			fieldFull = false
			break
	return fieldFull

displayField = ->
	print field[1] .. " | " .. field[2] .. " | " .. field[3]
	print "---------"
	print field[4] .. " | " .. field[5] .. " | " .. field[6]
	print "---------"
	print field[7] .. " | " .. field[8] .. " | " .. field[9]
	print ""

isGameOver = ->
	if fieldIsFull!
		initField!
		return true
	return false

print "Training"
for k = 1, nb_train
	xlua.progress k, nb_train
	--print "*****   " .. k .. "   *****"
	legalMoves = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	while not isGameOver!
		state = table.copy field -- make a deep copy
		--print table.concat legalMoves, ", "
		--print "---"

		locationAlg = Brain.forward state -- returns index of chosen action
		if field[locationAlg] == 0
			field[locationAlg] = 1
			legalMoves = [move for move in *legalMoves when move != locationAlg]
			Brain.backward rightReward
		else
			Brain.backward wrongReward
			--displayField!
			initField!
			break
		--displayField!

		break if isGameOver!

		--have opponent play
		locationOpp = legalMoves[math.random 1, #legalMoves]
		if field[locationOpp] == 0
			field[locationOpp] = 2
			legalMoves = [move for move in *legalMoves when move != locationOpp]
		else
			print "ERROR - OPP FORBIDDEN ACTION: " .. locationOpp
			print table.concat legalMoves, ", "
			displayField!
			initField!
			break
		--displayField!

Brain.epsilon_test_time = 0.0 -- don't make any more random choices
Brain.learning = false
initField!

print "Testing"
-- get an optimal action from the learned policy
export right, stuck = 0, 0
for k = 1, nb_test
	xlua.progress k, nb_test
	--print "*****   " .. k .. "   *****"
	legalMoves = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	while not isGameOver!
		state = table.copy field -- make a deep copy
		--print table.concat legalMoves, ", "
		--print "---"

		locationAlg = Brain.forward state -- returns index of chosen action
		if field[locationAlg] == 0
			field[locationAlg] = 1
			legalMoves = [move for move in *legalMoves when move != locationAlg]
			Brain.backward rightReward
			right += 1
		else
			Brain.backward wrongReward
			stuck += 1
			displayField!
			print "Move: " .. locationAlg
			initField!
			break
		--displayField!

		break if isGameOver!

		--have opponent play
		locationOpp = legalMoves[math.random 1, #legalMoves]
		if field[locationOpp] == 0
			field[locationOpp] = 2
			legalMoves = [move for move in *legalMoves when move != locationOpp]
		else
			print "ERROR - OPP FORBIDDEN ACTION: " .. locationOpp
			print table.concat legalMoves, ", "
			displayField!
			initField!
			break
		--displayField!

print "\n\n"
print "Right: " .. right
print "Stuck: " .. stuck
print "Time: " .. (os.time! - before) .. "s"