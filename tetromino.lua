
Tetromino = {}
Tetromino.__index = Tetromino

function Tetromino:new(key)
    local tet = {}
    setmetatable(tet, Tetromino)
    tet.key = key
    tet.shapes = tetrominoes[key].shapes
    tet.color = tetrominoes[key].color
    tet.rotation = 1
    tet.x = 4
    tet.y = 0
    tet.lockDelay = 0
    tet.lockDelayLimit = 0.1 -- Czas na wykonanie ruchów po dotknięciu podłoża
    return tet
end

function Tetromino:rotate(angle)
    local oldRotation = self.rotation              
    local rotationSteps = angle / 90
    self.rotation = (self.rotation - 1 + rotationSteps) % #self.shapes + 1
    if checkCollision(self) then
        if not wallKick(self, self.rotation, oldRotation) then
            self.rotation = oldRotation
        else
            lastActionWasSpin=true
        end
    else
        lastActionWasSpin = false
    end
end

function Tetromino:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
    if checkCollision(self) then
        self.x = self.x - dx
        self.y = self.y - dy
        return false
    else
        if dx ~= 0 then
            lastActionWasSpin = false
        end
        return true
    end
end
-- Definicja tetrominów zgodnie z SRS
tetrominoes = {
    I = {
        shapes = {
            {{0,0,0,0},{1,1,1,1},{0,0,0,0},{0,0,0,0}},
            {{0,0,1,0},{0,0,1,0},{0,0,1,0},{0,0,1,0}},
            {{0,0,0,0},{0,0,0,0},{1,1,1,1},{0,0,0,0}},
            {{0,1,0,0},{0,1,0,0},{0,1,0,0},{0,1,0,0}},
        },
        color = {0, 255, 255}
    },
    O = {
        shapes = {
            {{1,1},{1,1}},
            {{1,1},{1,1}},
            {{1,1},{1,1}},
            {{1,1},{1,1}},
        },
        color = {255, 255, 0}
    },
    T = {
        shapes = {
            {{0,1,0},{1,1,1},{0,0,0}},
            {{0,1,0},{0,1,1},{0,1,0}},
            {{0,0,0},{1,1,1},{0,1,0}},
            {{0,1,0},{1,1,0},{0,1,0}},
        },
        color = {128, 0, 128}
    },
    J = {
        shapes = {
            {{1,0,0},{1,1,1},{0,0,0}},
            {{0,1,1},{0,1,0},{0,1,0}},
            {{0,0,0},{1,1,1},{0,0,1}},
            {{0,1,0},{0,1,0},{1,1,0}},
        },
        color = {0, 0, 255}
    },
    L = {
        shapes = {
            {{0,0,1},{1,1,1},{0,0,0}},
            {{0,1,0},{0,1,0},{0,1,1}},
            {{0,0,0},{1,1,1},{1,0,0}},
            {{1,1,0},{0,1,0},{0,1,0}},
        },
        color = {255/255, 155/255, 0}
    },
    S = {
        shapes = {
            {{0,1,1},{1,1,0},{0,0,0}},
            {{0,1,0},{0,1,1},{0,0,1}},
            {{0,0,0},{0,1,1},{1,1,0}},
            {{1,0,0},{1,1,0},{0,1,0}},
        },
        color = {0, 255, 0}
    },
    Z = {
        shapes = {
            {{1,1,0},{0,1,1},{0,0,0}},
            {{0,0,1},{0,1,1},{0,1,0}},
            {{0,0,0},{1,1,0},{0,1,1}},
            {{0,1,0},{1,1,0},{1,0,0}},
        },
        color = {255, 0, 0}
    },
}
