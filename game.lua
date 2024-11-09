-- Moduł logiki gry

-- Parametry Tetris Handling
ARR = 0.1  -- Auto Repeat Rate (czas między kolejnymi przesunięciami)
DAS = 0.15 -- Delayed Auto Shift (opóźnienie przed rozpoczęciem powtarzania)
DCD = 0.0  -- Delayed Auto Shift Cancel (czas, po którym przerywane jest powtarzanie)
SDF = 0.05 -- Soft Drop Factor (szybkość opadania przy soft dropie)

blockSize = 32

function initGame()
    bag = {}
    currentTetromino = nil
    holdTetromino = nil
    canHold = true
    timer = 0
    score = 0
    linesClearedTotal = 0
    level = 1
    fallSpeed = 0.5
    combo = -1
    backToBack = false
    lastClearType = nil
    message = ""
    messageTimer = 0
    gameTime = 0
    lastActionWasSpin = false
    spawnTetromino()
end

function spawnTetromino()
    if #bag <= 7 then -- Jeśli w worku jest 7 lub mniej elementów
        refillBag()
    end
    currentTetrominoKey = table.remove(bag, 1) -- Pobierz pierwszy element
    currentTetromino = Tetromino:new(currentTetrominoKey)
    timer = 0 -- Resetuj timer po wygenerowaniu nowego tetromina
    if checkCollision(currentTetromino) then
        -- Koniec gry
        initGrid()
        initGame()
    end
end


function refillBag()
    local keys = {}
    for key in pairs(tetrominoes) do
        table.insert(keys, key)
    end
    -- Mieszanie kluczy
    while #keys > 0 do
        local index = math.random(#keys)
        table.insert(bag, keys[index])
        table.remove(keys, index)
    end
end

function updateGame(dt)
    timer = timer + dt
    gameTime = gameTime + dt

    -- Obsługa opadania tetromina
    if softDropping then
        softDropTimer = softDropTimer + dt
        if softDropTimer >= SDF then
            if not currentTetromino:move(0, 1) then
                -- Kolizja z podłożem
                currentTetromino.lockDelay = currentTetromino.lockDelay + dt
                if currentTetromino.lockDelay >= currentTetromino.lockDelayLimit then
                    lockTetromino(currentTetromino)
                    local lines = clearLines()
                    processScore(lines)
                    spawnTetromino()
                    canHold = true
                end
            else
                currentTetromino.lockDelay = 0
            end
            softDropTimer = 0
        end
    else
        if timer >= fallSpeed then
            if not currentTetromino:move(0, 1) then
                -- Kolizja z podłożem
                currentTetromino.lockDelay = currentTetromino.lockDelay + dt
                if currentTetromino.lockDelay >= currentTetromino.lockDelayLimit then
                    lockTetromino(currentTetromino)
                    local lines = clearLines()
                    processScore(lines)
                    spawnTetromino()
                    canHold = true
                end
            else
                currentTetromino.lockDelay = 0
            end
            timer = 0
        end
    end

    updateAutoShift(dt)
    updateMessage(dt)
end

function handleInput(key, isPressed)
    if isPressed then
        if key == "left" or key == "a" then
            moveLeft = true
            moveRight = false
            autoShiftTimer = 0
            autoShiftDirection = -1
            currentTetromino:move(-1, 0)
        elseif key == "right" or key == "d" then
            moveRight = true
            moveLeft = false
            autoShiftTimer = 0
            autoShiftDirection = 1
            currentTetromino:move(1, 0)
        elseif key == "down" or key == "s" then
            softDropping = true
            softDropTimer = 0
        elseif key == "z" then
            currentTetromino:rotate(90)
        elseif key == "x" then
            currentTetromino:rotate(180)
        elseif key == "c" then
            currentTetromino:rotate(270)
        elseif key == "space" then
            -- Hard drop
            while currentTetromino:move(0, 1) do
                score = score + 2
            end
            lockTetromino(currentTetromino)
            local lines = clearLines()
            processScore(lines)
            spawnTetromino()
            canHold = true
        elseif key == "lshift" or key == "rshift" then
            holdCurrentTetromino()
        end
    else
        if key == "left" or key == "a" then
            moveLeft = false
            autoShiftTimer = 0
        elseif key == "right" or key == "d" then
            moveRight = false
            autoShiftTimer = 0
        elseif key == "down" or key == "s" then
            softDropping = false
        end
    end
end

function updateAutoShift(dt)
    if moveLeft or moveRight then
        autoShiftTimer = autoShiftTimer + dt
        if autoShiftTimer >= DAS then
            repeat
                if currentTetromino:move(autoShiftDirection, 0) then
                    -- Sukces
                end
                autoShiftRepeatTimer = (autoShiftRepeatTimer or 0) + dt
            until autoShiftRepeatTimer < ARR
            autoShiftRepeatTimer = 0
        end
    end
end

function holdCurrentTetromino()
    if canHold then
        if holdTetromino then
            local temp = holdTetromino
            holdTetromino = currentTetrominoKey
            currentTetrominoKey = temp
            currentTetromino = Tetromino:new(currentTetrominoKey)
        else
            holdTetromino = currentTetrominoKey
            spawnTetromino()
        end
        canHold = false
    end
end

function drawCurrentTetromino()
    local shape = currentTetromino.shapes[currentTetromino.rotation]
    local xOffset = currentTetromino.x - 2
    local yOffset = currentTetromino.y - 3

    for i = 1, #shape do
        for j = 1, #shape[i] do
            if shape[i][j] == 1 then
                local x = (xOffset + j) * blockSize
                local y = (yOffset + i) * blockSize

                -- Rysowanie wypełnienia klocka
                love.graphics.setColor(currentTetromino.color)
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
end


function drawGhostPiece()
    local ghostTetromino = {
        x = currentTetromino.x,
        y = currentTetromino.y,
        rotation = currentTetromino.rotation,
        shapes = currentTetromino.shapes,
    }
    while not checkCollision(ghostTetromino) do
        ghostTetromino.y = ghostTetromino.y + 1
    end
    ghostTetromino.y = ghostTetromino.y

    local shape = ghostTetromino.shapes[ghostTetromino.rotation]
    love.graphics.setColor(1, 1, 1, 0.3) -- Półprzezroczysty biały kolor
    for i = 1, #shape do
        for j = 1, #shape[i] do
            if shape[i][j] == 1 then
                love.graphics.rectangle("fill", (ghostTetromino.x + j -2)*blockSize, (ghostTetromino.y + i -4)*blockSize, blockSize, blockSize)
            end
        end
    end
end

function wallKick(tetromino, newRotation, oldRotation)
    local kicks = getWallKicks(tetromino.key, (oldRotation - 1) % 4, (newRotation - 1) % 4)
    for i = 1, #kicks do
        tetromino.x = tetromino.x + kicks[i][1]
        tetromino.y = tetromino.y + kicks[i][2]
        if not checkCollision(tetromino) then
            return true
        end
        tetromino.x = tetromino.x - kicks[i][1]
        tetromino.y = tetromino.y - kicks[i][2]
    end
    return false
end

function getWallKicks(piece, oldRot, newRot)
    -- Definiowanie tablic przesunięć zgodnie z SRS
    local kicks = {
        I = {
            [0] = {
                [1] = {{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
                [3] = {{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
            },
            [1] = {
                [0] = {{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
                [2] = {{0,0},{-1,0},{2,0},{-1,2},{2,-1}},
            },
            [2] = {
                [1] = {{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
                [3] = {{0,0},{2,0},{-1,0},{2,1},{-1,-2}},
            },
            [3] = {
                [2] = {{0,0},{-2,0},{1,0},{-2,-1},{1,2}},
                [0] = {{0,0},{1,0},{-2,0},{1,-2},{-2,1}},
            },
        },
        other = {
            [0] = {
                [1] = {{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
                [3] = {{0,0},{1,0},{1,1},{0,-2},{1,-2}},
            },
            [1] = {
                [0] = {{0,0},{1,0},{1,-1},{0,2},{1,2}},
                [2] = {{0,0},{1,0},{1,-1},{0,2},{1,2}},
            },
            [2] = {
                [1] = {{0,0},{1,0},{1,1},{0,-2},{1,-2}},
                [3] = {{0,0},{-1,0},{-1,1},{0,-2},{-1,-2}},
            },
            [3] = {
                [2] = {{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
                [0] = {{0,0},{-1,0},{-1,-1},{0,2},{-1,2}},
            },
        }
    }

    oldRot = oldRot % 4
    newRot = newRot % 4

    local pieceKicks = kicks[piece] or kicks["other"]
    local rotKicks = pieceKicks[oldRot] and pieceKicks[oldRot][newRot]
    return rotKicks or {{0,0}}
end

-- Funkcje związane z punktacją i wyświetlaniem komunikatów

function processScore(linesCleared)
    local lineScore = 0
    local isSpin = false
    local clearType = nil

    -- Sprawdzenie, czy to był T-Spin
    if lastActionWasSpin and currentTetromino.key == "T" then
        if linesCleared == 1 then
            lineScore = 800 * level
            clearType = "T-Spin Single"
        elseif linesCleared == 2 then
            lineScore = 1200 * level
            clearType = "T-Spin Double"
        elseif linesCleared == 3 then
            lineScore = 1600 * level
            clearType = "T-Spin Triple"
        else
            lineScore = 400 * level
            clearType = "T-Spin"
        end
        isSpin = true
    else
        if linesCleared == 1 then
            lineScore = 100 * level
            clearType = "Single"
        elseif linesCleared == 2 then
            lineScore = 300 * level
            clearType = "Double"
        elseif linesCleared == 3 then
            lineScore = 500 * level
            clearType = "Triple"
        elseif linesCleared == 4 then
            lineScore = 800 * level
            clearType = "Tetris"
        end
    end

    -- Perfect Clear
    if linesCleared > 0 and isPerfectClear() then
        lineScore = lineScore + 3500 * level
        clearType = "Perfect Clear"
    end

    -- Combo
    if linesCleared > 0 then
        combo = combo + 1
        if combo > 0 then
            lineScore = lineScore + combo * 50 * level
        end
    else
        combo = -1
    end

    -- Back-to-Back
    if clearType == "Tetris" or isSpin then
        if backToBack then
            lineScore = lineScore * 1.5
            clearType = "Back-to-Back " .. clearType
        end
        backToBack = true
    else
        backToBack = false
    end

    -- Aktualizacja punktów i linii
    score = score + lineScore
    linesClearedTotal = linesClearedTotal + linesCleared

    -- Aktualizacja poziomu i prędkości
    if linesClearedTotal >= level * 10 then
        level = level + 1
        fallSpeed = fallSpeed * 0.9 -- Przyspieszanie opadania
    end

    -- Wyświetlanie komunikatu
    if clearType then
        message = clearType
        messageTimer = 2 -- Wyświetl komunikat przez 2 sekundy
    end
end

function updateMessage(dt)
    if messageTimer > 0 then
        messageTimer = messageTimer - dt
        if messageTimer <= 0 then
            message = ""
        end
    end
end

function drawUI()
    local smallFont = love.graphics.newFont("assets/conform-f-s.ttf", 20)
    love.graphics.setFont(smallFont)

    -- Wyświetl "HOLD" w lewym górnym rogu oraz klocka w trybie hold poniżej
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("HOLD", 10, 10)

    -- Wyświetlanie Score, Lines i Time poniżej siatki
    local screenHeight = love.graphics.getHeight()
    local gridHeight = 22 * blockSize
    local uiYPosition = gridHeight - 160

    love.graphics.print("Score\n " .. math.floor(score), 10, uiYPosition)
    love.graphics.print("Lines\n " .. linesClearedTotal, 10, uiYPosition - 160)
    love.graphics.print("Time\n" .. math.floor(gameTime), 10, uiYPosition - 80)
    -- Wyświetlanie napisu "NEXT" i następnych tetrominów
    love.graphics.setFont(smallFont)
    love.graphics.print("NEXT", baseWidth - 120, 10)
    -- Wyświetlanie komunikatów na środku ekranu (jeśli istnieje)
    if message ~= "" then
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf(message, 0, 200, baseWidth, "center")
        love.graphics.setColor(1, 1, 1)
    end

    if holdTetromino then
        drawHoldTetromino(1.4) -- Rysuj klocka w trybie hold, powiększony 1.2 razy
    end

    drawNextTetrominoes(1.4) -- Rysowanie kolejnych tetrominów, powiększonych 1.2 razy
end


function drawNextTetrominoes(scale)
    scale = scale or 1
    local startX = baseWidth - 120
    local startY = 50 + 30 -- Przesunięcie tetrominów nieco niżej
    local spacing = 120 -- Odstęp między tetrominami, dostosowany do powiększenia

    for i = 1, 3 do
        local nextTetrominoKey = bag[i]
        if nextTetrominoKey then
            local shape = tetrominoes[nextTetrominoKey].shapes[1]
            love.graphics.setColor(tetrominoes[nextTetrominoKey].color)
            for row = 1, #shape do
                for col = 1, #shape[row] do
                    if shape[row][col] == 1 then
                        love.graphics.rectangle(
                            "fill",
                            startX + (col - 1) * blockSize / 2 * scale,
                            startY + (row - 1) * blockSize / 2 * scale + (i - 1) * spacing,
                            blockSize / 2 * scale,
                            blockSize / 2 * scale
                        )
                    end
                end
            end
        end
    end
end



function drawHoldTetromino(scale)
    scale = scale or 1
    local holdShape = tetrominoes[holdTetromino].shapes[1]
    local startX = 50
    local startY = 90

    love.graphics.setColor(tetrominoes[holdTetromino].color)
    for i = 1, #holdShape do
        for j = 1, #holdShape[i] do
            if holdShape[i][j] == 1 then
                love.graphics.rectangle(
                    "fill",
                    startX + (j - 1) * blockSize / 2 * scale,
                    startY + (i - 1) * blockSize / 2 * scale,
                    blockSize / 2 * scale,
                    blockSize / 2 * scale
                )
            end
        end
    end
end
