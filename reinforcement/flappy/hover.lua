require('xlua')
Brain = require('deepqlearn')
torch.setnumthreads(100)
local before = os.time()
local nb_train = 1000
local nb_test = 1000
local maxHeight = 100
local jumpStrength = 21
local startingHeight = 50
local gravity = -5
local numInputs = 2
Brain.init(numInputs, 2)
local Bird
do
  local _base_0 = {
    move = function(self)
      self.yv = self.yv + self.gravity
      self.y = self.y + self.yv
    end,
    isDead = function(self)
      return self.y < 0 or self.y > 100
    end,
    flap = function(self)
      self.yv = self.jumpStrength
    end,
    decide = function(self, state)
      local decision = Brain.forward(state) == 1
      return decision
    end
  }
  _base_0.__index = _base_0
  local _class_0 = setmetatable({
    __init = function(self, y, gravity, jumpStrength)
      self.y = y
      self.yv = 0
      self.gravity = gravity
      self.jumpStrength = jumpStrength
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
      if self.bird:decide(state) then
        self.bird:flap()
      end
      self.bird:move()
      return Brain.backward(50 - math.abs(self.bird.y - maxHeight / 2))
    end,
    getScore = function(self)
      return self.score
    end,
    play = function(self)
      while not self.bird:isDead() do
        self.score = self.score + 1
        self:tick()
      end
      Brain.backward(-100)
      return self:getScore()
    end,
    playHuman = function(self)
      local _list_0 = self.pipes
      for _index_0 = 1, #_list_0 do
        local pipe = _list_0[_index_0]
        print(pipe:toString())
      end
      while not (function()
        local _base_1 = self.bird
        local _fn_0 = _base_1.isDead
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)() do
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
    __init = function(self, bird)
      self.bird = bird
      self.gameOver = false
      self.score = -1
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
print("Training")
for k = 1, nb_train do
  xlua.progress(k, nb_train)
  local bird = Bird(startingHeight, gravity, jumpStrength)
  local game = Game(bird)
  local score = game:play()
end
Brain.epsilon_test_time = 0.0
Brain.learning = false
local averageScore = 0
print("Testing")
for k = 1, nb_test do
  xlua.progress(k, nb_test)
  local bird = Bird(startingHeight, gravity, jumpStrength)
  local game = Game(bird)
  local score = game:play()
  averageScore = averageScore + score
end
averageScore = averageScore / nb_test
local bird = Bird(startingHeight, gravity, jumpStrength)
local game = Game(bird)
while not game.bird:isDead() do
  game.score = game.score + 1
  game:tick()
  print(tostring(game.bird.y) .. " | " .. tostring(game.bird.yv))
end
print(game:getScore())
print("\n\n")
print("Score: " .. tostring(averageScore))
return print("Time: " .. tostring(os.time() - before) .. "s")
