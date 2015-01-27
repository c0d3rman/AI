require('xlua')
Brain = require('deepqlearn')
torch.setnumthreads(100)
local before = os.time()
local nb_train = 1000
local nb_test = 1000
local maxHeight = 100
local beginningStretch = 30
local jumpStrength = 21
local startingHeight = 50
local horizontalSpeed = 3
local gravity = -5
local vision = 100
local numPipes = 20
local pipeGap = 20
local pipeWidth = 10
local pipeDistance = 30
local numInputs = 2 + 2 * math.ceil(vision / pipeDistance)
Brain.init(numInputs, 2)
local Pipe
do
  local _base_0 = {
    isColliding = function(self, x, y)
      return ((self.x < x) and (x < self.x + self.width)) and ((y < self.y) or (y > self.y + self.gapSize))
    end,
    toString = function(self)
      return "x: " .. tostring(self.x) .. "\ny: " .. tostring(self.y) .. "\nwidth: " .. tostring(self.width) .. "\ngapSize: " .. tostring(self.gapSize)
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, x, y, width, gapSize)
      self.x = x
      self.y = y
      self.width = width
      self.gapSize = gapSize
    end,
    __base = _base_0,
    __name = "Pipe"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Pipe = _class_0
end
local Bird
do
  local _base_0 = {
    move = function(self)
      self.x = self.x + self.xv
      self.yv = self.yv + self.gravity
      self.y = self.y + self.yv
    end,
    isInPipe = function(self, pipes)
      local inPipe = false
      for _index_0 = 1, #pipes do
        local pipe = pipes[_index_0]
        if pipe:isColliding(self.x, self.y) then
          inPipe = true
          break
        end
      end
      return inPipe
    end,
    isOutOfBounds = function(self)
      return self.y < 0 or self.y > 100
    end,
    isDead = function(self, pipes)
      return self:isOutOfBounds() or self:isInPipe(pipes)
    end,
    flap = function(self)
      self.yv = self.jumpStrength
    end,
    decide = function(self, state)
      local decision = Brain.forward(state) == 1
      if decision then
        Brain.backward(-1)
      else
        Brain.backward(0)
      end
      return decision
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, y, xv, gravity, jumpStrength, vision)
      self.x = 0
      self.y = y
      self.xv = xv
      self.yv = 0
      self.gravity = gravity
      self.jumpStrength = jumpStrength
      self.vision = vision
    end,
    __base = _base_0,
    __name = "Bird"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Bird = _class_0
end
local Game
do
  local _base_0 = {
    tick = function(self)
      local state = {
        self.bird.y,
        self.bird.yv
      }
      local _list_0 = self.pipes
      for _index_0 = 1, #_list_0 do
        local pipe = _list_0[_index_0]
        if pipe.x >= self.bird.x and pipe.x <= self.bird.x + self.bird.vision then
          table.insert(state, pipe.x - self.bird.x)
          table.insert(state, pipe.y)
        end
      end
      while #state < numInputs do
        table.insert(state, -1)
      end
      if self.bird:decide(state) then
        self.bird:flap()
      end
      return self.bird:move()
    end,
    getScore = function(self)
      return math.max(math.min(math.floor((self.bird.x - beginningStretch) / pipeDistance), numPipes), 0)
    end,
    isGameWon = function(self)
      return self.bird.x > beginningStretch + numPipes * pipeDistance + pipeWidth
    end,
    play = function(self)
      while not self:isGameWon() and not self.bird:isDead(self.pipes) do
        self:tick()
        print(tostring(self.bird.x) .. ", " .. tostring(self.bird.y) .. " | " .. tostring(self.bird.xv) .. ", " .. tostring(self.bird.yv))
      end
      return self:getScore()
    end,
    playHuman = function(self)
      local _list_0 = self.pipes
      for _index_0 = 1, #_list_0 do
        local pipe = _list_0[_index_0]
        print(pipe:toString())
      end
      while not self:isGameWon() and not self.bird:isDead(self.pipes) do
        print(tostring(self.bird.x) .. ", " .. tostring(self.bird.y) .. " | " .. tostring(self.bird.xv) .. ", " .. tostring(self.bird.yv) .. " | flap? ")
        if io.read() == "y" then
          self.bird:flap()
        end
        self:tick()
      end
      return self:getScore()
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, bird, pipes)
      self.bird = bird
      self.pipes = pipes
      self.gameOver = false
    end,
    __base = _base_0,
    __name = "Game"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Game = _class_0
end
local pipeGen
pipeGen = function()
  local pipes = { }
  for x = beginningStretch, (numPipes - 1) * pipeDistance + beginningStretch, pipeDistance do
    local y = math.random(0, maxHeight - pipeGap)
    local pipe = Pipe(x, y, pipeWidth, pipeGap)
    table.insert(pipes, pipe)
  end
  return pipes
end
print("Training")
for k = 1, nb_train do
  print("*****   " .. k .. "   *****")
  local bird = Bird(startingHeight, horizontalSpeed, gravity, jumpStrength, vision)
  local pipes = pipeGen()
  local game = Game(bird, pipes)
  local score = game:play()
  Brain.backward(score)
end
Brain.epsilon_test_time = 0.0
Brain.learning = false
local averageScore = 0
local averageX = 0
print("Testing")
for k = 1, nb_test do
  print("*****   " .. k .. "   *****")
  local bird = Bird(startingHeight, horizontalSpeed, gravity, jumpStrength, vision)
  local pipes = pipeGen()
  local game = Game(bird, pipes)
  local score = game:play()
  averageScore = averageScore + score
  averageX = averageX + game.bird.x
  Brain.backward(score)
end
averageScore = averageScore / nb_test
averageX = averageX / nb_test
print("\n\n")
print("Score: " .. tostring(averageScore))
print("X: " .. tostring(averageX))
return print("Time: " .. tostring(os.time() - before) .. "s")
