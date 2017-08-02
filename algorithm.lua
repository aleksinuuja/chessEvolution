Algorithm = {}

function Algorithm:new(params)
  o = {}
  o.colour = params.colour -- "w" or "b" (assigned as white or black)

  -- properties will contain "gene" values for different parameters used in the makeAMove() method

  setmetatable(o, self)
  self.__index = self
  return o
end

function Algorithm:makeAMove(pos)
  local allPossibleMoves = {}
  local possibleMovesForThis = {}
  local pieceAtPos, pieceName, pieceColour, pieceRank

  -- go through all squares
  local a, x
  for a=1,8 do
    for x=1,8 do
      pieceAtPos = pos[a][x]
      pieceName = returnPieceAt(pos, a, x)
      pieceColour = string.sub(pieceName, 3)
      pieceRank = string.sub(pieceName, 1, 1)
      -- if square has a piece of algorithm's own colour...
      if pieceColour == pos[9] then
        -- print("found my own piece at " .. a .. ", " ..x)
        -- print("it's name is " .. pieceName)
        -- print("it's colour is " .. pieceColour)
        -- print("it's rank is " .. pieceRank)

        -- find all legit moves it can make, fetch a list of Move class objects
        -- calculate and store a score for each move as well - store in the Move instance
        possibleMovesForThis = findAllLegitMoves(pos, a, x)

        -- append each move to the master list of all possible moves
        local i
--        print("for this given piece, the number for possible moves is " .. #possibleMovesForThis)
        for i, move in ipairs(possibleMovesForThis) do
          table.insert(allPossibleMoves, move)
        end

      end
    end
  end
  print("after going through all pieces, the total number for possible moves is " .. #allPossibleMoves)
  print("here's a list of all possible moves:")
  for i, move in ipairs(allPossibleMoves) do
    print(move.name)
  end


  -- select the move with the highest score

  -- now we just select a random one move
  -- make the move and .... nothing, the passed table is trasformed directly
  if #allPossibleMoves > 0 then
    local diceRoll = math.random(#allPossibleMoves)
    implementMove(pos, allPossibleMoves[diceRoll].from, allPossibleMoves[diceRoll].to)
  end

  -- the pos[9] says whose turn is next, switch it
  if pos[9] == "w" then pos[9] = "b" else pos[9] = "w" end
end

function findAllLegitMoves(pos, a, x)
  local legitMoves = {}
  local legit = true
  local pieceAtPos = pos[a][x]
  local pieceName = returnPieceAt(pos, a, x)
  local pieceColour = string.sub(pieceName, 3)
  local pieceRank = string.sub(pieceName, 1, 1)
  local targetColour -- used to determine if a piece in given square is friend or foe
  local step

  local function checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)
    legit = true -- always start with assumption the move is legit
    local step = 0
    local ta, tx, switch, name

    if pieceRank == "b" then name = "Bishop"
    elseif pieceRank == "r" then name = "Rook"
    elseif pieceRank == "q" then name = "Queen"
    end

    -- iterate to the direction of deltaA, deltaX until you run into board edge or a piece
    switch = false
    repeat
      step = step + 1
      ta = a + step*deltaA
      tx = x + step*deltaX
      if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then
        legit = false -- outside the board!
        switch = true
      else
        targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
        if targetColour == pos[9] then
          legit = false
          switch = true
        end -- the target's one of my own colour
      end

      if legit then
        scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, name .. " to ")
      end
    until switch

  end

  local function checkKingMoves(pos, a, x, deltaA, deltaX)
    legit = true -- always start with assumption the move is legit
    local ta, tx

    -- check a step to the direction of deltaA, deltaX
    ta = a + deltaA
    tx = x + deltaX
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end

    if legit then
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "King to ")
    end

  end

  -- we go through possible moves and if they are legit, create a Move object and add to legitMoves list

  if pieceRank == "p" then
    if pieceColour == "w" then step = 1 else step = -1 end

    -- one step ahead
    legit = true -- always start with assumption the move is legit
    if not(returnPieceAt(pos, a, x+step) == "emp") then legit = false end
    if legit then scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = a, x = x+step}, "Pawn to ") end

    -- two steps ahead
    legit = true -- always start with assumption the move is legit
    if not(returnPieceAt(pos, a, x+step) == "emp") then legit = false end
    if not(returnPieceAt(pos, a, x+2*step) == "emp") then legit = false end
    if legit then scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = a, x = x+2*step}, "Pawn to ") end

    -- capture left
    legit = true -- always start with assumption the move is legit
    if a < 2 then legit = false
    elseif x+step < 1 or x+step > 8 then legit = false
    else
      if returnPieceAt(pos, a-1, x+step) == "emp" then legit = false -- there's no-one to capture there
      else
        targetColour = string.sub(returnPieceAt(pos, a-1, x+step), 3)
        if targetColour == pos[9] then legit = false end -- the target's one of my own colour
      end
    end -- can't capture outside the board
    if legit then scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = a-1, x = x+step}, "Pawn captures at ") end

    -- capture right
    legit = true -- always start with assumption the move is legit
    if a > 7 then legit = false
    elseif x+step < 1 or x+step > 8 then legit = false
    else
      if returnPieceAt(pos, a+1, x+step) == "emp" then legit = false -- there's no-one to capture there
      else
        targetColour = string.sub(returnPieceAt(pos, a+1, x+step), 3)
        if targetColour == pos[9] then legit = false end -- the target's one of my own colour
      end
    end -- can't capture outside the board
    if legit then scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = a+1, x = x+step}, "Pawn captures at ") end

    -- TODO: OHESTALYÖNTI PUUTTUU

  elseif pieceRank == "n" then

    local function checkKnightMove(pos, ta, tx)
      legit = true -- always start with assumption the move is legit
      if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
      else
        targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
        if targetColour == pos[9] then legit = false end -- the target's one of my own colour
      end
      if legit then
        scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
      end
    end

    -- the knight has 8 possible moves: check each location
    local ta, tx -- target coordinates

    ta = a+1
    tx = x+2
    checkKnightMove(pos, ta, tx)

    ta = a+1
    tx = x-2
    checkKnightMove(pos, ta, tx)

    ta = a-1
    tx = x+2
    checkKnightMove(pos, ta, tx)

    ta = a-1
    tx = x-2
    checkKnightMove(pos, ta, tx)

    ta = a+2
    tx = x+1
    checkKnightMove(pos, ta, tx)

    ta = a+2
    tx = x-1
    checkKnightMove(pos, ta, tx)

    ta = a-2
    tx = x+1
    checkKnightMove(pos, ta, tx)

    ta = a-2
    tx = x-1
    checkKnightMove(pos, ta, tx)

  elseif pieceRank == "b" then

    -- the bishop has 4 possible directions to move: iterate squares in each of these
    local deltaA, deltaX

    deltaA = 1
    deltaX = 1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 1
    deltaX = -1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = -1
    deltaX = -1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = -1
    deltaX = 1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

  elseif pieceRank == "r" then

    -- the rook has 4 possible directions to move: iterate squares in each of these
    local deltaA, deltaX

    deltaA = 1
    deltaX = 0
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = -1
    deltaX = 0
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 0
    deltaX = 1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 0
    deltaX = -1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

  elseif pieceRank == "q" then

    -- the Queen has 8 possible directions to move: iterate squares in each of these
    local deltaA, deltaX

    deltaA = 1
    deltaX = 0
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = -1
    deltaX = 0
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 0
    deltaX = 1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 0
    deltaX = -1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 1
    deltaX = 1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = 1
    deltaX = -1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = -1
    deltaX = 1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

    deltaA = -1
    deltaX = -1
    checkBRQMoves(pos, a, x, deltaA, deltaX, pieceRank)

  elseif pieceRank == "k" then

    -- the King has 8 possible directions to move: check each of these
    local deltaA, deltaX

    deltaA = 1
    deltaX = 0
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = -1
    deltaX = 0
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = 0
    deltaX = 1
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = 0
    deltaX = -1
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = 1
    deltaX = 1
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = 1
    deltaX = -1
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = -1
    deltaX = 1
    checkKingMoves(pos, a, x, deltaA, deltaX)

    deltaA = -1
    deltaX = -1
    checkKingMoves(pos, a, x, deltaA, deltaX)

  end

  -- return a list of Move objects, complete with given scores
  return legitMoves
end

function scoreThisMoveAndAddToList(list, pos, from, to, name)
  local move = Move:new()
  local alteredPos = Position:new({seed = pos})

  move.from = from
  move.to = to
  alteredPos = implementMove(alteredPos, move.from, move.to)
  move.score = 0 -- scoreThisPos(alteredPos)
  move.name = name .. numberToLetter(to.a) .. to.x
  table.insert(list, move)
end

-- from and to are tables with a and x
function implementMove(pos, from, to)
  local temp = pos[from.a][from.x]
  pos[from.a][from.x] = emp
  pos[to.a][to.x] = temp

  return pos
end

function numberToLetter(a)
  if a == 1 then return "a"
  elseif a == 2 then return "b"
  elseif a == 3 then return "c"
  elseif a == 4 then return "d"
  elseif a == 5 then return "e"
  elseif a == 6 then return "f"
  elseif a == 7 then return "g"
  elseif a == 8 then return "h"
  end
end
