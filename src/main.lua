function love.draw(screen)
    love.graphics.print('Hello World!', 0, 0)
end

function love.gamepadpressed(joystick, button)
    love.event.quit()
end