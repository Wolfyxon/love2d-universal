local testImg = love.graphics.newImage("test.png")
local testImgW, testImgH = testImg:getDimensions()

function love.draw(screen)
    local width, height = love.graphics.getDimensions(screen)

    if not screen or screen == "top" then
        love.graphics.print('Hello World!', 0, 0)
    end
    
    if not screen or screen == "bottom" then
        love.graphics.draw(testImg, width / 2 - testImgW / 2, height / 2 - testImgH / 2)
    end
end

function love.gamepadpressed(joystick, button)
    love.event.quit()
end