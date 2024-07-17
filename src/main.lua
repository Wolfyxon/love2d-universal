local testImg = love.graphics.newImage("test.png")
local testImgW, testImgH = testImg:getDimensions()

function love.draw(screen)
    local width, height = love.graphics.getDimensions(screen)

    love.graphics.print('Hello World!', 0, 0)
    love.graphics.draw(testImg, width / 2 - testImgW / 2, height / 2 - testImgH / 2)
end

function love.gamepadpressed(joystick, button)
    love.event.quit()
end