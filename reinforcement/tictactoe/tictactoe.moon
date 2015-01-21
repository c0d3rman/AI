require 'xlua'
export Brain = require 'deepqlearn'


Brain.init 9, 9

nb_train = 1000
nb_test  = 1000

winReward = 100
loseReward = -10
tieReward = -1

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

getWinner = ->
	winner = 0
	for i, v in ipairs lookup
		if field[v[1]] == field[v[2]] and field[v[1]] == field[v[3]] then
			winner = field[v[1]]
			break
	return winner

fieldIsFull = ->
	fieldFull = true
	for square in *field
		if square == 0
			fieldFull = false
			break
	return fieldFull

-- checks if game is over, rewards winner, and resets field
isGameOver = ->
	winner = getWinner!
	if winner == 1
		Brain.backward winReward -- win
		--print "WIN"
		initField!
		return true
	elseif winner == 2 -- loss
		Brain.backward loseReward
		--print "LOSS"
		initField!
		return true
	else
		if fieldIsFull! -- tie
			--print "TIE"
			Brain.backward tieReward
			initField!
			return true
	return false

export wins, ties, losses = 0, 0, 0
isGameOverTest = ->
	winner = getWinner!
	if winner == 1
		wins += 1
		Brain.backward winReward -- win
		initField!
		return true
	elseif winner == 2 -- loss
		losses += 1
		Brain.backward loseReward
		initField!
		return true
	else
		if fieldIsFull! -- tie
			ties += 1
			Brain.backward tieReward
			initField!
			return true
	return false

displayField = ->
	print field[1] .. " | " .. field[2] .. " | " .. field[3]
	print "---------"
	print field[4] .. " | " .. field[5] .. " | " .. field[6]
	print "---------"
	print field[7] .. " | " .. field[8] .. " | " .. field[9]
	print ""

print "Training"
for k = 1, nb_train
	xlua.progress k, nb_train
	--print "*****   " .. k .. "   *****"
	legalMoves = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	illegalMoves = {}
	while not isGameOver!
		state = table.copy field -- make a deep copy
		--print table.concat legalMoves, ", "
		--print table.concat illegalMoves, ", "
		--print "---"

		locationAlg = Brain.forward_forbidden state, illegalMoves -- returns index of chosen action
		if field[locationAlg] == 0
			field[locationAlg] = 1
			legalMoves = [move for move in *legalMoves when move != locationAlg]
			table.insert illegalMoves, locationAlg
		else
			print "ERROR - ALG FORBIDDEN ACTION: " .. locationAlg
			print table.concat(legalMoves, ", ") .. " | " .. table.concat illegalMoves, ", "
			displayField!
			initField!
			break
		--displayField!

		break if isGameOver!

		--have opponent play
		locationOpp = legalMoves[math.random 1, #legalMoves]
		if field[locationOpp] == 0
			field[locationOpp] = 2
			legalMoves = [move for move in *legalMoves when move != locationOpp]
			table.insert illegalMoves, locationOpp
		else
			print "ERROR - OPP FORBIDDEN ACTION: " .. locationOpp
			print table.concat(legalMoves, ", ") .. " | " .. table.concat illegalMoves, ", "
			displayField!
			initField!
			break
		--displayField!

Brain.epsilon_test_time = 0.0 -- don't make any more random choices
Brain.learning = false
initField!

print "Testing"
-- get an optimal action from the learned policy
for k = 1, nb_test
	xlua.progress k, nb_test
	--print "*****   " .. k .. "   *****"
	legalMoves = {1, 2, 3, 4, 5, 6, 7, 8, 9}
	illegalMoves = {}
	while not isGameOverTest!
		state = table.copy field -- make a deep copy
		--print table.concat legalMoves, ", "
		--print table.concat illegalMoves, ", "
		--print "---"

		locationAlg = Brain.forward_forbidden state, illegalMoves -- returns index of chosen action
		if field[locationAlg] == 0
			field[locationAlg] = 1
			legalMoves = [move for move in *legalMoves when move != locationAlg]
			table.insert illegalMoves, locationAlg
		else
			print "ERROR - ALG FORBIDDEN ACTION: " .. locationAlg
			print table.concat(legalMoves, ", ") .. " | " .. table.concat illegalMoves, ", "
			displayField!
			initField!
			break
		--displayField!

		break if isGameOverTest!

		--have opponent play
		locationOpp = legalMoves[math.random 1, #legalMoves]
		if field[locationOpp] == 0
			field[locationOpp] = 2
			legalMoves = [move for move in *legalMoves when move != locationOpp]
			table.insert illegalMoves, locationOpp
		else
			print "ERROR - OPP FORBIDDEN ACTION: " .. locationOpp
			print table.concat(legalMoves, ", ") .. " | " .. table.concat illegalMoves, ", "
			displayField!
			initField!
			break
		--displayField!

print "\n\n"
print "Wins: " .. wins
print "Ties: " .. ties
print "Losses: " .. losses
print "Time: " .. (os.time! - before) .. "s"