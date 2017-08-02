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
        print("found my own piece at " .. a .. ", " ..x)
        print("it's name is " .. pieceName)
        print("it's colour is " .. pieceColour)
        print("it's rank is " .. pieceRank)

        -- find all legit moves it can make, fetch a list of Move class objects
        -- calculate and store a score for each move as well - store in the Move instance
        possibleMovesForThis = findAllLegitMoves(pos, a, x)

        -- append each move to the master list of all possible moves
        local i
        print("for this given piece, the number for possible moves is " .. #possibleMovesForThis)
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
  -- make the move and return the changed position



  -- execute the move
  -- pos[x][y] = piece

  -- the pos[9] says whose turn is next, switch it
  if pos[9] == "w" then pos[9] = "b" else pos[9] = "w" end

  return pos
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

    -- the knight has 8 possible moves: check each location
    local ta, tx -- target coordinates

    legit = true -- always start with assumption the move is legit
    ta = a+1
    tx = x+2
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a+1
    tx = x-2
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a-1
    tx = x+2
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then
      print("outside the board")
      legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then
        print("blocked by own piece")
        legit = false
      end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a-1
    tx = x-2
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a+2
    tx = x+1
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a+2
    tx = x-1
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a-2
    tx = x+1
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

    legit = true -- always start with assumption the move is legit
    ta = a-2
    tx = x-1
    print("ta: " .. ta)
    print("tx: " .. tx)
    if not((0 < ta and ta < 9) and (0 < tx and tx < 9)) then legit = false -- outside the board!
    else
      targetColour = string.sub(returnPieceAt(pos, ta, tx), 3)
      if targetColour == pos[9] then legit = false end -- the target's one of my own colour
    end
    if legit then
      print("this knight move is legit!!")
      scoreThisMoveAndAddToList(legitMoves, pos, {a = a, x = x}, {a = ta, x = tx}, "Knight to ")
    end

  elseif pieceRank == "b" then
  elseif pieceRank == "r" then
  elseif pieceRank == "q" then
  elseif pieceRank == "k" then
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
