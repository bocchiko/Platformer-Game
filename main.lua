push = require 'push'
Class = require 'class'
require 'Animation'
require 'Util'

Window_Height = 720
Window_Width = 1280

Virtual_Height = 144
Virtual_Width = 256

Tile_Size = 16
Tile_Set_Width = 5
Tile_Set_Height = 4
Tile_Set_Wide = 6
Tile_Set_Tall = 10
Topper_Set_Wide = 6
Topper_Set_Tall = 18

Character_Width = 16
Character_Height = 20

CameraSpeed = 40
Character_Speed = 40
Jump_Velocity = -200

Gravity = 7

Ground = 3
Sky = 5

function love.load()
    math.randomseed(os.time())
    
    tilesheet = love.graphics.newImage('tiles.png')
    quads = GenerateQuads(tilesheet, Tile_Size, Tile_Size)

    toppersheet = love.graphics.newImage('tile_tops.png')
    topperquads = GenerateQuads(toppersheet, Tile_Size, Tile_Size)

    tilesets = GenerateTileSets(quads, Tile_Set_Wide, Tile_Set_Tall, Tile_Set_Width, Tile_Set_Height)
    toppersets = GenerateTileSets(topperquads, Topper_Set_Wide, Topper_Set_Tall, Tile_Set_Width, Tile_Set_Height)

    tileset = math.random(#tilesets)
    topperset = math.random(#toppersets)

    characterSheet = love.graphics.newImage('character.png')
    characterQuads = GenerateQuads(characterSheet, Character_Width, Character_Height)


    idleAnimation = Animation {
        frames = { 1 },
        interval = 1
    }
    movingAnimation = Animation {
        frames = { 10, 11 },
        interval = 0.2
    }
    jumpAnimation = Animation {
        frames = { 3 },
        interval = 1
    }
    currentAnimation = idleAnimation

    characterX = Virtual_Width / 2 - (Character_Width / 2)
    characterY = ((7 - 1) * Tile_Size) - Character_Height
    characterDy = 0

    direction = 'right'

    mapWidth = 20
    mapHeight = 20

    cameraScroll = 0

    backgroundR = math.random(255) / 255
    backgroundG = math.random(255) / 255
    backgroundB = math.random(255) / 255

    tiles = generateLevel()

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Platformer')
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

    if key == 'space' and characterDy == 0 then
        characterDy = Jump_Velocity
        currentAnimation = jumpAnimation
    end

    if key == 'r' then
        tileset =  math.random(#tilesets)
        topperset =  math.random(#toppersets)
    end
end

function love.update(dt)
    characterDy = characterDy + Gravity
    characterY = characterY + characterDy * dt
    if characterY > ((7 - 1) * Tile_Size) - Character_Height then
        characterY = ((7 - 1) * Tile_Size) - Character_Height
        characterDy = 0
    end

    currentAnimation:update(dt)

    if love.keyboard.isDown('left') then
        characterX = characterX - Character_Speed * dt
        if characterDy == 0 then
            currentAnimation = movingAnimation
        end
        direction = 'left'
    elseif love.keyboard.isDown('right') then
        characterX = characterX + Character_Speed * dt
        if characterDy == 0 then
            currentAnimation = movingAnimation
        end
        direction = 'right'
    else
        currentAnimation = idleAnimation
    end

    cameraScroll = characterX - (Virtual_Width / 2) + (Character_Width / 2)
end

function love.draw()
    push:start()
    love.graphics.translate(-math.floor(cameraScroll), 0)
    love.graphics.clear(backgroundR, backgroundG, backgroundB, 1)

    for y = 1, mapHeight do
        for x = 1, mapWidth do
            local tile = tiles[y][x]
            love.graphics.draw(tilesheet, tilesets[tileset][tile.id], (x - 1) * Tile_Size, (y - 1) * Tile_Size)
        
            if tile.topper then
                love.graphics.draw(toppersheet, toppersets[topperset][tile.id],
                    (x - 1) * Tile_Size, (y - 1) * Tile_Size)
            end
        end
    end

    love.graphics.draw(characterSheet, characterQuads[currentAnimation:getCurrentFrame()],
        math.floor(characterX) + Character_Width / 2, math.floor(characterY) + Character_Height / 2,
        0, direction == 'left' and -1 or 1, 1,
        Character_Width / 2, Character_Height / 2)

    push:finish()
end

function generateLevel()
    local tiles = {}
    for y = 1, mapHeight do
        table.insert(tiles, {})
        for x = 1, mapWidth do
            table.insert(tiles[y], {
                id = y < 7 and Sky or Ground,
                topper = y == 7 and true or false
            })
        end
    end
    return tiles
end