gameStates.maingame = {}
s = gameStates.maingame -- short ref to maingame state
s.isInitiated = false

require "textlogger"
require "position"
require "match"
require "algorithm"
require "move"
require "ticker"
require "slider"
require "button"
require "evoiteration"

function gameStates.maingame.initiateState()
  s.resetGame()
end

function s.resetGame()
  s.isPaused = false
  s.isControlsDisabled = false
  isZoomedIn = false
  zoomedInBoard = 0
  scrolloffsetX = 0
	scrolloffsetY = 0

  gridSize = 5

  evoI = EvoIteration:new()
  evoI.matches = {}
--  allMatches = {}

  -- let's create 25 chess matches and run the simultaneously
  local i
  for i=1,gridSize*gridSize do
    m = Match:new()
    m.position = Position:new()
    m.algorithmWhite = Algorithm:new({colour = "w"})
    m.algorithmBlack = Algorithm:new({colour = "b"})
    table.insert(evoI.matches, m) -- add match to the array of all matches
    evoI.matchesActive = evoI.matchesActive + 1
  end

  function updateMatches()
--    print("jahas ticker kutsui updateMacthes joten jokaisen matsin seuraava siirto")
    local i
    for i, match in ipairs(evoI.matches) do
      match:nextMove()
    end
  end
  theTicker = Ticker:new({tickFunction = updateMatches})

  timeScaleSlider = Slider:new({
    x = 1000,
    y = 10,
    width = 100,
    valuesUpTo = 1000
  })

  textLogger = Textlogger:new({
		maxrows = 3,
	  rowheight = 20,
		textsize = 12,
	  updateSpeed = 3, -- seconds (how often log scrolls on it's own)
	  x = 10,
	  y = love.graphics.getHeight() - 100,
		blinkDuration = 0.050, -- milliseconds how quickly new message blinks
	  maxBlinks = 3})

  closeButton = Button:new({
    x = love.graphics.getHeight()+10,
    y = 10,
    width = 50,
    height = 50,
    sprite = closePng
  })
end

function gameStates.maingame.draw()
  -- first draw zoomable game graphics
  love.graphics.push()
  love.graphics.setColor(255, 255, 255)
  love.graphics.setLineWidth(1)
  love.graphics.scale(tv("scale"), tv("scale"))
  love.graphics.translate(tv("sX"), tv("sY"))

  -- draw background image - replaced with a coloured rectangle
--  love.graphics.draw(bg)
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth()/tv("scale"), love.graphics.getHeight()/tv("scale"))

  -- draw a grid full of chessboards, either one big, 2x2, 3x3 or 4x4
  -- work in progress, let's draw first one board at given coordinates with given height and width
  drawGridOfBoards(gridSize)

  -- then reset transformations and draw static overlay graphics such as texts and menus
  love.graphics.pop()

  -- right side of screen is overlaid with black
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", love.graphics.getHeight(), 0, love.graphics.getWidth()-love.graphics.getHeight(), love.graphics.getHeight())

  if isZoomedIn then
    if evoI.matches[zoomedInBoard].gameOver then
      local winner = evoI.matches[zoomedInBoard].winner
      love.graphics.setColor(255, 255, 255)
      if winner == "w" then
        love.graphics.print("WHITE WINS", love.graphics.getHeight()+10, 80)
      elseif winner == "b" then
        love.graphics.print("BLACK WINS", love.graphics.getHeight()+10, 80)
      elseif winner == "d" then
        love.graphics.print("DRAW", love.graphics.getHeight()+10, 80)
      elseif winner == "s" then
        love.graphics.print("STALEMATE", love.graphics.getHeight()+10, 80)
      end
    end
  end

  timeScaleSlider:draw()
  textLogger:draw()
  if isZoomedIn then
    closeButton:draw()
  end

  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Current FPS: " .. tostring(currentFPS), love.graphics.getHeight()+10, 10)
  love.graphics.print("Matches active: " .. evoI.matchesActive, love.graphics.getHeight()+10, 30)
end

function drawGridOfBoards(n)
  local i, j
  local boardWidth = universe.height/n - BoardGridMargin

  for i=1,n do
    for j=1,n do
      drawChessBoard(evoI.matches[(j-1)*n+i].position, (i-1)*(boardWidth+BoardGridMargin), (j-1)*(boardWidth+BoardGridMargin), boardWidth)
      if evoI.matches[(j-1)*n+i].gameOver then
        drawEndOverlay((i-1)*(boardWidth+BoardGridMargin), (j-1)*(boardWidth+BoardGridMargin), boardWidth, evoI.matches[(j-1)*n+i].winner)
      end
    end
  end

end

function drawChessBoard(pos, locx, locy, width)
  local a, x
  local switch = -1
  for a=1,8 do
    switch = - switch
    for x=1,8 do

      -- first draw background square with one of the 2 bg colours
      switch = - switch
      if switch > 0 then
        love.graphics.setColor(200, 0, 200)
      else
        love.graphics.setColor(255, 200, 255)
      end
      love.graphics.rectangle("fill", locx + (a-1)*width/8, locy + (9-x-1)*width/8, width/8, width/8)

      -- then draw the piece
      love.graphics.setColor(255, 255, 255)
      if pos == nil then
        print("nyt niiku piirän lautaa mut oon saanu positioks nil")
        love.graphics.draw(initPosition[a][x], locx + (a-1)*width/8, locy + (9-x-1)*width/8, 0, (width/8)/p_w:getWidth(), (width/8)/p_w:getWidth())
      else
        love.graphics.draw(pos[a][x], locx + (a-1)*width/8, locy + (9-x-1)*width/8, 0, (width/8)/p_w:getWidth(), (width/8)/p_w:getWidth())
      end
    end
  end
end


function drawEndOverlay(locx, locy, width, winner)
  if not isZoomedIn then
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", locx+50, locy+(width/2-25), 200, 50)

    love.graphics.setColor(255, 255, 255)
    if winner == "w" then
      love.graphics.print("WHITE WINS", locx+50+10, locy+(width/2-25)+10, 0, 2, 2)
    elseif winner == "b" then
      love.graphics.print("BLACK WINS", locx+50+10, locy+(width/2-25)+10, 0, 2, 2)
    elseif winner == "d" then
      love.graphics.print("DRAW", locx+50+10, locy+(width/2-25)+10, 0, 2, 2)
    elseif winner == "s" then
      love.graphics.print("STALEMATE", locx+50+10, locy+(width/2-25)+10, 0, 2, 2)
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

-- returns a string with the piece name - when given the imagename
function returnPieceName(piece)
  imageAt = piece
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
    -- timeScaleSlider dragging
    if x > timeScaleSlider.rect.x and x < timeScaleSlider.rect.x + timeScaleSlider.rect.width
    and y > timeScaleSlider.rect.y and y < timeScaleSlider.rect.y + timeScaleSlider.rect.height
    then
      timeScaleSlider.dragging.active = true
      timeScaleSlider.dragging.diffX = x - timeScaleSlider.rect.x
      timeScaleSlider.dragging.diffY = y - timeScaleSlider.rect.y
    end

    -- if this program was smart, it would have a list of clickables and they would have a trigger function
    -- now I just manually go through each clickable element

    -- clicked on the board grid (square with both height and width = love.graphics.getHeight())
    if x < love.graphics.getHeight() and y < love.graphics.getHeight() then
      -- if playing this is potentially a move

      -- if in evolution-farm (gamestate can later be also player-vs-AI), this is select board to zoom it
      local scrolloffsetX, scrolloffsetY = determineWhichBoardWasClicked(x, y)
      scrolloffsetX = - scrolloffsetX
      scrolloffsetY = - scrolloffsetY
      local currentScale = tweenEngine:returnValue("scale")
      local currentSX, currentSY = tweenEngine:returnValue("sX"), tweenEngine:returnValue("sY")
      local boardWidth = universe.height/gridSize - BoardGridMargin
      local newScale = love.graphics.getHeight()/boardWidth
      tweenEngine:createTween("scale", currentScale, newScale, 0, linearTween)
      tweenEngine:createTween("sX", currentSX, scrolloffsetX, 0, linearTween)
      tweenEngine:createTween("sY", currentSY, scrolloffsetY, 0, linearTween)
      isZoomedIn = true
    end

    -- clicked on closeButton
    if isZoomedIn then
      if x > closeButton.x and x < closeButton.x + closeButton.width
      and y > closeButton.y and y < closeButton.y + closeButton.height
      then
        -- return to normal view
        local currentScale = tweenEngine:returnValue("scale")
        local currentSX, currentSY = tweenEngine:returnValue("sX"), tweenEngine:returnValue("sY")
        local newScale = 0.5
        tweenEngine:createTween("scale", currentScale, newScale, 0, linearTween)
        tweenEngine:createTween("sX", currentSX, 0, 0, linearTween)
        tweenEngine:createTween("sY", currentSY, 0, 0, linearTween)
        isZoomedIn = false
        zoomedInBoard = 0
      end
    end

  end
end

function determineWhichBoardWasClicked(x, y)
  n = gridSize
  x = x/tv("scale")
  y = y/tv("scale")
  local i, j
  local bx, by -- individual board location
  local count = 0
  local boardWidth = universe.height/n - BoardGridMargin

  for j=1,n do
    for i=1,n do
      count = count + 1
      bx = (i-1)*(boardWidth+BoardGridMargin)
      by = (j-1)*(boardWidth+BoardGridMargin)
      if x > bx and x < (bx + boardWidth) and
      y > by and y < (by + boardWidth) then
        zoomedInBoard = count
        return bx, by
      end
    end
  end
end

function gameStates.maingame.mousereleased(x, y, button)
  if button == 1 then
    -- reset dragging for all sliders (individually)
    timeScaleSlider.dragging.active = false
  end
end

function gameStates.maingame.keypressed(key)
  if key == "space" then
    s.isPaused = not(s.isPaused) -- switch pause on and off
  elseif key == "z" then
    if gridSize > 1 then gridSize = gridSize - 1 end
  elseif key == "x" then
    gridSize = gridSize + 1
  end
end

function gameStates.maingame.update(dt)
  if not isInitiated then
    isInitiated = true
    gameStates.maingame.initiateState()
    tweenEngine:createTween("scale", 2, 0.5, 0.5, linearTween)
    tweenEngine:createTween("zoomOffsetX", 200, 500, 0.5, linearTween)
    tweenEngine:createTween("zoomOffsetY", 200, 0, 0.5, linearTween)
  end

  if not s.isPaused then
--    zoomOffsetX = tv("zoomOffsetX")
--    zoomOffsetY = tv("zoomOffsetY")

    evoI:update()
    textLogger:update()
    theTicker:update()
    timeScaleSlider:update()

    theTicker.tickDuration = (1000 - timeScaleSlider.value) / 1000


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

--[[
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
]]--


-- return 'v' rounded to 'p' decimal places:
function round(v, p)
local mult = math.pow(10, p or 0) -- round to 0 places when p not supplied
    return math.floor(v * mult + 0.5) / mult;
end
