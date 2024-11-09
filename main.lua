-- main.lua

require("tetromino")
require("grid")
require("game")
require("input")
menu = require("menu")
crashHandler = require("crash_handler") -- Dodajemy crash handler
baseWidth = 640
baseHeight = 960
local scaleX, scaleY
function updateScale()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    scaleX = screenWidth / baseWidth
    scaleY = screenHeight / baseHeight
end

function love.load()
    gameState = "menu"
    menu.load()
    initGrid()
    initGame()
    initInput()
    updateScale() -- Oblicz początkową skalę
end

function love.resize(w, h)
    updateScale() -- Zaktualizuj skalę przy zmianie rozmiaru okna
end


function love.update(dt)
    crashHandler.setPosition("love.update") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.update(dt)
        elseif gameState == "game" then
            updateGame(dt)
            updateInput(dt)
        end
        crashHandler.update(dt) -- Aktualizacja crash handlera
    end)
end

function love.draw()
    crashHandler.setPosition("love.draw")
    crashHandler.monitor(function()
        love.graphics.push()
        love.graphics.scale(scaleX, scaleY) -- Ustaw skalowanie

        if gameState == "menu" then
            menu.draw()
        elseif gameState == "game" then
            local screenWidth = baseWidth
            local gridWidth = 10 * blockSize
            local offsetX = (screenWidth - gridWidth) / 2

            love.graphics.push()
            love.graphics.translate(offsetX, 0)

            drawGrid()
            drawGhostPiece()
            drawCurrentTetromino()

            love.graphics.pop()
            drawUI()
            drawButtons()
        end

        crashHandler.draw()
        love.graphics.pop() -- Przywróć poprzedni stan grafiki
    end)
end


function love.keypressed(key)
    crashHandler.setPosition("love.keypressed") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.keypressed(key)
        elseif gameState == "game" then
            handleInput(key, true)
        end
    end)
end

function love.keyreleased(key)
    crashHandler.setPosition("love.keyreleased") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "game" then
            handleInput(key, false)
        end
    end)
end

function love.mousepressed(x, y, button, istouch)
    crashHandler.setPosition("love.mousepressed")
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.mousepressed(x / scaleX, y / scaleY, button, istouch)
        else
            handleMousePressed(x / scaleX, y / scaleY, button)
        end
    end)
end

function love.mousereleased(x, y, button, istouch)
    crashHandler.setPosition("love.mousereleased")
    crashHandler.monitor(function()
        if gameState == "game" then
            handleMouseReleased(x / scaleX, y / scaleY, button, istouch)
        end
    end)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    crashHandler.setPosition("love.touchpressed")
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.touchpressed(id, x / scaleX, y / scaleY, dx / scaleX, dy / scaleY, pressure)
        elseif gameState == "game" then
            handleTouchPressed(id, x / scaleX, y / scaleY)
        end
    end)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    crashHandler.setPosition("love.touchreleased")
    crashHandler.monitor(function()
        if gameState == "game" then
            handleTouchReleased(id, x / scaleX, y / scaleY)
        end
    end)
end