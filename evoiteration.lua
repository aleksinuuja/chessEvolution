EvoIteration = {}

function EvoIteration:new(params)
  o = {}

  o.matches = {}
  o.matchesActive = 0
  o.blackWins = 0
  o.whiteWins = 0
  o.winner = "" -- d = draw, s = stalemate

  setmetatable(o, self)
  self.__index = self
  return o
end

function EvoIteration:update()
  if self.matchesActive == 0 then
    print("all matches are overrr!!!")
    print("white wins " .. self.whiteWins .. "times.")
    print("black wins " .. self.blackWins .. "times.")
  end
end
