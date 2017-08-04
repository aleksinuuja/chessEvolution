Button = {}

function Button:new(params)
  o = {}
  o.x = params.x
  o.y = params.y
  o.height = params.height
  o.width = params.width
  o.sprite = params.sprite
  o.action = params.action -- function to be called on click

  setmetatable(o, self)
  self.__index = self
  return o
end

function Button:draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.draw(self.sprite, self.x, self.y, 0, self.width/self.sprite:getWidth(), self.height/self.sprite:getHeight())
end
