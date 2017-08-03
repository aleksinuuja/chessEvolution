Ticker = {}

function Ticker:new(params)
  o = {}
  o.lastStamp = love.timer.getTime()
  o.tickDuration = 0.3 -- seconds
  o.tickFunction = params.tickFunction

  setmetatable(o, self)
  self.__index = self
  return o
end

function Ticker:update(dt)
  local timeElapsed = love.timer.getTime() - self.lastStamp
  if timeElapsed > (self.tickDuration/timeScale) then
    self.lastStamp = love.timer.getTime()
    -- call tick function now
    self.tickFunction()
  end
end
