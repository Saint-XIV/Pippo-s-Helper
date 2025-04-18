require "pippo's helper plus"


function love.load()
    display.setInternalResolution( 900, 900 )

    local red = artist.mixPaint( 255, 0, 0 )
    local green = artist.mixPaint( 0, 255, 0 )
    local blue = artist.mixPaint( 0, 0, 255 )
    local white = artist.mixPaint( 255, 255, 255 )
    local purple = artist.mixPaint( 255, 0, 255 )
    local gray = artist.mixPaint( 150, 150, 150 )

    --- @param color Color
    --- @return Color
    local function flipColor( color )
        return artist.mixPaint( 255 - color.red, 255 - color.green, 255 - color.blue )
    end

    --- @param element GUI.Element
    local function flipElementColor( element )
        element.backgroundColor = flipColor( element.backgroundColor )
        element.color = flipColor( element.color )
    end

    local scene = sceneManager.newScene()

    local updateSystem = ecs.newUpdateSystem( ecs.newFilter( ecs.filterType.requireAll, "update" ), true )
    updateSystem.update = function ( entity, deltaTime )
        entity:update( deltaTime )
    end
    scene:addSystem( updateSystem )
    local spring = engineer.newSpring( 10, 0.1, 0.01, 1 )
    scene:addEntity( spring )

    local base = gui.newSlime{
    backgroundColor = red,
    width = 500, height = 500,
    paddingAll = 10, childSpacing = 10,
    x = 10, y = 10,
    }

        gui.newSlime{
            childSpacing = 10, paddingAll = 10,
            layoutDirection = "topToBottom",
            height = "expand",
            backgroundColor = blue,
        }

            for i = 1, 3 do
                local color = gray
                if i % 2 == 0 then color = white end

                gui.newSlime{
                    backgroundColor = color,
                    width = 200, height = "expand",
                    text = "we getting gui in here",
                    textHorizontalAlign = "center",
                    textVerticalAlign = "center",
                    paddingAll = 10,
                    shadowOffsetX = 5, shadowOffsetY = 5,
                    textShadowOffsetX = 1, textShadowOffsetY = 1,
                    mousePressed = flipElementColor,
                    inputActive = true
                } gui.gatherSlimelets()
            end

        gui.gatherSlimelets()

        gui.newSlime{
            backgroundColor = green,
            width = "expand", height = "expand",
            horizontalAlign = "center",
            layoutDirection = "topToBottom",
            paddingAll = 10, childSpacing = 20
        }

            local purpleBox = gui.newSlime{
                backgroundColor = purple,
                width = 200, height = 100,
                text = "hi down there",
                textHorizontalAlign = "center",
                textVerticalAlign = "bottom",
                paddingAll = 10,
                mouseEntered = function ( element ) spring:setTarget( 1.05 ) end,
                mouseExited = function ( element ) spring:setTarget( 1 ) end,
                inputActive = true
            } gui.gatherSlimelets()
            spring:addSetter( function ( value ) purpleBox.scale = value end )

            gui.newSlime{
                height = "expand"
            } gui.gatherSlimelets()

            gui.newSlime{
                backgroundColor = purple,
                width = 100, height = 25,
                text = "click here!",
                textHorizontalAlign = "center",
                textVerticalAlign = "center",
                paddingAll = 10,
                mousePressed = function ( element ) element.visible = not( element.visible ) end,
                inputActive = true,
            } gui.gatherSlimelets()

        gui.gatherSlimelets()

    gui.gatherSlimelets()

    local guiCanvas = artist.makeScreenCanvas()
    scene:addGUITree( base, guiCanvas )

    scene.draw = function ()
        artist.paintCanvas( guiCanvas )
    end

    sceneManager.changeScene( scene )
end
