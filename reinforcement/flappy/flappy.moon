require 'xlua'
export Brain = require 'deepqlearn'

torch.setnumthreads 100
before = os.time!


nb_train = 1000
nb_test  = 1000

maxHeight = 100
beginningStretch = 30

jumpStrength = 21
startingHeight = 50
horizontalSpeed = 3
gravity = -5
vision = 100

numPipes = 20
pipeGap = 20
pipeWidth = 10
pipeDistance = 30


-- Inputs: Y & YV of bird + X and Y of every pipe in vision
numInputs = 2 + 2 * math.ceil(vision / pipeDistance)
-- Outputs: to flap or not to flap
Brain.init numInputs, 2

class Pipe
	new: (x, y, width, gapSize) =>
		@x = x				-- x coordinate of bottom left corner
		@y = y				-- y coordinate of bottom of pipe gap
		@width = width		-- how thick the pipe is
		@gapSize = gapSize	-- how tall the gap is

	isColliding: (x, y) =>
		((@x < x) and (x < @x + @width)) and ((y < @y) or (y > @y + @gapSize))

	toString: =>
		"x: #{@x}
y: #{@y}
width: #{@width}
gapSize: #{@gapSize}"

class Bird
	new: (y, xv, gravity, jumpStrength, vision) =>
		@x = 0
		@y = y
		@xv = xv
		@yv = 0
		@gravity = gravity
		@jumpStrength = jumpStrength
		@vision = vision

	move: =>
		@x += @xv
		@yv += @gravity
		@y += @yv

	isInPipe: (pipes) =>
		inPipe = false
		for pipe in *pipes
			if pipe\isColliding @x, @y
				inPipe = true
				break
		return inPipe

	isOutOfBounds: =>
		@y < 0 or @y > 100

	isDead: (pipes) =>
		@isOutOfBounds! or @isInPipe pipes

	flap: =>
		@yv = @jumpStrength

	decide: (state) =>
		decision = Brain.forward(state) == 1
		if decision then Brain.backward -1 else Brain.backward 0
		return decision

class Game
	new: (bird, pipes) =>
		@bird = bird
		@pipes = pipes
		@gameOver = false

	tick: =>
		state = {@bird.y, @bird.yv}
		for pipe in *@pipes
			if pipe.x >= @bird.x and pipe.x <= @bird.x + @bird.vision
				table.insert state, pipe.x - @bird.x
				table.insert state, pipe.y
		while #state < numInputs do table.insert state, -1
		--print @bird.x .. " | " .. table.concat(state, ", ")

		@bird\flap! if @bird\decide state
		@bird\move!

	getScore: =>
		math.max math.min(math.floor((@bird.x - beginningStretch) / pipeDistance), numPipes), 0

	isGameWon: =>
		@bird.x > beginningStretch + numPipes * pipeDistance + pipeWidth

	play: =>
		while not @isGameWon! and not @bird\isDead @pipes
			@tick!
			print "#{@bird.x}, #{@bird.y} | #{@bird.xv}, #{@bird.yv}"
		return @getScore!

	playHuman: =>
		print pipe\toString! for pipe in *@pipes
		while not @isGameWon! and not @bird\isDead @pipes
			print "#{@bird.x}, #{@bird.y} | #{@bird.xv}, #{@bird.yv} | flap? "
			@bird\flap! if io.read() == "y"
			@tick!
		return @getScore!

pipeGen = ->
	pipes = {}
	for x = beginningStretch, (numPipes - 1) * pipeDistance + beginningStretch, pipeDistance
		y = math.random 0, maxHeight - pipeGap
		pipe = Pipe x, y, pipeWidth, pipeGap
		table.insert pipes, pipe
	return pipes

print "Training"
for k = 1, nb_train
	--xlua.progress k, nb_train
	print "*****   " .. k .. "   *****"
	bird = Bird startingHeight, horizontalSpeed, gravity, jumpStrength, vision
	pipes = pipeGen!
	game = Game bird, pipes

	score = game\play!

	Brain.backward score

Brain.epsilon_test_time = 0.0 -- don't make any more random choices
Brain.learning = false

averageScore = 0
averageX = 0
print "Testing"
-- get an optimal action from the learned policy
for k = 1, nb_test
	--xlua.progress k, nb_test
	print "*****   " .. k .. "   *****"
	bird = Bird startingHeight, horizontalSpeed, gravity, jumpStrength, vision
	pipes = pipeGen!
	game = Game bird, pipes

	score = game\play!
	averageScore += score
	averageX += game.bird.x

	Brain.backward score

averageScore /= nb_test
averageX /= nb_test

print "\n\n"
print "Score: #{averageScore}"
print "X: #{averageX}"
print "Time: #{os.time! - before}s"