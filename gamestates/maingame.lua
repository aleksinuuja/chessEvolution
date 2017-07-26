gameStates.maingame = {}
s = gameStates.maingame -- short ref to maingame state
s.isInitiated = false

require "textlogger"

function gameStates.maingame.initiateState()
  s.resetGame()
end

function s.resetGame()
  s.isPaused = false
  s.isControlsDisabled = false
  scrolloffsetX = 0
	scrolloffsetY = 0

  initPosition = {}

  table.insert(initPosition, {r_b, p_b, emp, emp, emp, emp, p_w, r_w})
  table.insert(initPosition, {n_b, p_b, emp, emp, emp, emp, p_w, n_w})
  table.insert(initPosition, {b_b, p_b, emp, emp, emp, emp, p_w, b_w})
  table.insert(initPosition, {q_b, p_b, emp, emp, emp, emp, p_w, q_w})
  table.insert(initPosition, {k_b, p_b, emp, emp, emp, emp, p_w, k_w})
  table.insert(initPosition, {b_b, p_b, emp, emp, emp, emp, p_w, b_w})
  table.insert(initPosition, {n_b, p_b, emp, emp, emp, emp, p_w, n_w})
  table.insert(initPosition, {r_b, p_b, emp, emp, emp, emp, p_w, r_w})

  textLogger = Textlogger:new({
		maxrows = 3,
	  rowheight = 20,
		textsize = 12,
	  updateSpeed = 3, -- seconds (how often log scrolls on it's own)
	  x = 10,
	  y = love.graphics.getHeight() - 100,
		blinkDuration = 0.050, -- milliseconds how quickly new message blinks
	  maxBlinks = 3})
end

function gameStates.maingame.draw()
  -- first draw zoomable game graphics
  love.graphics.push()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setLineWidth(1)
  love.graphics.scale(tv("scale"), tv("scale"))
  love.graphics.translate(scrolloffsetX, scrolloffsetY)

  -- draw background image which is as large as the game universe
  love.graphics.draw(bg, 0, 0, 0, UNIVERSESIZE, UNIVERSESIZE)

  -- draw a grid full of chessboards, either one big, 2x2, 3x3 or 4x4
  -- work in progress, let's draw first one board at given coordinates with given height and width
  drawChessBoard(nil, 0, 0, 512)
  drawChessBoard(nil, 512 + 50, 0, 512)
  drawChessBoard(nil, 0, 512 + 50, 512)
  drawChessBoard(nil, 512 + 50, 512 + 50, 512)

  -- then reset transformations and draw static overlay graphics such as texts and menus
  love.graphics.pop()
  textLogger:draw()

  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Current FPS: " .. tostring(currentFPS), 10, 10)
  love.graphics.print("piece at x=6, y=8: " .. returnPieceAt(initPosition, 6, 8), 10, 50)
end

function drawChessBoard(pos, x, y, width)
  local i, j
  local switch = -1
  for i=1,8 do
    switch = - switch
    for j=1,8 do

      -- first draw grid square
      switch = - switch
      if switch > 0 then
        love.graphics.setColor(200, 0, 200)
      else
        love.graphics.setColor(255, 200, 255)
      end
      love.graphics.rectangle("fill", x + (i-1)*width/8, y + (j-1)*width/8, width/8, width/8)

      love.graphics.setColor(255, 255, 255)
      if pos == nil then
        love.graphics.draw(initPosition[i][j], x + (i-1)*width/8, y + (j-1)*width/8, 0, (width/8)/p_w:getWidth(), (width/8)/p_w:getWidth())
      else
        love.graphics.draw(pos[i][j], x + (i-1)*width/8, y + (j-1)*width/8, 0, (width/8)/p_w:getWidth(), (width/8)/p_w:getWidth())
      end
    end
  end

end

-- returns a string with the piece name
function returnPieceAt(position, x, y)
  imageAt = position[x][y]
  if imageAt == p_b then return "p_b"
  elseif imageAt == n_b then return "n_b"
  elseif imageAt == b_b then return "b_b"
  elseif imageAt == r_b then return "r_b"
  elseif imageAt == q_b then return "q_b"
  elseif imageAt == k_b then return "k_b"
  elseif imageAt == p_w then return "p_w"
  elseif imageAt == n_w then return "n_w"
  elseif imageAt == b_w then return "b_w"
  elseif imageAt == r_w then return "r_w"
  elseif imageAt == q_w then return "q_w"
  elseif imageAt == k_w then return "k_w"
  elseif imageAt == emp then return "emp"
  end
end

function gameStates.maingame.mousepressed(x, y, button)
  if button == 1 then
    print("mouse button pressed in maingame!")

  end
end



function gameStates.maingame.mousereleased(x, y, button)
  if button == 1 then
    -- reset dragging for all sliders
--[[
    timeScaleSlider.dragging.active = false
    zoomSlider.dragging.active = false
    inspector.dragging.active = false
]]--
  end
end

function gameStates.maingame.keypressed(key)
  if key == "space" then
    s.isPaused = not(s.isPaused) -- switch pause on and off
--  elseif key == "b" then
--    table.insert(boids, Boid:new({x = math.random()*universe.width, y = math.random()*universe.height}))
  end
end

function gameStates.maingame.update(dt)
  if not isInitiated then
    isInitiated = true
    gameStates.maingame.initiateState()
    tweenEngine:createTween("scale", 2, 0.5, 0.5, linearTween)
  end

  if not s.isPaused then

    textLogger:update()

  end -- is not paused
end




-- Collision detection taken function from http://love2d.org/wiki/BoundingBox.lua
-- Returns true if two boxes overlap, false if they don't
-- x1,y1 are the left-top coords of the first box, while w1,h1 are its width and height
-- x2,y2,w2 & h2 are the same, but for the second box
function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function updateCameraOffsetsByMouse(x, y) -- gets x and y value from mouse
  local screenwidth = (love.graphics.getWidth() / tv("scale")) -- how much of the universe is visible right now
	local screenheight = (love.graphics.getHeight() / tv("scale"))
  local scrollBoundary = 100
  local scrollSpeed = 10
  -- scrolling left
  if (x < scrollBoundary and x >= 0) then
    local edgeAccelerate = math.max(((scrollBoundary - x))-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetX = scrolloffsetX + scrollSpeed*5
  end
  -- scrolling right
  if (x > (love.graphics.getWidth() - scrollBoundary) and x <= love.graphics.getWidth()) then
    local edgeAccelerate = math.max(scrollBoundary - (love.graphics.getWidth() - x)-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetX = scrolloffsetX - scrollSpeed*5
  end
  -- scrolling up
  if (y < scrollBoundary and y >= 0) then
    local edgeAccelerate = math.max(((scrollBoundary - y))-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetY = scrolloffsetY + scrollSpeed*5
  end
  -- scrolling down
  if (y > (love.graphics.getHeight() - scrollBoundary) and y <= love.graphics.getHeight()) then
    local edgeAccelerate = math.max(scrollBoundary - (love.graphics.getHeight() - y)-scrollBoundary/2, 0)
    scrollSpeed = scrollSpeed + edgeAccelerate/2 -- faster scrolling closer to edge
    scrolloffsetY = scrolloffsetY - scrollSpeed*5
  end
  -- don't allow showing black space - stop scroll at boundaries - fix offset when zooming
  if scrolloffsetX > 0 then scrolloffsetX = 0 end
  if scrolloffsetY > 0 then scrolloffsetY = 0 end
  if -scrolloffsetX > universe.width-screenwidth then scrolloffsetX = -(universe.width-screenwidth) end
  if -scrolloffsetY > universe.height-screenheight then scrolloffsetY = -(universe.height-screenheight) end

end

-- center camera to x, y by calculating correct scrolloffset
-- except when close to universe boundaries
function centerCameraOffsets(x, y)

	local screenwidth = (love.graphics.getWidth() / tv("scale"))
	local screenheight = (love.graphics.getHeight() / tv("scale"))
	local midpointx = - scrolloffsetX + (screenwidth  / 2)
	local midpointy = - scrolloffsetY + (screenheight / 2)

	-- so the delta to move scrolloffset is the difference between where the ship is drawn and the midpoint
	local deltax = midpointx - x
	local deltay = midpointy - y

	-- calculate distance from universe edge
	local xdistance = universe.width - midpointx
	local ydistance = universe.height - midpointy

	-- determine if ship coordinates are near boundary or in the middle - this affects scrolling
	-- values as strings "start", "mid", "end"
	local xarea = "mid"
	local yarea = "mid"
	if x < (screenwidth / 2) then xarea = "start" end
	if x > (universe.width - (screenwidth / 2)) then xarea = "end" end
	if y < (screenheight / 2) then yarea = "start" end
	if y > (universe.height - (screenheight / 2)) then yarea = "end" end

	-- in mid area, scroll freely
	if xarea == "mid" then scrolloffsetX = scrolloffsetX + deltax end
	if yarea == "mid" then scrolloffsetY = scrolloffsetY + deltay end

	-- if close to zero, that is "start", do nothing, offset remains put

	-- if close to end of universe boundary, that is "end" calculate correct offset
	-- it's universe boundary - screenwidth/height
	if xarea == "end" then scrolloffsetX = - (universe.width - screenwidth) end
	if yarea == "end" then scrolloffsetY = - (universe.height - screenheight) end

  if not(tv("scale") >= (love.graphics.getWidth() / universe.width)) then
		-- if scale is so zoomed out that the universe width is smaller in width than the screen, center it
		local actualWidthOfUniverse = universe.width*tv("scale")
		local centerXDelta = (love.graphics.getWidth() - actualWidthOfUniverse)/2
		scrolloffsetX = centerXDelta/tv("scale")
	end

end

-- return 'v' rounded to 'p' decimal places:
function round(v, p)
local mult = math.pow(10, p or 0) -- round to 0 places when p not supplied
    return math.floor(v * mult + 0.5) / mult;
end
