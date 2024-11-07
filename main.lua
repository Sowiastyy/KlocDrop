-- main.lua

require("tetromino")
require("grid")
require("game")
require("input")
menu = require("menu")
crashHandler = require("crash_handler") -- Dodajemy crash handler

function love.load()
    gameState = "menu"
    menu.load()
    initGrid()
    initGame()
    initInput()
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
    crashHandler.setPosition("love.draw") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.draw()
        elseif gameState == "game" then
            local screenWidth = love.graphics.getWidth()
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
        crashHandler.draw() -- Rysowanie crash handlera, jeśli wystąpił błąd
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
    crashHandler.setPosition("love.mousepressed") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.mousepressed(x, y, button, istouch)
        end
    end)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    crashHandler.setPosition("love.touchpressed") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "menu" then
            menu.touchpressed(id, x, y, dx, dy, pressure)
        elseif gameState == "game" then
            handleTouchPressed(id, x, y)
        end
    end)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    crashHandler.setPosition("love.touchreleased") -- Ustawiamy pozycję
    crashHandler.monitor(function()
        if gameState == "game" then
            handleTouchReleased(id, x, y)
        end
    end)
end
