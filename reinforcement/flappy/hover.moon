require 'xlua'
export Brain = require 'deepqlearn'

torch.setnumthreads 100
before = os.time!


nb_train = 1000
nb_test  = 1000

maxHeight = 100

jumpStrength = 21
startingHeight = 50
gravity = -5


-- Inputs: Y & YV of bird
numInputs = 2
-- Outputs: to flap or not to flap
Brain.init numInputs, 2

class Bird
	new: (y, gravity, jumpStrength) =>
		@y = y
		@yv = 0
		@gravity = gravity
		@jumpStrength = jumpStrength

	move: =>
		@yv += @gravity
		@y += @yv

	isDead: =>
		@y < 0 or @y > 100

	flap: =>
		@yv = @jumpStrength

	decide: (state) =>
		decision = Brain.forward(state) == 1
		--if decision then Brain.backward -1 else Brain.backward 0
		return decision

class Game
	new: (bird) =>
		@bird = bird
		@gameOver = false
		@score = -1

	tick: =>
		state = {@bird.y, @bird.yv}
		@bird\flap! if @bird\decide state
		@bird\move!
		Brain.backward 50 - math.abs @bird.y - maxHeight / 2
		--print "REWARD " .. (25 - math.abs @bird.y - maxHeight / 2) .. ", Y " .. @bird.y

	getScore: =>
		return @score

	play: =>
		while not @bird\isDead!
			@score += 1
			@tick!
			--print "#{@bird.y} | #{@bird.yv}"
		Brain.backward -100
		--print "REWARD " .. -100
		return @getScore!

	playHuman: =>
		print pipe\toString! for pipe in *@pipes
		while not @bird\isDead
			print "#{@bird.x}, #{@bird.y} | #{@bird.xv}, #{@bird.yv} | flap? "
			@bird\flap! if io.read() == "y"
			@tick!
		return @getScore!

print "Training"
for k = 1, nb_train
	xlua.progress k, nb_train
	--print "*****   " .. k .. "   *****"
	bird = Bird startingHeight, gravity, jumpStrength
	game = Game bird

	score = game\play!

	--Brain.backward score

Brain.epsilon_test_time = 0.0 -- don't make any more random choices
Brain.learning = false

averageScore = 0
print "Testing"
-- get an optimal action from the learned policy
for k = 1, nb_test
	xlua.progress k, nb_test
	--print "*****   " .. k .. "   *****"
	bird = Bird startingHeight, gravity, jumpStrength
	game = Game bird

	score = game\play!
	averageScore += score

	--Brain.backward score

averageScore /= nb_test

bird = Bird startingHeight, gravity, jumpStrength
game = Game bird
while not game.bird\isDead!
	game.score += 1
	game\tick!
	print "#{game.bird.y} | #{game.bird.yv}"
print game\getScore!

print "\n\n"
print "Score: #{averageScore}"
print "Time: #{os.time! - before}s"