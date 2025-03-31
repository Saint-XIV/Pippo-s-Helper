--#region === COLOR ===

--- @class Color
--- @field red integer
--- @field green integer
--- @field blue integer
--- @field alpha integer
local baseColor = {}


--- @private
baseColor.__index = baseColor


--- @param red integer
--- @param green integer
--- @param blue integer
--- @return Color
local function newColor( red, green, blue, alpha )
    local object = { red = red, green = green, blue = blue, alpha = alpha or 255 }
    setmetatable( object, baseColor )
    return object
end


function baseColor:setDrawColor()
    love.graphics.setColor( self.red / 255, self.green / 255, self.blue / 255, self.alpha / 255 )
end


_G.newColor = newColor

--#endregion


--#region === ARRAY ===

--- @class Array<T>: { [integer]: T }
local array = {}


--- @private
array.__index = array


--- @param value any
function array:append( value )
    table.insert( self, value )
end


--- @param valueToErase any
function array:erase( valueToErase )
    for index = 1, #self do
        local value = self[ index ]
        if value == valueToErase then table.remove( self, index ) end
    end
end


--- @param valueToErase any
function array:eraseSwapback( valueToErase )
    for index = 1, #self do
        local value = self[ index ]
        if value == valueToErase then
            self[ index ] = self[ #self ]
            table.remove( self, #self )
        end
    end
end


function array:clear()
    for index = #self, 1, -1 do
        table.remove( self, index )
    end
end


--- @param value any
--- @return boolean
function array:has( value )
    for _, v in ipairs( self ) do
        if value == v then return true end
    end

    return false
end


--- @return boolean
function array:isEmpty()
    return #self == 0
end


--- @private
function array:__tostring()
    local result = "[ "

    for key, value in ipairs( self ) do
        result = result..tostring( value )

        if key < #self then result = result..", " end
    end

    return result.." ]"
end


--- @param ... any
--- @return Array
local function newArray( ... )
    local object = {}
    setmetatable( object, array )

    for index = 1, select( "#", ... ) do
        table.insert( object, ( select( index, ... ) ) )
    end

    return object
end


_G.newArray = newArray

--#endregion


--#region === MATH ===

--- @param totalTime number
--- @param stagesPerSecond integer
--- @param stages integer
--- @return integer
function math.step( totalTime, stagesPerSecond, stages )
    return math.floor( totalTime * stagesPerSecond ) % stages + 1
end


--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function math.distance( x1, y1, x2, y2 )
    local pow, sqrt = math.pow, math.sqrt
    return sqrt( pow( x2 - x1, 2 ) + pow( y2 - y1, 2 ) )
end


--- @param a number
--- @param b number
--- @return number
function math.pythagoras( a, b )
    return math.sqrt( a*a + b*b )
end


--- @param a number
--- @param b number
--- @param time number
--- @return number
function math.lerp( a, b, time )
    return ( 1 - time ) * a + time * b
end


--- @param value number
--- @param inMin number
--- @param inMax number
--- @param outMin number
--- @param outMax number
--- @return number
function math.mapToRange( value, inMin, inMax, outMin, outMax )
    local time = ( value - inMin ) / ( inMax - inMin )
    return math.lerp( outMin, outMax, time )
end


--- @param n number
--- @param min number
--- @param max number
--- @return number
function math.clamp( n, min, max )
    return math.min( max, math.max( min, n ) )
end


--- First is the "origin", second is where its pointing
--- @param x1 number
--- @param y1 number
--- @param x2 number
--- @param y2 number
--- @return number
function math.dirBetweenPoints( x1, y1, x2, y2 )
    return math.atan2( y2 - y1, x2 - x1 )
end


math.random = love.math.random


math.twopi = math.pi * 2
math.halfpi = math.pi * 0.5

--#endregion


--#region === Artist ===

_G.artist = {}


local function setLineWidth( newLineWidth )
    if not( newLineWidth ) then love.graphics.setLineWidth( 1 ) return end
    love.graphics.setLineWidth( newLineWidth )
end


local function setColor( color )
    if not( color ) then love.graphics.setColor( 1, 1, 1, 1 ) return end
    color:setDrawColor()
end


--- @param mode love.DrawMode
--- @param points table< number >
--- @param color Color?
--- @param lineWidth number?
function artist.drawPolygon( mode, points, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.polygon( mode, points )
end


--- @param mode love.DrawMode
--- @param centerX number
--- @param centerY number
--- @param width number
--- @param height number
--- @param color Color?
--- @param lineWidth number?
function artist.drawRectangleCentered( mode, centerX, centerY, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.rectangle( mode, centerX - width * 0.5, centerY - height * 0.5, width, height )
end


--- @param mode love.DrawMode
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param color Color?
--- @param lineWidth number?
function artist.drawRectangle( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.rectangle( mode, x, y, width, height )
end


--- @param mode love.DrawMode
---@param x number
---@param y number
---@param radius number
---@param color Color?
---@param lineWidth number?
function artist.drawCircle( mode, x, y, radius, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.circle( mode, x, y, radius )
end


--- @param texture love.Texture
--- @param x number
--- @param y number
--- @param color Color?
function artist.drawTexture( texture, x, y, color )
    setColor( color )
    love.graphics.draw( texture, x, y )
end


--- @param scale number
--- @param x number?
--- @param y number?
function artist.scale( scale, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.scale( scale, scale )
    if translate then love.graphics.translate( -x, -y ) end
end


--- @param rads number
--- @param x number?
--- @param y number?
function artist.drawRotate( rads, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.rotate( rads )
    if translate then love.graphics.translate( -x, -y ) end
end


--- @param width number
--- @param height number
--- @param drawfunc function
--- @return love.Canvas
function artist.newStaticCanvas( width, height, drawfunc )
    local canvas = love.graphics.newCanvas( width, height )
    canvas:renderTo( drawfunc )
    return canvas
end


--- @param texture love.Texture
--- @param limit number
--- @param emissionRate number
--- @param initEmissions number?
--- @return love.ParticleSystem
function artist.newParticleSystem( texture, limit, emissionRate, initEmissions )
    local system = love.graphics.newParticleSystem( texture, limit )
    system:setEmissionRate( emissionRate )
    if initEmissions then system:emit( initEmissions ) end
    return system
end

--#endregion


--#region === DISPLAY ===

_G.display = {
    --- @type integer, integer
    internalWidth = 0, internalHeight = 0,
    --- @type number, number
    centerX = 0, centerY = 0,
    --- @type integer, integer
    windowWidth = 0, windowHeight = 0,
}


local scale, translateX, translateY = 0, 0, 0
--- @type love.Canvas
local mainCanvas = nil


local function updateMainCanvas()
    mainCanvas = love.graphics.newCanvas( display.internalWidth, display.internalHeight )
end


--- @param width integer
--- @param height integer
local function setInternalDimensions( width, height )
    display.internalWidth, display.internalHeight = width, height
    display.centerX, display.centerY = width * 0.5, height * 0.5

    updateMainCanvas()
end


--- @param internalWidth integer
--- @param internalHeight integer
function display.setInternalResolution( internalWidth, internalHeight )
    setInternalDimensions( internalWidth, internalHeight )
    love.window.setMode( internalWidth, internalHeight, { resizable = true } )
end


--- @param width integer
--- @param height integer
function display.updateWindowDimensions( width, height )
    display.windowWidth, display.windowHeight = width, height

    scale = math.min( width / display.internalWidth, height / display.internalHeight )

    translateX = ( width - display.internalWidth * scale ) * 0.5
    translateY = ( height - display.internalHeight * scale ) * 0.5
end


local function setMainCanvas()
    ---@diagnostic disable-next-line: missing-fields
    love.graphics.setCanvas{ mainCanvas, stencil = true }
end


local function drawMainCanvas()
    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.translate( translateX, translateY )
    love.graphics.scale( scale )
    love.graphics.setColor( 1, 1, 1, 1 )

    love.graphics.draw( mainCanvas )

    love.graphics.setCanvas( mainCanvas )
    love.graphics.clear()
    love.graphics.setCanvas()
end

--#endregion


--#region === SCENE MANAGER ===

_G.sceneManager = {}


--- @type Scene
local currentScene = nil


--- @param newScene Scene
function sceneManager.changeScene( newScene )
    if currentScene then
        currentScene.exit()
    end

    currentScene = newScene

    newScene.enter()
end


function sceneManager.update( deltaTime )
    if not( currentScene ) then return end

    for _, system in ipairs( currentScene:getPreUpdateSystems() ) do
        for _, entity in ipairs( system:getEntities() ) do
            system.update( entity, deltaTime )
        end
    end

    currentScene.update( deltaTime )

    for _, system in ipairs( currentScene:getPostUpdateSystems() ) do
        for _, entity in ipairs( system:getEntities() ) do
            system.update( entity, deltaTime )
        end
    end

    currentScene:cleanup()
end


function sceneManager.draw()
    if not( currentScene ) then return end
    setMainCanvas()

    for _, system in ipairs( currentScene:getPreDrawSystems() ) do
        for _, entity in ipairs( system:getEntities() ) do
            system.draw( entity )
        end
    end

    currentScene.draw()

    for _, system in ipairs( currentScene:getPostDrawSystems() ) do
        for _, entity in ipairs( system:getEntities() ) do
            system.draw( entity )
        end
    end

    drawMainCanvas()
end


-- Scene

--- @class Scene
--- @field private preDrawSystems Array< DrawSystem >
--- @field private postDrawSystems Array< DrawSystem >
--- @field private preUpdateSystems Array< UpdateSystem >
--- @field private postUpdateSystems Array< UpdateSystem >
--- @field private allSystems Array< System >
--- @field private entities Array< table >
--- @field private entityTrash Array< table >
--- @field enter fun()
--- @field exit fun()
--- @field update fun( deltaTime : number )
--- @field draw fun()
local baseScene = {}


--- @private
baseScene.__index = baseScene


--- @package
--- @param system System
--- @param isPreDraw boolean
function baseScene:addDrawSystem( system, isPreDraw )
    if isPreDraw then
        self.preDrawSystems:append( system )
    else
        self.postDrawSystems:append( system )
    end

    self.allSystems:append( system )
end


--- @package
--- @param system System
--- @param isPreUpdate boolean
function baseScene:addUpdateSystem( system, isPreUpdate )
    if isPreUpdate then
        self.preUpdateSystems:append( system )
    else
        self.postUpdateSystems:append( system )
    end

    self.allSystems:append( system )
end


--- @param entity table
function baseScene:addEntity( entity )
    self.entities:append( entity )

    for _, system in ipairs( self.allSystems ) do
        system:addEntity( entity )
    end
end


--- @param entity table
--- Will be deleted at the end of the frame
function baseScene:deleteEntity( entity )
    self.entityTrash:append( entity )
end


--- @package
function baseScene:cleanup()
    if self.entityTrash:isEmpty() then return end

    for _, entity in ipairs( self.entityTrash ) do
        for _, system in ipairs( self.allSystems ) do
            system:deleteEntity( entity )
        end
    end

    self.entityTrash:clear()
end


--- @package
--- @return Array< UpdateSystem >
function baseScene:getPreUpdateSystems()
    return self.preUpdateSystems
end


--- @package
--- @return Array< UpdateSystem >
function baseScene:getPostUpdateSystems()
    return self.postUpdateSystems
end


--- @package
--- @return Array< DrawSystem >
function baseScene:getPreDrawSystems()
    return self.preDrawSystems
end


--- @package
--- @return Array< DrawSystem >
function baseScene:getPostDrawSystems()
    return self.postDrawSystems
end


--- @return Scene
function sceneManager.newScene()
    local object = {}

    object.preDrawSystems = newArray()
    object.postDrawSystems = newArray()
    object.preUpdateSystems = newArray()
    object.postUpdateSystems = newArray()
    object.allSystems = newArray()
    object.entities = newArray()
    object.entityTrash = newArray()

    object.enter = function () end
    object.exit = function () end
    object.update = function () end
    object.draw = function () end

    setmetatable( object, baseScene )
    return object
end


-- Init
setInternalDimensions( 800, 600 )
display.updateWindowDimensions( 800, 600 )


--#endregion


--#region === ECS ===

_G.ecs = {}


-- Filters

local function entityHasKey( entity, key )
    return entity[ key ] ~= nil
end


--- @enum FilterType
ecs.filterType = {
    requireAll = function ( entity, ... )
        for index = 1, select( "#", ... ) do
            if not( entityHasKey( entity, ( select( index, ... ) ) ) ) then
                return false
            end
        end

        return true
    end,

    requireAny = function ( entity, ... )
        for index = 1, select( "#", ... ) do
            if entityHasKey( entity, ( select( index, ... ) ) ) then
                return true
            end
        end

        return false
    end,

    rejectAll = function ( entity, ... )
        for index = 1, select( "#", ... ) do
            if not( entityHasKey( entity, ( select( index, ... ) ) ) ) then
                return true
            end
        end

        return false
    end,

    rejectAny = function ( entity, ... )
        for index = 1, select( "#", ... ) do
            if entityHasKey( entity, ( select( index, ... ) ) ) then
                return false
            end
        end

        return true
    end,
}



--- @class Filter
--- @field private type FilterType
--- @field private requiredComponents string[]
--- @field private subfilters Array< Filter >
local baseFilter = {}


--- @private
baseFilter.__index = baseFilter


--- @package
--- @param entity table
--- @return boolean
function baseFilter:filterEntity( entity )
    for _, subfilter in ipairs( self.subfilters ) do
        if not( subfilter:filterEntity( entity ) ) then return false end
    end

    if self.type then
        if not( self.type( entity, unpack( self.requiredComponents ) ) ) then return false end
    end

    return true
end


--- @overload fun( type : FilterType, component : string, ... : string ) : Filter
--- @overload fun( subfilter : Filter, ... : Filter ) : Filter
function ecs.newFilter( ... )
    local newFilter = {}
    newFilter.type = nil
    newFilter.requiredComponents = {}
    newFilter.subfilters = newArray()

    for index = 1, select ( "#", ... ) do
        local value = ( select( index, ... ) )
        local valueType = type( value  )

        if valueType == "string" then
            -- value is component
            table.insert( newFilter.requiredComponents, value )
        elseif valueType == "function" then
            -- value is type
            newFilter.type = value
        elseif valueType == "table" then
            -- value is subfilter
            newFilter.subfilters:append( value )
        end
    end

    setmetatable( newFilter, baseFilter )
    return newFilter
end


-- System

--- @class System
--- @field private filter Filter
--- @field private entities Array< table >
local baseSystem = {}


--- @private
baseSystem.__index = baseSystem


--- @package
--- @param entity table
function baseSystem:addEntity( entity )
    if not( self.filter:filterEntity( entity ) ) then return end
    self.entities:append( entity )
end


--- @package
--- @param entity table
function baseSystem:deleteEntity( entity )
    self.entities:eraseSwapback( entity )
end


--- @package
--- @return Array< table >
function baseSystem:getEntities()
    return self.entities
end


local function newSystem( filter )
    local obj = {}

    obj.filter = filter
    obj.entities = newArray()

    setmetatable( obj, baseSystem )

    return obj
end


--- @class DrawSystem : System
--- @field draw fun( entity : table )
local baseDrawSystem = {}
setmetatable( baseDrawSystem, baseSystem )


--- @private
baseDrawSystem.__index = baseDrawSystem


--- @param filter Filter
--- @param scene Scene
--- @param isPreDrawSystem boolean If true, will execute BEFORE the scene.draw function. If false it will execute AFTER.
--- @return DrawSystem
function ecs.newDrawSystem( filter, scene, isPreDrawSystem )
    local system = newSystem( filter )

    setmetatable( system, baseDrawSystem )

    scene:addDrawSystem( system, isPreDrawSystem )

    return system
end


--- @class UpdateSystem : System
--- @field update fun( entity : table, deltaTime : number )
local baseUpdateSystem = {}
setmetatable( baseUpdateSystem, baseSystem )


--- @private
baseUpdateSystem.__index = baseUpdateSystem


--- @param filter Filter
--- @param scene Scene
--- @param isPreUpdateSystem boolean If true, will execute BEFORE the scene.update function. If false it will execute AFTER.
--- @return UpdateSystem
function ecs.newUpdateSystem( filter, scene, isPreUpdateSystem )
    local system = newSystem( filter )
    system.update = function() end

    setmetatable( system, baseUpdateSystem )

    scene:addUpdateSystem( system, isPreUpdateSystem )

    return system
end

--#endregion
