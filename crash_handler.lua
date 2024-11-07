-- crash_handler.lua

local crashHandler = {}
local lastPosition = ""
local crashOccurred = false
local crashMessage = ""
local crashTimer = 0

function crashHandler.setPosition(position)
    lastPosition = position
end

function crashHandler.monitor(func)
    -- Funkcja monitorująca, próbuje uruchomić kod w `func`, łapie błędy
    local status, err = pcall(func)
    if not status then
        crashOccurred = true
        crashMessage = "Crash at: " .. lastPosition .. "\nError: " .. err
        crashTimer = 5 -- Ustaw czas wyświetlania błędu na 5 sekund
        print(crashMessage)
    end
end

function crashHandler.update(dt)
    -- Aktualizacja licznika czasu dla komunikatu o błędzie
    if crashOccurred then
        crashTimer = crashTimer - dt
        if crashTimer <= 0 then
            crashOccurred = false
        end
    end
end

function crashHandler.draw()
    -- Rysowanie komunikatu o błędzie na środku ekranu
    if crashOccurred then
        love.graphics.setColor(1, 0, 0) -- Kolor czerwony
        love.graphics.setFont(love.graphics.newFont(24)) -- Większa czcionka
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        love.graphics.printf(crashMessage, screenWidth / 4, screenHeight / 2, screenWidth / 2, "center")
        love.graphics.setColor(1, 1, 1) -- Przywrócenie koloru
    end
end

return crashHandler
