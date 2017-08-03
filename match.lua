Match = {}

function Match:new(params)
  o = {}

  o.position = {}
  o.algorithmWhite = {}
  o.algorithmBlack = {}

  setmetatable(o, self)
  self.__index = self
  return o
end

function Match:nextMove()
  if self.position[9] == "w" then -- white's turn
    self.algorithmWhite:makeAMove(self.position)
  elseif self.position[9] == "b" then -- black's turn
    self.algorithmBlack:makeAMove(self.position)
  end


end
