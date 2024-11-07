buttons = {}
local buttonImages = {} -- Table to store button images

local gridColumns = 4
local gridRows = 2
local buttonSpacing = 10
local offset = 20

function initInput()
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local buttonSize = math.min(
        (screenWidth - (gridColumns + 1) * buttonSpacing - 2 * offset) / gridColumns,
        (screenHeight - (gridRows + 1) * buttonSpacing - 2 * offset) / gridRows
    )
    
    local yPosition = (blockSize * 20) + 10

    -- Load button images
    buttonImages["rotate90"] = love.graphics.newImage("assets/buttons/rotate90.png")
    buttonImages["rotate180"] = love.graphics.newImage("assets/buttons/rotate180.png")
    buttonImages["rotate270"] = love.graphics.newImage("assets/buttons/rotate270.png")
    buttonImages["hold"] = love.graphics.newImage("assets/buttons/hold.png")
    buttonImages["hardDrop"] = love.graphics.newImage("assets/buttons/hardDrop.png")
    buttonImages["left"] = love.graphics.newImage("assets/buttons/left.png")
    buttonImages["right"] = love.graphics.newImage("assets/buttons/right.png")
    buttonImages["softDrop"] = love.graphics.newImage("assets/buttons/softDrop.png")

    -- Create button definitions with position and image
    buttons = {
        {x = offset + buttonSpacing * 2 + buttonSize, y = yPosition + buttonSize + buttonSpacing, width = buttonSize, height = buttonSize, image = buttonImages["left"]},
        {x = offset + buttonSpacing, y = yPosition + buttonSize + buttonSpacing, width = buttonSize, height = buttonSize, image = buttonImages["hardDrop"]},
        {x = offset + buttonSpacing * 4 + 3 * buttonSize, y = yPosition, width = buttonSize, height = buttonSize, image = buttonImages["hold"]},
        {x = offset + buttonSpacing * 3 + 2 * buttonSize, y = yPosition + buttonSize + buttonSpacing, width = buttonSize, height = buttonSize, image = buttonImages["right"]},
        {x = offset + buttonSpacing * 4 + 3 * buttonSize, y = yPosition + buttonSize + buttonSpacing, width = buttonSize, height = buttonSize, image = buttonImages["softDrop"]},
        {x = offset + buttonSpacing, y = yPosition, width = buttonSize, height = buttonSize, image = buttonImages["rotate90"]},
        {x = offset + buttonSpacing * 2 + buttonSize, y = yPosition, width = buttonSize, height = buttonSize, image = buttonImages["rotate180"]},
        {x = offset + buttonSpacing * 3 + 2 * buttonSize, y = yPosition, width = buttonSize, height = buttonSize, image = buttonImages["rotate270"]},
    }
end

function drawButtons()
    love.graphics.setColor(1, 1, 1)
    for _, button in pairs(buttons) do
        local scaleX = button.width / button.image:getWidth()
        local scaleY = button.height / button.image:getHeight()
        
        -- Draw the button image scaled to the button size
        love.graphics.draw(button.image, button.x, button.y, 0, scaleX, scaleY)
    end
end

function updateInput(dt)
    -- Możesz tutaj dodać logikę trzymania przycisków
end

function handleTouchPressed(id, x, y)
    for action, button in pairs(buttons) do
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            executeAction(action, true)
        end
    end
end

function handleTouchReleased(id, x, y)
    for action, button in pairs(buttons) do
        if x >= button.x and x <= button.x + button.width and y >= button.y and y <= button.y + button.height then
            executeAction(action, false)
        end
    end
end

function executeAction(action, isPressed)
    if isPressed then
        if action == "rotate90" then
            currentTetromino:rotate(90)
        elseif action == "rotate180" then
            currentTetromino:rotate(180)
        elseif action == "rotate270" then
            currentTetromino:rotate(270)
        elseif action == "left" then
            moveLeft = true
            moveRight = false
            autoShiftTimer = 0
            autoShiftDirection = -1
            currentTetromino:move(-1, 0)
        elseif action == "right" then
            moveRight = true
            moveLeft = false
            autoShiftTimer = 0
            autoShiftDirection = 1
            currentTetromino:move(1, 0)
        elseif action == "softDrop" then
            softDropping = true
            softDropTimer = 0
        elseif action == "hardDrop" then
            while currentTetromino:move(0, 1) do
                score = score + 2
            end
            lockTetromino(currentTetromino)
            local lines = clearLines()
            processScore(lines)
            spawnTetromino()
            canHold = true
        elseif action == "hold" then
            holdCurrentTetromino()
        end
    else
        if action == "left" then
            moveLeft = false
            autoShiftTimer = 0
        elseif action == "right" then
            moveRight = false
            autoShiftTimer = 0
        elseif action == "softDrop" then
            softDropping = false
        end
    end
end
