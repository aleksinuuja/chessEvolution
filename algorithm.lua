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

  allPossibleMoves = findAllPossibleMovesForPosition(pos)

  -- allrighty, now we have a list of moves the pieces can make according to their restrictions
  -- next we need to check if the moves in the list are ILLEGAL, e.g. would leave the king checked
  allPossibleMoves = filterMoves(isLegal, allPossibleMoves, pos)

--[[
  print("after going through all pieces, the total number for possible moves is " .. #allPossibleMoves)
  print("here's a list of all possible moves:")
  for i, move in ipairs(allPossibleMoves) do
    print(move.name)
  end
]]--

  -- select the move with the highest score

  -- now we just select a random one move
  -- make the move
  if #allPossibleMoves > 0 then
    if not isPositionDraw(pos) then

      local diceRoll = math.random(#allPossibleMoves)
      implementMove(pos, allPossibleMoves[diceRoll].from, allPossibleMoves[diceRoll].to)
      return false -- game is NOT over
    else
      return true -- game IS over - it's a draw
    end
  else
--    print("there's no possible moves so it's a game over and I'm not moving at all for now")
    return true -- game IS over
  end
end


function isPositionStaleMate(pos)
-- called only when gameover = true - than means there are no moves leftLimit
-- the only thing we need to test is whether the King is threatened or not (if not = stalemate)
  local k, ka, kx -- king's position, k is used to store the piece for searching

  -- find where the king (held in __current__ position[9]) is in the altered position
  if pos[9] == "w" then
    print("checking for stalemate, checking whether WHITE king is threatened or not")
    k = k_w
  else
    print("checking for stalemate, checking whether BLACK king is threatened or not")
    k = k_b
  end
  ka, kx = locatePiece(pos, k)

  -- check if any opponent is threatening it - if yes, then it's not a stalemate
  -- for this we need to reverse whose turn it is
  if pos[9] == "w" then pos[9] = "b" else pos[9] = "w" end 
  if isThisSquareThreatened(pos, ka, kx) then
    print("yes the king's threatened so it's not a stalemate")
    return false
  else
    print("no the king's not threatened so YES IT IS a stalemate")
    return true
  end
end

function isPositionDraw(pos)
  -- material runs out, only kings OR king+bishop vs. king OR king+knight vs. king

  -- let's build a list of pieces
  -- white pieces other than king
  -- black pieces other than king

  local a, x
  local pieceAtPos, pieceName, pieceColour, pieceRank
  local allWhitePiecesExceptKing = {}
  local allBlackPiecesExceptKing = {}
  for a=1,8 do
    for x=1,8 do
      pieceAtPos = pos[a][x]
      pieceName = returnPieceAt(pos, a, x)
      pieceColour = string.sub(pieceName, 3)
      pieceRank = string.sub(pieceName, 1, 1)

      if not (pieceRank == "k") then
        if pieceColour == "b" then table.insert(allBlackPiecesExceptKing, pieceAtPos)
        elseif pieceColour == "w" then table.insert(allWhitePiecesExceptKing, pieceAtPos) end
      end

    end
  end

  -- draw if both lists empty
  if #allWhitePiecesExceptKing == 0 and #allBlackPiecesExceptKing == 0 then return true end

  -- draw if other list empty, other has knight or bishop
  if #allWhitePiecesExceptKing == 0 and #allBlackPiecesExceptKing == 1 then
    pieceAtPos = allBlackPiecesExceptKing[1]
    pieceName = returnPieceName(pieceAtPos)
    pieceRank = string.sub(pieceName, 1, 1)
    if pieceRank == "b" or pieceRank == "n" then return true end
  end
  if #allBlackPiecesExceptKing == 0 and #allWhitePiecesExceptKing == 1 then
    pieceAtPos = allWhitePiecesExceptKing[1]
    pieceName = returnPieceName(pieceAtPos)
    pieceRank = string.sub(pieceName, 1, 1)
    if pieceRank == "b" or pieceRank == "n" then return true end
  end

  return false
  -- three same moves NOT IMPLEMENTED (TODO?)
end


function findAllPossibleMovesForPosition(pos)
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
        possibleMovesForThis = findAllLegitMovesForPiece(pos, a, x)

        -- append each move to the master list of all possible moves
        local i
--        print("for this given piece, the number for possible moves is " .. #possibleMovesForThis)
        for i, move in ipairs(possibleMovesForThis) do
          table.insert(allPossibleMoves, move)
        end

      end
    end
  end
  return allPossibleMoves
end

-- returns a list of moves that are possible according to how the pieces moves
-- they will be separately checked if they are legal and allowed
--
function findAllLegitMovesForPiece(pos, a, x)
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
        elseif not(targetColour == "p") then -- if encountered opponent piece move is legit, but stop iterating
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

function isLegal(move, pos)
  -- if the position after the move has your own king in check, it is not legal
  local alteredPos = Position:new({seed = pos})
  alteredPos = implementMove(alteredPos, move.from, move.to)

  local k, ka, kx -- king's position, k is used to store the piece for searching

  -- find where the king (held in __current__ position[9]) is in the altered position
  if pos[9] == "w" then k = k_w else k = k_b end
  ka, kx = locatePiece(alteredPos, k)

  -- check if any opponent threatens to kill it - which is, in correct terms, a Check
  if isThisSquareThreatened(alteredPos, ka, kx) then return false else return true end
end

function isThisSquareThreatened(pos, a, x)
  -- go through all possible next opponent moves, if any of them finds moving to a, x a legit (but not necessarily LEGAL) move then it's a check
  local possibleNextMoves = {}
  possibleNextMoves = findAllPossibleMovesForPosition(pos)

  local i
  for i, move in ipairs(possibleNextMoves) do
    if move.to.a == a and move.to.x == x then return true end
  end
  return false
end

function locatePiece(pos, piece)
  local a, x
  for a=1,8 do
    for x=1,8 do
      if pos[a][x] == piece then return a, x end
    end
  end
end


function filterMoves(func, moveList, pos)
   local newList= {}

   for i,move in pairs(moveList) do
       if func(move, pos) then
         local tempMove = Move:new()
         tempMove.from = move.from
         tempMove.to = move.to
         tempMove.name = move.name
         tempMove.score = move.score
         table.insert(newList, tempMove)
       end
   end
   return newList
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

  if temp == p_b and to.x == 1 then pos[to.a][to.x] = q_b end -- promotion to gueen
  if temp == p_w and to.x == 8 then pos[to.a][to.x] = q_w end -- promotion to gueen

  -- switch whose turn it is
  if pos[9] == "w" then pos[9] = "b" else pos[9] = "w" end

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
