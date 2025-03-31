# Pippo's Helper
Scene manager, ECS, and other stuff for Love2D

## Example - Minimum Setup
```lua
function love.load()
    require "pippo's helper"
end


function love.update( dt )
    sceneManager.update( dt )
end


function love.draw()
    sceneManager.draw()
end


function love.resize( width, height )
    display.updateWindowDimensions( width, height )
end
```
## Example - Moving a Red Rectangle with Shadow Left and Right
```lua
-- Make some colors
local red = newColor( 255, 0, 0 )
local blue = newColor( 0, 0, 255 )
local black = newColor( 0, 0, 0 )

-- Make a new scene
local scene = sceneManager.newScene()

-- Draw a blue background
scene.draw = function ()
    artist.drawRectangle( "fill", 0, 0, display.internalWidth, display.internalHeight, blue )
end

-- Make a filter for an ECS system
local filter = ecs.newFilter( ecs.filterType.requireAll, "x", "y", "width", "height", "color" )

-- Add a draw system for the shadow, note that systems are executed in first-in-first-executed order
local shadowSystem = ecs.newDrawSystem( filter, scene, false )
shadowSystem.draw = function ( entity )
    artist.drawRectangle( "fill", entity.x + 5, entity.y + 5, entity.width, entity.height, black )
end

-- Add a draw system for the rectangle
local drawSystem = ecs.newDrawSystem( filter, scene, false )
drawSystem.draw = function ( entity )
    artist.drawRectangle( "fill", entity.x, entity.y, entity.width, entity.height, entity.color )
end

-- Add a system to move the rectangle left and right
local controlSystem = ecs.newUpdateSystem( filter, scene, true )
controlSystem.update = function ( entity, deltaTime )
    if love.keyboard.isDown( "left" ) then
        entity.x = entity.x - 200 * deltaTime
    elseif love.keyboard.isDown( "right" ) then
        entity.x = entity.x + 200 * deltaTime
    end
end

-- Make a player "entity"
local player ={ x = 30, y = 65, width = 300, height = 200, color = red }

-- Add the player to the scene
scene:addEntity( player )

-- Change the scene to our example scene
sceneManager.changeScene( scene )
```
