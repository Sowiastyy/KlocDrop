-- Moduł siatki gry

blockSize = 32 -- Nowy rozmiar bloku, aby dopasować siatkę do rozdzielczości

    function initGrid()
        grid = {}
        for y = 1, 22 do -- Dodatkowe dwie linie jako bufor
            grid[y] = {}
            for x = 1, 10 do
                grid[y][x] = 0
            end
        end
    end
    
    function checkCollision(tetromino)
        local shape = tetromino.shapes[tetromino.rotation]
        for i = 1, #shape do
            for j = 1, #shape[i] do
                if shape[i][j] == 1 then
                    local gridX = tetromino.x + j -1
                    local gridY = tetromino.y + i
                    if gridX < 1 or gridX > 10 or gridY > 22 or (gridY > 0 and grid[gridY][gridX] ~= 0) then
                        return true
                    end
                end
            end
        end
        return false
    end
    
    function lockTetromino(tetromino)
        local shape = tetromino.shapes[tetromino.rotation]
        for i = 1, #shape do
            for j = 1, #shape[i] do
                if shape[i][j] == 1 then
                    local gridX = tetromino.x + j -1
                    local gridY = tetromino.y + i
                    if gridY > 0 then
                        grid[gridY][gridX] = tetromino.color
                    end
                end
            end
        end
    end
    
    function clearLines()
        local linesCleared = 0
        local row = 22
        while row >= 1 do
            local full = true
            for col = 1, 10 do
                if grid[row][col] == 0 then
                    full = false
                    break
                end
            end
            if full then
                table.remove(grid, row)
                table.insert(grid, 1, {})
                for col = 1, 10 do
                    grid[1][col] = 0
                end
                linesCleared = linesCleared + 1
                -- Nie zmieniaj wartości 'row', aby ponownie sprawdzić ten sam indeks
            else
                row = row - 1
            end
        end
        return linesCleared
    end
    
    function isPerfectClear()
        for i = 1, 22 do
            for j = 1, 10 do
                if grid[i][j] ~= 0 then
                    return false
                end
            end
        end
        return true
    end
    function drawGrid()
        -- Rysowanie czarnego tła dla całej siatki z przezroczystością 0.4
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", 0, 0, 10 * blockSize, 20 * blockSize)
    
        -- Rysowanie powiększonej białej ramki wokół całego gridu
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(3) -- Ustawienie grubości linii na 3 dla wyraźnej obramówki
        love.graphics.rectangle("line", 0, 0, 10 * blockSize, 20 * blockSize)

        -- Rysowanie siatki i klocków
        for i = 3, 22 do -- Ukryj górne dwie linie
            for j = 1, 10 do
                local x, y = (j - 1) * blockSize, (i - 3) * blockSize
                -- Rysowanie szarej wewnętrznej siatki z przezroczystością 0.6
                love.graphics.setColor(0.5, 0.5, 0.5, 0.6)
                love.graphics.setLineWidth(1) -- Ustawienie cienkiej linii dla siatki
                love.graphics.rectangle("line", x, y, blockSize, blockSize)
                if grid[i][j] ~= 0 then
                    -- Rysowanie wypełnienia klocka
                    love.graphics.setColor(grid[i][j])
                    love.graphics.rectangle("fill", x, y, blockSize, blockSize)
    
                    -- Rysowanie białoszarego obramowania na górze i po prawej stronie
                    love.graphics.setColor(0.9, 0.9, 0.9) -- Jasny, białoszary kolor
                    love.graphics.rectangle("fill", x, y, blockSize, 2) -- Górna linia
                    love.graphics.rectangle("fill", x + blockSize - 2, y, 2, blockSize) -- Prawa linia
    
                    -- Rysowanie szaroczarnego obramowania na dole i po lewej stronie
                    love.graphics.setColor(0.1, 0.1, 0.1) -- Ciemny, szaroczarny kolor
                    love.graphics.rectangle("fill", x, y + blockSize - 2, blockSize, 2) -- Dolna linia
                    love.graphics.rectangle("fill", x, y, 2, blockSize) -- Lewa linia
                end
            end
        end
    
        -- Przywrócenie domyślnej grubości linii po zakończeniu rysowania
        love.graphics.setLineWidth(1)
    end
    