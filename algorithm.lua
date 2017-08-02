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
        -- calculate and store a score for the move as well - store in the Move instance
        possibleMovesForThis = findAllLegitMoves(pos, a, x)

        -- append each move to the master list of all possible moves


      end
    end
  end


  -- select the move with the highest score
  -- make the move and return the changed position


  -- let's assign a random piece at a random location
  local x, y, p, piece
  x = math.random(8)
  y = math.random(8)
  p = math.random(13)
  if p == 1 then piece = p_b
  elseif p == 2 then piece = n_b
  elseif p == 3 then piece = b_b
  elseif p == 4 then piece = r_b
  elseif p == 5 then piece = q_b
  elseif p == 6 then piece = k_b
  elseif p == 7 then piece = p_w
  elseif p == 8 then piece = n_w
  elseif p == 9 then piece = b_w
  elseif p == 10 then piece = r_w
  elseif p == 11 then piece = q_w
  elseif p == 12 then piece = k_w
  elseif p == 13 then piece = emp
  end

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
  local step
  local move = Move:new()
  local alteredPos = pos

  -- we go through possible moves and if they are legit, create a Move object and add to legitMoves list

  if pieceRank == "p" then
    print("finding legit moves for my pawn")
    if pieceColour == "w" then step = 1 else step = -1 end

    -- one step ahead
    legit = true -- always start with assumption the move is legit
    print("i'm sitting at " .. a .. ", " .. x)
    print("if i took one step i would be in " .. a .. ", " .. x+step)
    print("in that square is a " .. returnPieceAt(pos, a, x+step))
    if not(returnPieceAt(pos, a, x+step) == "emp") then legit = false end
    if legit then
      print("found a legit move, my pawn can take one step forward")
      move.from = {a = a, x = x}
      move.to = {a = a, x = x+step}
      -- alteredPos = implementMove(pos, move.from, move.to)
      move.score = 0 -- scoreThisPos(alteredPos)
      table.insert(legitMoves, move)
    end

    -- two steps ahead

    -- capture left

    -- capture rigth

  elseif pieceRank == "n" then
  elseif pieceRank == "b" then
  elseif pieceRank == "r" then
  elseif pieceRank == "q" then
  elseif pieceRank == "k" then
  end

  -- return a list of Move objects, complete with given scores
  return legitMoves
end

-- from and to are tables with a and x
function implementMove(pos, from, to)
  local temp = pos[from.a][from.x]
  pos[from.a][from.x] = emp
  pos[to.a][to.x] = temp

  return pos
end
