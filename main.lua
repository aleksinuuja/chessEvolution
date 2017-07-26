require 'tween2'

function love.load()
	math.randomseed(os.time())

	UNIVERSESIZE = 1 -- factor to scale bg image with
	timeScale = 1 -- number of updates before drawing

  bg = love.graphics.newImage("graphics/bigbg.jpg")
	p_b = love.graphics.newImage("graphics/p_b.png")
	p_w = love.graphics.newImage("graphics/p_w.png")
	n_b = love.graphics.newImage("graphics/n_b.png")
	n_w = love.graphics.newImage("graphics/n_w.png")
	b_b = love.graphics.newImage("graphics/b_b.png")
	b_w = love.graphics.newImage("graphics/b_w.png")
	r_b = love.graphics.newImage("graphics/r_b.png")
	r_w = love.graphics.newImage("graphics/r_w.png")
	q_b = love.graphics.newImage("graphics/q_b.png")
	q_w = love.graphics.newImage("graphics/q_w.png")
	k_b = love.graphics.newImage("graphics/k_b.png")
	k_w = love.graphics.newImage("graphics/k_w.png")
	emp = love.graphics.newImage("graphics/emp.png")


	universe = {
		width = bg:getWidth() * UNIVERSESIZE,
		height = bg:getHeight() * UNIVERSESIZE
	}

	tweenEngine = Tween:new()
	initiateTweenValues()

	-- initiate state handling
	gameStates = {}
	stateTimeStamp = 0
	timeInState = 0
	gotoGameState("maingame")
	currentSubState = "none"
	require 'gamestates/maingame'

	currentFPS = love.timer.getFPS()
	lowestFPS = 30
	highestFPS = 30
end

function gotoGameState(st)
	currentState = st
	stateTimeStamp = love.timer.getTime()
end

function initiateTweenValues()
 	tweenEngine:newKeyAndValue("scale", 1) -- value used to zoom in and out the whole game
	tweenEngine:newKeyAndValue("logTextY", 0)
	tweenEngine:newKeyAndValue("logAlpha", 0)
end

function love.keypressed(key)
	if key == "escape" then -- this is global to all states
		print("Lowest FPS: " .. lowestFPS)
		print("Highest FPS: " .. highestFPS)
		love.event.quit()
--	elseif key == "z" then -- USE D FOR DEBUGGING BUTTONS
--		generateItemPack()
	else
		if currentSubState == "none" then
			gameStates[currentState].keypressed(key)
		else -- if in substate, it overrides key input from main gamestate
			gameStates[currentSubState].keypressed(key)
		end
	end
end

function love.mousepressed(x, y, button)
	if currentSubState == "none" then
		gameStates[currentState].mousepressed(x, y, button)
	else -- if in substate, it overrides key input from main gamestate
		gameStates[currentSubState].mousepressed(x, y, button)
	end
end

function love.mousereleased(x, y, button)
	if currentSubState == "none" then
		gameStates[currentState].mousereleased(x, y, button)
	else -- if in substate, it overrides key input from main gamestate
		gameStates[currentSubState].mousereleased(x, y, button)
	end
end

function love.draw()
		gameStates[currentState].draw()
		if not(currentSubState == "none") then -- if in substate, draw both main gamestate and substate
			gameStates[currentSubState].draw()
		end
end

function love.update(dt)
	-- track FPS
	currentFPS = love.timer.getFPS()
	if currentFPS < lowestFPS then lowestFPS = currentFPS end
	if currentFPS > highestFPS then highestFPS = currentFPS end

	timeInState = love.timer.getTime() - stateTimeStamp

	for i=1,timeScale do -- call update as many times as timeScale
		tweenEngine:update(dt)
		gameStates[currentState].update(dt)
		if not(currentSubState == "none") then -- if in substate, update both main gamestate and substate
			gameStates[currentSubState].update(dt)
		end
	end
end
