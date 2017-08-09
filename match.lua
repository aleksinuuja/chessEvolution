Match = {}

function Match:new(params)
  o = {}

  o.position = {}
  o.algorithmWhite = {}
  o.algorithmBlack = {}

  o.gameOver = false
  o.winner = "" -- d = draw, s = stalemate

  setmetatable(o, self)
  self.__index = self
  return o
end

function Match:nextMove()
  if not self.gameOver then
    if self.position[9] == "w" then -- white's turn
      self.gameOver = self.algorithmWhite:makeAMove(self.position)
      if self.gameOver then
        print("white could not make a move, black is winning")
        if isPositionDraw(self.position) then self.winner = "d" else
          self.winner = "b"
          if isPositionStaleMate(self.position) then self.winner = "s" end
        end
      end
    elseif self.position[9] == "b" then -- black's turn
      self.gameOver = self.algorithmBlack:makeAMove(self.position)
      if self.gameOver then
        print("black could not make a move, white is winning")
        if isPositionDraw(self.position) then self.winner = "d" else
          self.winner = "w"
          if isPositionStaleMate(self.position) then self.winner = "s" end
        end
      end
    end
  end
end
