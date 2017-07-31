Match = {}

function Match:new(params)
  o = {}
  o.position = Position:new()
  o.algorithmWhite = Algorithm:new("w")
  o.algorithmBlack = Algorithm:new("b")

  setmetatable(o, self)
  self.__index = self
  return o
end
