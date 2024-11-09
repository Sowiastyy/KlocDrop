local menu = {}

function menu.load()
    -- Ładowanie nowej czcionki
    menu.titleFont = love.graphics.newFont("assets/conform-f-s.ttf", 60)
    menu.optionFont = love.graphics.newFont("assets/conform-f-s.ttf", 40)

    menu.options = {"Start Game", "Options", "Exit"}
    menu.selected = 1
    menu.title = "Kloc\nDrop"
    menu.optionYPositions = {400, 500, 600}
    menu.optionHeight = 60

    -- Inicjalizacja spadających klocków
    menu.blocks = {}
    menu.spawnTimer = 0
end

function menu.update(dt)
    -- Aktualizacja spadających klocków
    menu.updateFallingBlocks(dt)

    -- Co 0.7 sekundy generujemy nowy klocek
    menu.spawnTimer = menu.spawnTimer + dt
    if menu.spawnTimer >= 0.7 then
        menu.spawnFallingBlock()
        menu.spawnTimer = 0
    end
end

function menu.draw()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.1)

    -- Rysowanie spadających klocków
    menu.drawFallingBlocks()

    -- Ustawienie czcionki i koloru dla tytułu
    love.graphics.setFont(menu.titleFont)

    -- Rysowanie cienia tytułu
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(menu.title, 2, 152, baseWidth, "center")

    -- Rysowanie głównego tytułu
    love.graphics.setColor(0, 0.8, 1)
    love.graphics.printf(menu.title, 0, 150, baseWidth, "center")

    -- Ustawienie czcionki dla opcji menu
    love.graphics.setFont(menu.optionFont)
    
    -- Rysowanie opcji menu jako przyciski
    for i, option in ipairs(menu.options) do
        local color = {1, 1, 1}
        if i == menu.selected then
            color = {0.5, 0.8, 1}
        end
        love.graphics.setColor(color)
        love.graphics.printf(option, 0, menu.optionYPositions[i], baseWidth, "center")
    end
end

function menu.spawnFallingBlock()
    local blockTypes = {"I", "J", "L", "O", "S", "T", "Z"}
    local colors = {
        I = {0, 1, 1},
        J = {0, 0, 1},
        L = {1, 0.5, 0},
        O = {1, 1, 0},
        S = {0, 1, 0},
        T = {0.5, 0, 0.5},
        Z = {1, 0, 0},
    }
    local blockType = blockTypes[math.random(#blockTypes)]
    local xPosition = math.random(0, baseWidth - blockSize * 2)
    local speed = math.random(60, 100) -- Większa prędkość spadania
    local color = colors[blockType]

    table.insert(menu.blocks, {
        type = blockType,
        x = xPosition,
        y = -blockSize * 2,
        speed = speed,
        color = color
    })
end

function menu.updateFallingBlocks(dt)
    for i = #menu.blocks, 1, -1 do
        local block = menu.blocks[i]
        block.y = block.y + block.speed * dt

        -- Usuń klocek, jeśli wyjdzie poza ekran
        if block.y > love.graphics.getHeight() then
            table.remove(menu.blocks, i)
        end
    end
end

function menu.drawFallingBlocks()
    for _, block in ipairs(menu.blocks) do
        love.graphics.setColor(block.color) -- Używamy przypisanego koloru klocka
        local shape = tetrominoes[block.type].shapes[1]
        for i = 1, #shape do
            for j = 1, #shape[i] do
                if shape[i][j] == 1 then
                    love.graphics.rectangle(
                        "fill",
                        block.x + (j - 1) * blockSize / 2,
                        block.y + (i - 1) * blockSize / 2,
                        blockSize / 2,
                        blockSize / 2
                    )
                end
            end
        end
    end
end

function menu.keypressed(key)
    if key == "up" then
        menu.selected = menu.selected - 1
        if menu.selected < 1 then menu.selected = #menu.options end
    elseif key == "down" then
        menu.selected = menu.selected + 1
        if menu.selected > #menu.options then menu.selected = 1 end
    elseif key == "return" then
        menu.activateOption(menu.selected)
    end
end

function menu.mousepressed(x, y, button, istouch)
    menu.checkButtonPress(x, y)
end

function menu.touchpressed(id, x, y, dx, dy, pressure)
    menu.checkButtonPress(x, y)
end

function menu.checkButtonPress(x, y)
    for i, optionY in ipairs(menu.optionYPositions) do
        if y >= optionY and y <= optionY + menu.optionHeight then
            menu.activateOption(i)
        end
    end
end

function menu.activateOption(selectedOption)
    if selectedOption == 1 then
        gameState = "game"
    elseif selectedOption == 2 then
        gameState = "options"
    elseif selectedOption == 3 then
        love.event.quit()
    end
end

return menu
