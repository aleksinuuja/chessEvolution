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
    print("white makes a move")
    self.position = self.algorithmWhite:makeAMove(self.position)
    print("moven jälkee 1,1 pala on " .. returnPieceAt(self.position,1,1))
  elseif self.position[9] == "b" then -- black's turn
    print("black makes a move")
    self.position = self.algorithmBlack:makeAMove(self.position)
  end


end
