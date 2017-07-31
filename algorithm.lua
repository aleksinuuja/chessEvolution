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
  return pos
end
