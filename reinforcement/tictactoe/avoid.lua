require('xlua')
Brain = require('deepqlearn')
Brain.init(9, 9)
local nb_train = 1000
local nb_test = 1000
local rightReward = 1
local wrongReward = -10
torch.setnumthreads(100)
local before = os.time()
field = { }
local initField
initField = function()
  field = {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  }
end
initField()
local fieldIsFull
fieldIsFull = function()
  local fieldFull = true
  for _index_0 = 1, #field do
    local square = field[_index_0]
    if square == 0 then
      fieldFull = false
      break
    end
  end
  return fieldFull
end
local displayField
displayField = function()
  print(field[1] .. " | " .. field[2] .. " | " .. field[3])
  print("---------")
  print(field[4] .. " | " .. field[5] .. " | " .. field[6])
  print("---------")
  print(field[7] .. " | " .. field[8] .. " | " .. field[9])
  return print("")
end
local isGameOver
isGameOver = function()
  if fieldIsFull() then
    initField()
    return true
  end
  return false
end
print("Training")
for k = 1, nb_train do
  xlua.progress(k, nb_train)
  local legalMoves = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9
  }
  while not isGameOver() do
    local state = table.copy(field)
    local locationAlg = Brain.forward(state)
    if field[locationAlg] == 0 then
      field[locationAlg] = 1
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #legalMoves do
          local move = legalMoves[_index_0]
          if move ~= locationAlg then
            _accum_0[_len_0] = move
            _len_0 = _len_0 + 1
          end
        end
        legalMoves = _accum_0
      end
      Brain.backward(rightReward)
    else
      Brain.backward(wrongReward)
      initField()
      break
    end
    if isGameOver() then
      break
    end
    local locationOpp = legalMoves[math.random(1, #legalMoves)]
    if field[locationOpp] == 0 then
      field[locationOpp] = 2
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #legalMoves do
          local move = legalMoves[_index_0]
          if move ~= locationOpp then
            _accum_0[_len_0] = move
            _len_0 = _len_0 + 1
          end
        end
        legalMoves = _accum_0
      end
    else
      print("ERROR - OPP FORBIDDEN ACTION: " .. locationOpp)
      print(table.concat(legalMoves, ", "))
      displayField()
      initField()
      break
    end
  end
end
Brain.epsilon_test_time = 0.0
Brain.learning = false
initField()
print("Testing")
right, stuck = 0, 0
for k = 1, nb_test do
  xlua.progress(k, nb_test)
  local legalMoves = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9
  }
  while not isGameOver() do
    local state = table.copy(field)
    local locationAlg = Brain.forward(state)
    if field[locationAlg] == 0 then
      field[locationAlg] = 1
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #legalMoves do
          local move = legalMoves[_index_0]
          if move ~= locationAlg then
            _accum_0[_len_0] = move
            _len_0 = _len_0 + 1
          end
        end
        legalMoves = _accum_0
      end
      Brain.backward(rightReward)
      right = right + 1
    else
      Brain.backward(wrongReward)
      stuck = stuck + 1
      displayField()
      print("Move: " .. locationAlg)
      initField()
      break
    end
    if isGameOver() then
      break
    end
    local locationOpp = legalMoves[math.random(1, #legalMoves)]
    if field[locationOpp] == 0 then
      field[locationOpp] = 2
      do
        local _accum_0 = { }
        local _len_0 = 1
        for _index_0 = 1, #legalMoves do
          local move = legalMoves[_index_0]
          if move ~= locationOpp then
            _accum_0[_len_0] = move
            _len_0 = _len_0 + 1
          end
        end
        legalMoves = _accum_0
      end
    else
      print("ERROR - OPP FORBIDDEN ACTION: " .. locationOpp)
      print(table.concat(legalMoves, ", "))
      displayField()
      initField()
      break
    end
  end
end
print("\n\n")
print("Right: " .. right)
print("Stuck: " .. stuck)
return print("Time: " .. (os.time() - before) .. "s")
