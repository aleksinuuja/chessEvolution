Match = {}

function Match:new(params)
  o = {}

  o.position = {}
  o.algorithmWhite = {}
  o.algorithmBlack = {}

  o.gameOver = false
  o.winner = ""

  setmetatable(o, self)
  self.__index = self
  return o
end

function Match:nextMove()
  if not self.gameOver then
    if self.position[9] == "w" then -- white's turn
      self.gameOver = self.algorithmWhite:makeAMove(self.position)
      if self.gameOver then self.winner = "w" end
    elseif self.position[9] == "b" then -- black's turn
      self.gameOver = self.algorithmBlack:makeAMove(self.position)
      if self.gameOver then self.winner = "b" end
    end
  else
      -- no move this is in gameover
  end
end
