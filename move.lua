Move = {}

function Move:new(params)
  o = {}
  o.from = {}
  o.to = {}
  o.score = 0
  o.name = ""

  setmetatable(o, self)
  self.__index = self
  return o
end
