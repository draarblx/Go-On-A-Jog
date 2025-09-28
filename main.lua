local MainCharacter = {
    Position = { x = 0, y = 0 },
    spriteSheet = nil,
    quads = {
        left = {},
        right = {}
    },
    currentFrame = 1,
    frameTimer = 0,
    frameDuration = 0.2, 
    direction = "right",
    speed = 200,
    maxSpeed = 200,
    minSpeed = 50,
    slowAmount = 1,
    regenAmount = 15,
    regenDelay = 1.5,
    idleTime = 0
}

local MainBackground = {
    Position = { x = 0, y = 0 },
    bgImage = nil,
    scale = 1,
    width = 0
}

local distanceTravelled = 0
local fullscreenMode = { isFullscreen = false }
local font

local function FullScreen(arg)
    if arg and not fullscreenMode.isFullscreen then
        fullscreenMode.isFullscreen = true
        love.window.setFullscreen(true, "desktop")
    elseif arg == false and fullscreenMode.isFullscreen then
        love.window.setFullscreen(false, "desktop")
        fullscreenMode.isFullscreen = false
    end
end

function love.load()
    love.window.setMode(1280, 720, {resizable=false})

    font = love.graphics.newFont(28)
    love.graphics.setFont(font)

    MainCharacter.spriteSheet = love.graphics.newImage("spritearray.png")
    MainBackground.bgImage = love.graphics.newImage("background.png")

    local windowWidth, windowHeight = love.graphics.getDimensions()
    local bgWidth, bgHeight = MainBackground.bgImage:getDimensions()
    MainBackground.scale = windowHeight / bgHeight
    MainBackground.width = bgWidth * MainBackground.scale

    local sheetWidth, sheetHeight = MainCharacter.spriteSheet:getDimensions()
    frameWidth = sheetWidth / 4
    frameHeight = sheetHeight / 4

    for i = 0, 3 do
        MainCharacter.quads.right[i+1] = love.graphics.newQuad(
            i * frameWidth, 1 * frameHeight + 10,
            frameWidth, frameHeight + 8,
            sheetWidth, sheetHeight
        )
    end

    for i = 0, 3 do
        MainCharacter.quads.left[i+1] = love.graphics.newQuad(
            i * frameWidth, 2 * frameHeight + 10,
            frameWidth, frameHeight + 8,
            sheetWidth, sheetHeight
        )
    end

    MainCharacter.Position.x = windowWidth / 2
    MainCharacter.Position.y = windowHeight - (frameHeight - 50)
end

function love.update(dt)
    local moving = false
    local step = MainCharacter.speed * dt

    if love.keyboard.isDown("a") then
        MainBackground.Position.x = MainBackground.Position.x - step
        MainCharacter.direction = "left"
        moving = true
        distanceTravelled = distanceTravelled + step
    end

    if love.keyboard.isDown("d") then
        MainBackground.Position.x = MainBackground.Position.x + step
        MainCharacter.direction = "right"
        moving = true
        distanceTravelled = distanceTravelled + step
    end

    MainBackground.Position.x = MainBackground.Position.x % MainBackground.width

    if moving then
        MainCharacter.frameTimer = MainCharacter.frameTimer + dt

        local speedScale = MainCharacter.speed / MainCharacter.maxSpeed
        local scaledFrameDuration = MainCharacter.frameDuration / math.max(speedScale, 0.2)

        if MainCharacter.frameTimer >= scaledFrameDuration then
            MainCharacter.frameTimer = MainCharacter.frameTimer - scaledFrameDuration
            MainCharacter.currentFrame = MainCharacter.currentFrame % 4 + 1

            MainCharacter.speed = math.max(MainCharacter.speed - MainCharacter.slowAmount, MainCharacter.minSpeed)
        end

        MainCharacter.idleTime = 0
    else
        MainCharacter.currentFrame = 1
        MainCharacter.idleTime = MainCharacter.idleTime + dt

        if MainCharacter.idleTime >= MainCharacter.regenDelay then
            MainCharacter.speed = math.min(MainCharacter.speed + MainCharacter.regenAmount * dt, MainCharacter.maxSpeed)
        end
    end
end

function love.draw()
    local winWidth = love.graphics.getWidth()
    local startX = - (MainBackground.Position.x % MainBackground.width)

    for i = -1, math.ceil(winWidth / MainBackground.width) + 1 do
        love.graphics.draw(
            MainBackground.bgImage,
            startX + i * MainBackground.width, MainBackground.Position.y,
            0,
            MainBackground.scale, MainBackground.scale
        )
    end

    local quad = MainCharacter.quads[MainCharacter.direction][MainCharacter.currentFrame]
    love.graphics.draw(
        MainCharacter.spriteSheet,
        quad,
        MainCharacter.Position.x, MainCharacter.Position.y,
        0,
        1.5, 1.5,
        frameWidth/2, frameHeight
    )

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Speed: " .. math.floor(MainCharacter.speed), 10, love.graphics.getHeight() - 70)

    local km = distanceTravelled / (MainBackground.width / 2)
    local distanceText = string.format("Distance: %.2f km", km)
    local textWidth = font:getWidth(distanceText)
    love.graphics.print(distanceText, love.graphics.getWidth() - textWidth - 10, love.graphics.getHeight() - 70)

    local barWidth = 160
    local barHeight = 20
    local barX = 10
    local barY = love.graphics.getHeight() - 100

    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)

    local speedPercent = (MainCharacter.speed - MainCharacter.minSpeed) / (MainCharacter.maxSpeed - MainCharacter.minSpeed)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth * speedPercent, barHeight)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
end

