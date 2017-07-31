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
  if pos[9] == "w" then pos[9] = "b" else pos[9] = "w" end

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
  pos[x][y] = piece

  return pos
end