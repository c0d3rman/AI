require('xlua')
Brain = require('deepqlearn')
Brain.init(9, 9)
local nb_train = 1000
local nb_test = 1000
local winReward = 100
local loseReward = -10
local tieReward = -1
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
local lookup = {
  {
    1,
    2,
    3
  },
  {
    4,
    5,
    6
  },
  {
    7,
    8,
    9
  },
  {
    1,
    4,
    7
  },
  {
    2,
    5,
    8
  },
  {
    3,
    6,
    9
  },
  {
    1,
    5,
    9
  },
  {
    3,
    5,
    7
  }
}
local getWinner
getWinner = function()
  local winner = 0
  for i, v in ipairs(lookup) do
    if field[v[1]] == field[v[2]] and field[v[1]] == field[v[3]] then
      winner = field[v[1]]
      break
    end
  end
  return winner
end
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
local isGameOver
isGameOver = function()
  local winner = getWinner()
  if winner == 1 then
    Brain.backward(winReward)
    initField()
    return true
  elseif winner == 2 then
    Brain.backward(loseReward)
    initField()
    return true
  else
    if fieldIsFull() then
      Brain.backward(tieReward)
      initField()
      return true
    end
  end
  return false
end
wins, ties, losses = 0, 0, 0
local isGameOverTest
isGameOverTest = function()
  local winner = getWinner()
  if winner == 1 then
    wins = wins + 1
    Brain.backward(winReward)
    initField()
    return true
  elseif winner == 2 then
    losses = losses + 1
    Brain.backward(loseReward)
    initField()
    return true
  else
    if fieldIsFull() then
      ties = ties + 1
      Brain.backward(tieReward)
      initField()
      return true
    end
  end
  return false
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
  local illegalMoves = { }
  while not isGameOver() do
    local state = table.copy(field)
    local locationAlg = Brain.forward_forbidden(state, illegalMoves)
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
      table.insert(illegalMoves, locationAlg)
    else
      print("ERROR - ALG FORBIDDEN ACTION: " .. locationAlg)
      print(table.concat(legalMoves, ", ") .. " | " .. table.concat(illegalMoves, ", "))
      displayField()
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
      table.insert(illegalMoves, locationOpp)
    else
      print("ERROR - OPP FORBIDDEN ACTION: " .. locationOpp)
      print(table.concat(legalMoves, ", ") .. " | " .. table.concat(illegalMoves, ", "))
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
  local illegalMoves = { }
  while not isGameOverTest() do
    local state = table.copy(field)
    local locationAlg = Brain.forward_forbidden(state, illegalMoves)
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
      table.insert(illegalMoves, locationAlg)
    else
      print("ERROR - ALG FORBIDDEN ACTION: " .. locationAlg)
      print(table.concat(legalMoves, ", ") .. " | " .. table.concat(illegalMoves, ", "))
      displayField()
      initField()
      break
    end
    if isGameOverTest() then
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
      table.insert(illegalMoves, locationOpp)
    else
      print("ERROR - OPP FORBIDDEN ACTION: " .. locationOpp)
      print(table.concat(legalMoves, ", ") .. " | " .. table.concat(illegalMoves, ", "))
      displayField()
      initField()
      break
    end
  end
end
print("\n\n")
print("Wins: " .. wins)
print("Ties: " .. ties)
print("Losses: " .. losses)
return print("Time: " .. (os.time() - before) .. "s")
