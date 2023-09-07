push = require 'push'

require 'Util'

Window_Height = 720
Window_Width = 1280

Virtual_Height = 144
Virtual_Width = 256

Tile_Size = 16

Character_Width = 16
Character_Height = 20

CameraSpeed = 40

Ground = 1
Sky = 2

function love.load()
    math.randomseed(os.time())
    tiles = {}
    tilesheet = love.graphics.newImage('tiles.png')
    quads = GenerateQuads(tilesheet, Tile_Size, Tile_Size)

    characterSheet = love.graphics.newImage('character.png')
    characterQuads = GenerateQuads(characterSheet, Character_Width, Character_Height)
    characterX = Virtual_Width / 2 - (Character_Width / 2)
    CharacterY = ((7 - 1) * Tile_Size) - Character_Height

    mapWidth = 20
    mapHeight = 20

    cameraScroll = 0

    backgroundR = math.random(255) / 255
    backgroundG = math.random(255) / 255
    backgroundB = math.random(255) / 255

    for y = 1, mapHeight do
        table.insert(tiles, {})
        for x = 1, mapWidth do
            table.insert(tiles[y], {
                id = y < 7 and Sky or Ground
            })
        end
    end

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('tiles0')
    push:setupScreen(Virtual_Width, Virtual_Height, Window_Width, Window_Height, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

function love.update(dt)
    if love.keyboard.isDown('left') then
        cameraScroll = cameraScroll - CameraSpeed * dt
    elseif love.keyboard.isDown('right') then
        cameraScroll = cameraScroll + CameraSpeed * dt
    end
end

function love.draw()
    push:start()
    love.graphics.translate(-math.floor(cameraScroll), 0)
    love.graphics.clear(backgroundR, backgroundG, backgroundB, 1)

    for y = 1, mapHeight do
        for x = 1, mapWidth do
            local tile = tiles[y][x]
            love.graphics.draw(tilesheet, quads[tile.id], (x - 1) * Tile_Size, (y - 1) * Tile_Size)
        end
    end
    love.graphics.draw(characterSheet, characterQuads[1], characterX, CharacterY)
    push:finish()
end
