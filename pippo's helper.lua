--- @type Scene
local currentScene = nil
local min, max = math.min, math.max


--#region === TEACHER ===

--- @class Pip.Teacher
_G.teacher = {}


--- @class Class
--- @field private __index table
--- @field super any
local class = {}
class.__index = class


function class:extend()
    local table = {}

    for key, value in pairs( self ) do
        if key:find( "__" ) == 1 then
            table[ key ] = value
        end
    end

    table.__index = table
    table.super = self

    setmetatable( table, self )

    return table
end


--- @protected
function class:init( ... ) end


--- @return boolean
function class:is( classType )
    local metatable = getmetatable( self )

    while metatable do

        if metatable == classType then
            return true
        end

        metatable = getmetatable( metatable )

    end

    return false
end


--- @private
function class:__call( ... )
    local object = setmetatable( {}, self )
    object:init( ... )
    return object
end


teacher.makeClass = function ()
    return class:extend()
end


--- @class List<T>: { [integer]: T }
--- @field private __index table
local list = {}
list.__index = list


--- @param value any
function list:append( value )
    table.insert( self, value )
end


--- @param valueToErase any
function list:erase( valueToErase )
    for index = 1, #self do
        local value = self[ index ]
        if value == valueToErase then table.remove( self, index ) end
    end
end


--- @param valueToErase any
function list:eraseSwapback( valueToErase )
    for index = 1, #self do
        local value = self[ index ]
        if value == valueToErase then
            self[ index ] = self[ #self ]
            table.remove( self, #self )
        end
    end
end


function list:clear()
    for index = #self, 1, -1 do
        table.remove( self, index )
    end
end


--- @return any
function list:pickRandom()
    return self[ love.math.random( #self ) ]
end


--- @return List
function list:duplicate()
    local newList = teacher.makeList()

    for _, item in ipairs( self ) do
        newList:append( item )
    end

    return newList
end


--- @param value any
--- @return boolean
function list:has( value )
    for _, v in ipairs( self ) do
        if value == v then return true end
    end

    return false
end


--- @return boolean
function list:isEmpty()
    return #self == 0
end


--- @return any
function list:popBack()
    return table.remove( self, #self )
end


--- @return any
function list:back()
    return self[#self]
end


--- @return any
function list:popFront()
    return table.remove( self, 1 )
end


--- @return any
function list:front()
    return self[ 1 ]
end


--- @private
function list:__tostring()
    local result = "[ "

    for key, value in ipairs( self ) do
        result = result..tostring( value )

        if key < #self then result = result..", " end
    end

    return result.." ]"
end


--- @param ... any
--- @return List
function teacher.makeList( ... )
    local object = {}
    setmetatable( object, list )

    for index = 1, select( "#", ... ) do
        table.insert( object, ( select( index, ... ) ) )
    end

    return object
end


-- Queue
--- @class Queue
--- @field private __index table
--- @field private first number
--- @field private last number
local baseQueue = {}
baseQueue.__index = baseQueue


--- @return Queue
function teacher.makeQueue()
    return setmetatable( { first = 0, last = -1 }, baseQueue )
end


--- @param thing any
function baseQueue:enqueue( thing )
    local last = self.last + 1
    self.last = last
    self[ last ] = thing
end


--- @return any
function baseQueue:next()
    local first = self.first
    local value = self[ first ]

    self[ first ] = nil
    self.first = first + 1

    return value
end


function baseQueue:clear()
    for index, _ in ipairs( self ) do
        self[ index ] = nil
    end

    self.first = 0 self.last = -1
end


--- @return boolean
function baseQueue:isEmpty()
    return self.first > self.last
end


do
    local next = next
    function table.isEmpty( table )
        return next( table ) == nil
    end
end


-- Sparse Set

--- @class SparseSet<T>
--- @field private __index table
--- @field private sparse table
--- @field private dense table
local basesparseSet = {}
basesparseSet.__index = basesparseSet


--- @param value any
function basesparseSet:append( value )
    local dense, sparse = self.dense, self.sparse

    if sparse[ value ] then return end

    table.insert( dense, value )
    sparse[ value ] = #dense
end


--- @param value any
function basesparseSet:erase( value )
    local sparse, dense = self.sparse, self.dense
    local index = sparse[ value ]

    if not( index ) then return end

    dense[ index ] = dense[ #dense ]
    sparse[ dense[ #dense ] ] = index

    table.remove( dense, #dense )
    sparse[ value ] = nil
end


function basesparseSet:iterate()
    local dense = self.dense
    local index, limit = 0, #dense

    return function ()
        index = index + 1
        if index <= limit then return dense[ index ] end
    end
end


--- @param value any
--- @return boolean
function basesparseSet:has( value )
    return self.sparse[ value ] ~= nil
end


--- @return integer
function basesparseSet:length()
    return #self.dense
end


--- @return string
--- @private
function basesparseSet:__tostring()
    local s = "["

    for _, item in ipairs( self.dense ) do
        s = s..tostring( item )..", "
    end

    s = s.."]"

    return s
end


--- @return SparseSet
function teacher.makeSparseSet()
    return setmetatable( { sparse = {}, dense = {} }, basesparseSet )
end

--#endregion


--#region === ARTIST ===

--- @class Pip.Artist
_G.artist = {}


-- Color

--- @class Color
--- @field private __index table
--- @field red integer
--- @field green integer
--- @field blue integer
--- @field alpha integer
local baseColor = {}
baseColor.__index = baseColor

function baseColor:setDrawColor()
    love.graphics.setColor( self:scaleToOne() )
end


--- @return number, number, number, number
function baseColor:scaleToOne()
    return self.red / 255, self.green / 255, self.blue / 255, self.alpha / 255
end


--- @param red integer
--- @param green integer
--- @param blue integer
--- @return Color
function artist.mixPaint( red, green, blue, alpha )
    local object = { red = red, green = green, blue = blue, alpha = alpha or 255 }
    setmetatable( object, baseColor )
    return object
end


-- Helpers

local function setLineWidth( newLineWidth )
    if not( newLineWidth ) then love.graphics.setLineWidth( 1 ) return end
    love.graphics.setLineWidth( newLineWidth )
end


local function setColor( color )
    if not( color ) then love.graphics.setColor( 1, 1, 1, 1 ) return end
    color:setDrawColor()
end


-- Draw functions

--- @param mode love.DrawMode
--- @param points table< number >
--- @param color Color?
--- @param lineWidth number?
function artist.paintPolygon( mode, points, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.polygon( mode, points )
end


--- @param mode love.DrawMode
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param color Color?
--- @param lineWidth number?
function artist.paintRectangle( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.rectangle( mode, x, y, width, height )
end


--- @param mode love.DrawMode
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param color Color?
--- @param lineWidth number?
function artist.paintRectangleRound( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )

    local rounding = min( width * 0.1, height * 0.1 )

    love.graphics.rectangle( mode, x, y, width, height, rounding, rounding )
end


--- @param mode love.DrawMode
--- @param x number
--- @param y number
--- @param radius number
--- @param color Color?
--- @param lineWidth number?
function artist.paintCircle( mode, x, y, radius, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )
    love.graphics.circle( mode, x, y, radius )
end


--- @param texture love.Texture
--- @param x number
--- @param y number
--- @param color Color?
function artist.paintTexture( texture, x, y, color )
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
function artist.rotate( rads, x, y )
    local translate = false
    if x and y then love.graphics.translate( x, y ) translate = true end
    love.graphics.rotate( rads )
    if translate then love.graphics.translate( -x, -y ) end
end


--- @param width number
--- @param height number
--- @param drawfunc function
--- @return love.Canvas
function artist.makeStaticCanvas( width, height, drawfunc )
    local canvas = love.graphics.newCanvas( width, height )
    canvas:renderTo( drawfunc )
    return canvas
end


--- @param texture love.Texture
--- @param limit number
--- @param emissionRate number
--- @param initEmissions number?
--- @return love.ParticleSystem
function artist.makeParticleSystem( texture, limit, emissionRate, initEmissions )
    local system = love.graphics.newParticleSystem( texture, limit )
    system:setEmissionRate( emissionRate )
    if initEmissions then system:emit( initEmissions ) end
    return system
end


--- @param text string
--- @param x number
--- @param y number
--- @param limit number
--- @param align love.AlignMode
--- @param color Color?
--- @param font love.Font?
function artist.write( text, x, y, limit, align, color, font )
    if not( color ) then
        love.graphics.setColor( 0, 0, 0 )
    else
        color:setDrawColor()
    end

    if not( font ) then font = love.graphics.getFont() end

    love.graphics.printf( text, font, x, y, limit, align )
end


--- @return love.Canvas
function artist.makeScreenCanvas()
    local canvas = love.graphics.newCanvas( stage.internalWidth, stage.internalHeight )
    canvas:setFilter( "nearest", "nearest" )
    return canvas
end


--- @param canvas love.Canvas
--- @param x integer?
--- @param y integer?
function artist.paintCanvas( canvas, x, y )
    setColor()
    love.graphics.draw( canvas, x or 0 , y or 0 )
end


--- @param drawSystem DrawSystem
function artist.paintDrawSystem( drawSystem )
    if not( currentScene ) then return end

    local drawCanvases = currentScene:getDrawCanvases()

    artist.paintCanvas( drawCanvases[ drawSystem ] )
end


--- @param mode love.DrawMode
--- @param x number
--- @param y number
--- @param outerRadius number
--- @param innerRadius number
--- @param color Color?
--- @param lineWidth number?
function artist.paintDonut( mode, x, y, outerRadius, innerRadius, color, lineWidth )
    love.graphics.push( "all" )

    setColor( color )
    setLineWidth( lineWidth )

    if mode == "fill" then
        love.graphics.stencil( function ()
            love.graphics.circle( "fill", x, y, innerRadius )
        end, "replace", 1 )

        love.graphics.setStencilTest( "less", 1 )
        love.graphics.circle( "fill", x, y, outerRadius )
    else
        love.graphics.circle( "line", x, y, outerRadius )
        love.graphics.circle( "line", x, y, innerRadius )
    end

    love.graphics.pop()
end


-- Spritesheet

--- @class SpriteSheet
--- @field private __index table
--- @field private quads List< love.Quad >
--- @field private image love.Image
--- @field private frameTime number
--- @field private time number
--- @field private currentQuadIndex integer
--- @field private frames integer
--- @field width integer
--- @field height integer
local baseSpritesheet = {}
baseSpritesheet.__index = baseSpritesheet


--- @private
function baseSpritesheet:makeQuads( rows, columns, frames )
    local image, floor = self.image, math.floor
    local imageWidth, imageHeight = image:getDimensions()
    local makeQuad = love.graphics.newQuad
    local quads = self.quads
    local frameWidth = floor( imageWidth / columns )
    local frameHeight = floor( imageHeight / rows )

    self.width, self.height = frameWidth, frameHeight

    local frame = 0
    for y = 0, rows - 1 do
        for x = 0, columns - 1 do
            local quad = makeQuad( x * frameWidth, y * frameHeight, frameWidth, frameHeight, imageWidth, imageHeight )
            quads:append( quad )

            frame = frame + 1
            if frame >= frames then return end
        end
    end
end


--- @param deltaTime number
function baseSpritesheet:update( deltaTime )
    self.time = self.time + deltaTime

    if self.time >= self.frameTime then
        self.time = 0
        self.currentQuadIndex = self.currentQuadIndex + 1
        if self.currentQuadIndex > self.frames then
            self.currentQuadIndex = 1
        end
    end
end


--- @param x integer
--- @param y integer
function baseSpritesheet:draw( x, y )
    local quad = self.quads[ self.currentQuadIndex ]
    setColor()
    love.graphics.draw( self.image, quad, x, y )
end


--- @param path string
--- @param rows integer
--- @param columns integer
--- @param frames integer
--- @param fps integer
--- @return SpriteSheet
function artist.makeSpritesheet( path, rows, columns, frames, fps )
    local image = love.graphics.newImage( path )
    local t = {
        image = image,
        frameTime = 1 / fps,
        frames = frames,
        currentQuadIndex = 1,
        quads = teacher.makeList(),
        time = 0
    }

    setmetatable( t, baseSpritesheet )

    t:makeQuads( rows, columns, frames )

    return t
end

--#endregion


--#region === WRITER ===

--- @class Pip.Writer
_G.writer = {}


-- Text input
local textThisFrame = ""
local backspace = false
local utf8 = require "utf8"


function writer.type( s )
    s = s..textThisFrame

    if not( backspace ) then return s end

    local offset = utf8.offset( s, -1 )

    if not( offset ) then return s end

    s = s:sub( 1, offset - 1 )
    return s
end


--#endregion


--#region === DJ ===

--- @class Pip.DJ
_G.dj = {}


--- @type table< string, love.Source >
local sounds = {}

--- @type table< string, love.Source >
local music = {}

--- @param path string
--- @return love.Source
function dj.getSample( path )
    local source = sounds[ path ]

    if not( source ) then
        source = love.audio.newSource( path, "static" )
        sounds[ path ] = source
        return source:clone()
    else
        return source:clone()
    end
end

--- @param path string
--- @return love.Source
function dj.getTrack( path )
    local track = music[ path ]

    if not( track ) then
        track = love.audio.newSource( path, "stream" )
        music[ path ] = track
        return track:clone()
    else
        return track:clone()
    end
end

--#endregion


--#region === ENGINEER ===

--- @class Pip.Engineer
_G.engineer = {}


--- @class Spring
--- @field private __index table
--- @field private stiffness number
--- @field private dampening number
--- @field private mass number
--- @field private velocity number
--- @field private target number
--- @field private value number
--- @field private initValue number
--- @field private setter fun( value : number )
local spring = {}
spring.__index = spring


--- @param deltaTime number
function spring:update( deltaTime )
    local velocity, target, value = self.velocity, self.target, self.value

    -- Early exit
    if value == target and velocity == 0 then return end

    local stiffness, dampening, mass = self.stiffness, self.dampening, self.mass
    local delta = value - target

    local springForce = -stiffness * delta
    local dampeningForce = -dampening * velocity
    local totalForce = springForce + dampeningForce
    local acceleration = totalForce / mass

    self.velocity = velocity + acceleration * deltaTime
    self.value = value + self.velocity * deltaTime

    if math.abs( self.value - self.target ) < 0.001 then self.value = self.target end

    if self.setter then self.setter( self.value ) end
end


--- @param to number?
function spring:reset( to )
    self.value = to or self.initValue
    self.velocity = 0
end


--- @param impulse number
function spring:applyImpulse( impulse )
    self.velocity = impulse
end


--- @param newTarget number
function spring:setTarget( newTarget )
    self.target = newTarget
end


--- @return number
function spring:getValue()
    return self.value
end


--- @param setter fun( value : number )
function spring:addSetter( setter )
    self.setter = setter
end


--- @param stiffness number
--- @param dampening number
--- @param mass number
--- @param initValue number
--- @return Spring
function engineer.makeSpring( stiffness, dampening, mass, initValue )
    local obj = {
        stiffness = stiffness,
        dampening = dampening,
        mass = mass,
        target = initValue or 0,
        velocity = 0,
        value = initValue or 0,
        initValue = initValue or 0,
    }

    setmetatable( obj, spring )

    return obj
end


--- @class StateMachine
--- @field private __index table
--- @field private currentState State
local stateMachine = {}
stateMachine.__index = stateMachine


--- @package
--- @return boolean
function stateMachine:earlyExit()
    if not( self.currentState ) then return true end
    if not( self.currentState.update ) then return true end
    return false
end


--- @param deltaTime number
function stateMachine:update( deltaTime )
    if self:earlyExit() then return end

    self.currentState.update( deltaTime )
end


function stateMachine:draw()
    if self:earlyExit() then return end

    self.currentState.draw()
end


--- @param newState State
function stateMachine:changeState( newState )
    if self.currentState and self.currentState.exit then
        self.currentState.exit()
    end

    if newState.enter then newState.enter() end

    self.currentState = newState
end


--- @return State
function stateMachine:getState()
    return self.currentState
end


--- @return StateMachine
function engineer.makeStateMachine()
    local obj = { currentState = nil }
    setmetatable( obj, stateMachine )
    return obj
end


-- State
--- @class State
--- @field enter fun()
--- @field exit fun()
--- @field update fun( deltaTime : number )
--- @field draw fun()


--- @return State
function engineer.makeState()
    return {}
end
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
--- @param minN number
--- @param maxN number
--- @return number
function math.clamp( n, minN, maxN )
    return min( maxN, max( minN, n ) )
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


do
    local bor, lshift = bit.bor, bit.lshift

    --- @param ... boolean
    --- @return integer
    function math.boolsToInt( ... )
        local int, size = 0, select( "#", ... )

        for index = 1, size do
            int = int + lshift( ( select( index, ... ) and 1 or 0 ), size - index )
        end

        return int
    end
end


math.random = love.math.random


math.twopi = math.pi * 2
math.halfpi = math.pi * 0.5

--#endregion


--#region === STAGE ===

--- @class Pip.Stage
_G.stage = {
    --- @type integer, integer
    internalWidth = 0, internalHeight = 0,
    --- @type number, number
    centerX = 0, centerY = 0,
    --- @type integer, integer
    windowWidth = 0, windowHeight = 0,
}


local forcePixelPerfectScaling = false
local scale, translateX, translateY = 0, 0, 0
--- @type love.Canvas
local mainCanvas = nil


local function updateMainCanvas()
    mainCanvas = love.graphics.newCanvas( stage.internalWidth, stage.internalHeight )
    mainCanvas:setFilter( "nearest", "nearest" )
end


--- @param width integer
--- @param height integer
local function setInternalDimensions( width, height )
    stage.internalWidth, stage.internalHeight = width, height
    stage.centerX, stage.centerY = width * 0.5, height * 0.5

    updateMainCanvas()
end


--- @param internalWidth integer
--- @param internalHeight integer
function stage.setInternalResolution( internalWidth, internalHeight )
    setInternalDimensions( internalWidth, internalHeight )
    love.window.setMode( internalWidth, internalHeight, { resizable = true } )
end


--- @param doPixelPerfectScaling boolean
function stage.setPixelPerfectScaling( doPixelPerfectScaling )
    forcePixelPerfectScaling = doPixelPerfectScaling
end


local function setMainCanvas()
    ---@diagnostic disable-next-line: missing-fields
    love.graphics.setCanvas{ mainCanvas, stencil = true }
    love.graphics.clear( love.graphics.getBackgroundColor() )
end


local function drawMainCanvas()
    love.graphics.setCanvas()
    love.graphics.origin()
    love.graphics.translate( translateX, translateY )
    love.graphics.scale( scale )
    love.graphics.setColor( 1, 1, 1, 1 )

    love.graphics.draw( mainCanvas )
end

--#endregion


--#region === CAPTAIN ===

--- @class Pip.Captain
_G.captain = {}


--- @enum MouseButton
captain.mouseButton = {
    left = 1,
    right = 2,
    middle = 3
}


local keysDown = teacher.makeList()
local keysJustPressed = teacher.makeList()
local mouseButtonsDown = teacher.makeList()
local mouseButtonsJustPressed = teacher.makeList()
local mouseScreenX, mouseScreenY = 0, 0


--- @param key love.KeyConstant
--- @return boolean
function captain.isKeyDown( key )
    return keysDown:has( key )
end


--- @param key love.KeyConstant
--- @return boolean
function captain.isKeyJustPressed( key )
    return keysJustPressed:has( key )
end


--- @param button MouseButton
--- @return boolean
function captain.isMouseButtonDown( button )
    return mouseButtonsDown:has( button )
end


--- @param button MouseButton
--- @return boolean
function captain.isMouseButtonJustPressed( button )
    return mouseButtonsJustPressed:has( button )
end


--- @return number, number
function captain.getMousePosition()
    return mouseScreenX, mouseScreenY
end


--#endregion


--#region === DARK ECS ===

--- @class Pip.Dark
_G.dark = {}


-- Filters

local function entityHasKey( entity, key )
    return entity[ key ] ~= nil
end


--- @enum FilterType
dark.filterType = {
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


--- @param entity table
---@param name string
---@param value any
function dark.setComponent( entity, name, value )
    entity[ name ] = value
    if not( currentScene ) then return end
    currentScene:updateEntity( entity )
end


--- @class Filter
--- @field private __index table
--- @field private type FilterType
--- @field private requiredComponents string[]
--- @field private subfilters List< Filter >
--- @field private entities SparseSet< table >
local baseFilter = {}
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


--- @param entity table
--- @package
function baseFilter:addEntity( entity )
    if not( self:filterEntity( entity ) ) then return end
    self.entities:append( entity )
end


--- @package
--- @param entity table
function baseFilter:eraseEntity( entity )
    self.entities:erase( entity )
end


--- @package
--- @return SparseSet< table >
function baseFilter:getEntities()
    return self.entities
end


--- @overload fun( type : FilterType, component : string, ... : string ) : Filter
--- @overload fun( subfilter : Filter, ... : Filter ) : Filter
function dark.makeFilter( ... )
    local newFilter = {}
    newFilter.type = nil
    newFilter.requiredComponents = {}
    newFilter.entities = teacher.makeSparseSet()
    newFilter.subfilters = teacher.makeList()

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
--- @field private __index table
--- @field private isPre boolean
local baseSystem = {}
baseSystem.__index = baseSystem


--- @package
--- @return boolean
function baseSystem:getIsPre()
    return self.isPre
end


--- @param isPre boolean
local function newSystem( isPre )
    local obj = {}

    obj.isPre = isPre
    obj.entities = teacher.makeList()

    setmetatable( obj, baseSystem )

    return obj
end


--- @class DrawSystem : System
--- @field private __index table
--- @field draw fun( entity : table )
local baseDrawSystem = {}
baseDrawSystem.__index = baseDrawSystem
setmetatable( baseDrawSystem, baseSystem )


--- @return DrawSystem
function dark.makeDrawSystem()
    local system = newSystem( false )
    system.draw = function() end

    setmetatable( system, baseDrawSystem )

    return system
end


--- @class UpdateSystem : System
--- @field private __index table
--- @field update fun( entity : table, deltaTime : number )
local baseUpdateSystem = {}
baseUpdateSystem.__index = baseUpdateSystem
setmetatable( baseUpdateSystem, baseSystem )


--- @param isPreUpdateSystem boolean? If true, will execute BEFORE the scene.update function. If false it will execute AFTER.
--- @return UpdateSystem
function dark.makeUpdateSystem( isPreUpdateSystem )
    local system = newSystem( isPreUpdateSystem or true )
    system.update = function() end

    setmetatable( system, baseUpdateSystem )

    return system
end

--#endregion


--#region === DIRECTOR ===

--- @class Pip.Director
_G.director = {}


--- @param newScene Scene
function director.changeScene( newScene )
    if currentScene then
        currentScene.exit()
    end

    currentScene = newScene

    newScene.enter()
end


--- @package
function director.update( deltaTime )
    if not( currentScene ) then return end

    local preUpdateSystems, postUpdateSystems = currentScene:getPreUpdateSystems(), currentScene:getPostUpdateSystems()

    for system, filter in pairs( preUpdateSystems ) do
        for entity in filter:getEntities():iterate() do
            system.update( entity, deltaTime )
        end
    end

    currentScene.update( deltaTime )

    for system, filter in pairs( postUpdateSystems ) do
        for entity in filter:getEntities():iterate() do
            system.update( entity, deltaTime )
        end
    end
end


local setCanvasSetup = { stencil = true }

--- @package
function director.draw()
    if not( currentScene ) then return end

    local drawSystems, drawCanvases = currentScene:getDrawSystems(), currentScene:getDrawCanvases()

    for system, filter in pairs( drawSystems ) do
        local canvas = drawCanvases[ system ]
        setCanvasSetup[ 1 ] = canvas
        love.graphics.setCanvas( setCanvasSetup )
        love.graphics.clear()

        for entity in filter:getEntities():iterate() do
            system.draw( entity )
        end
    end

    setMainCanvas()

    currentScene.draw()

    drawMainCanvas()
end


-- Scenes

--- @class Scene
--- @field private __index table
--- @field private filters List< Filter >
--- @field private drawSystems table< DrawSystem, Filter >
--- @field private drawCanvases table< DrawSystem, love.Canvas >
--- @field private preUpdateSystems table< UpdateSystem, Filter >
--- @field private postUpdateSystems table< UpdateSystem, Filter >
--- @field private entities SparseSet< table >
--- @field private inputGUIElements List<GUI.Element>
--- @field enter fun()
--- @field exit fun()
--- @field update fun( deltaTime : number )
--- @field draw fun()
local baseScene = {}
baseScene.__index = baseScene


--- @param entity table
function baseScene:addEntity( entity )
    self.entities:append( entity )

    for _, filter in ipairs( self.filters ) do
        filter:addEntity( entity )
    end
end


--- @param entity table
function baseScene:eraseEntity( entity )
    self.entities:erase( entity )

    for _, filter in ipairs( self.filters ) do
        filter:eraseEntity( entity )
    end
end


--- @package
--- @param entity table
function baseScene:updateEntity( entity )
    for _, filter in ipairs( self.filters ) do
        filter:eraseEntity( entity )
        filter:addEntity( entity )
    end
end


--- @package
--- @param filter Filter
function baseScene:addFilter( filter )
    if self.filters:has( filter ) then return end

    for entity in self.entities:iterate() do
        filter:addEntity( entity )
    end

    self.filters:append( filter )
end


--- @param system System
--- @param filter Filter
function baseScene:addSystem( system, filter )
    local metatable = getmetatable( system )

    self:addFilter( filter )

    if metatable == baseDrawSystem then
        self.drawSystems[ system ] = filter
        self.drawCanvases[ system ] = artist.makeScreenCanvas()
    elseif metatable == baseUpdateSystem then
        if system:getIsPre() then
            self.preUpdateSystems[ system ] = filter
        else
            self.postUpdateSystems[ system ] = filter
        end
    end
end


--- @package
--- @return List< table >
function baseScene:getEntities()
    return self.entities
end


--- @package
--- @return table< UpdateSystem, Filter >
function baseScene:getPreUpdateSystems()
    return self.preUpdateSystems
end


--- @package
--- @return table< DrawSystem, love.Canvas >
function baseScene:getDrawCanvases()
    return self.drawCanvases
end


--- @package
--- @return SparseSet< Filter >
function baseScene:getFilters()
    return self.filters
end


--- @package
--- @return table< DrawSystem, Filter >
function baseScene:getDrawSystems()
    return self.drawSystems
end


--- @package
--- @return table< UpdateSystem, Filter >
function baseScene:getPostUpdateSystems()
    return self.postUpdateSystems
end


--- @return Scene
function director.makeScene()
    local object = {}

    object.filters = teacher.makeList()
    object.drawSystems = {}
    object.drawCanvases = {}
    object.preUpdateSystems = {}
    object.postUpdateSystems = {}
    object.entities = teacher.makeSparseSet()
    object.inputGUIElements = teacher.makeList()

    object.enter = function () end
    object.exit = function () end
    object.update = function () end
    object.draw = function () end

    setmetatable( object, baseScene )

    return object
end


--#endregion


--#region === GOOEY GUI ===

--- @class Pip.Gooey
_G.gooey = {}


--- @alias GUI.Dimension "internalWidth" | "internalHeight"
--- @alias GUI.SizeMode "expand" | "fit" | number
--- @alias GUI.LayoutDirection "leftToRight" | "topToBottom"
--- @alias GUI.HorizontalAlign "left" | "center" | "right"
--- @alias GUI.VerticalAlign "top" | "center" | "bottom"
--- @alias GUI.Axis "x" | "y"
--- @alias GUI.Setup { width : GUI.SizeMode, height : GUI.SizeMode, minWidth : number, minHeight : number, maxWidth : number, maxHeight : number, x : number, y : number, layoutDirection : GUI.LayoutDirection, horizontalAlign : GUI.HorizontalAlign, verticalAlign : GUI.VerticalAlign, childSpacing : number, paddingAll : number, paddingTop : number, paddingBottom : number, paddingLeft : number, paddingRight : number, text : string, textHorizontalAlign : love.AlignMode, textVerticalAlign : GUI.VerticalAlign, font : love.Font, round : boolean, texture : love.Texture, mouseEntered : fun( element : GUI.Element ), mouseExited : fun( element : GUI.Element ), color : Color, backgroundColor : Color, shadowOffsetX : number, shadowOffsetY : number, shadowColor : Color, textShadowOffsetX : number, textShadowOffsetY : number, scale : number, rotation : number, mouseEntered : fun( element : GUI.Element ), mouseExited : fun( element : GUI.Element ), mouseButton : MouseButton, mousePressed : fun( element : GUI.Element ), mouseReleased : fun( element : GUI.Element ), inputActive : boolean, visible : boolean }

local elementStack = teacher.makeList()


--- @class GUI.Element
--- @field private __index table
---
--- In setup, user interfaces when making element
--- @field private width GUI.SizeMode
--- @field private height GUI.SizeMode
--- @field private minWidth number
--- @field private minHeight number
--- @field private maxWidth number
--- @field private maxHeight number
--- @field private layoutDirection GUI.LayoutDirection
--- @field package horizontalAlign GUI.HorizontalAlign
--- @field package verticalAlign GUI.VerticalAlign
--- @field private childSpacing number
--- @field private paddingAll number
--- @field private paddingTop number
--- @field private paddingLeft number
--- @field private paddingBottom number
--- @field private paddingRight number
--- @field package text string?
--- @field private textHorizontalAlign love.AlignMode
--- @field private textVerticalAlign GUI.VerticalAlign
--- @field private textShadowOffsetX number
--- @field private textShadowOffsetY number
--- @field private font love.Font
--- @field private round boolean
--- @field private texture love.Texture?
--- @field private shadowOffsetX number
--- @field private shadowOffsetY number
--- @field private shadowColor Color
--- @field private mouseButton MouseButton
--- @field x number
--- @field y number
--- @field rotation number
--- @field mouseEntered fun( element : GUI.Element )
--- @field mouseExited fun( element : GUI.Element )
--- @field mousePressed fun( element : GUI.Element )
--- @field mouseReleased fun( element : GUI.Element )
--- @field color Color
--- @field backgroundColor Color
--- @field scale number
--- @field visible boolean
--- @field inputActive boolean
---
--- For internal use
--- @field package parent GUI.Element?
--- @field package children List<GUI.Element>
--- @field private internalWidth number
--- @field private internalHeight number
--- @field private horizontalPadding number
--- @field private verticalPadding number
--- @field private userSetMinWidth boolean
--- @field private userSetMinHeight boolean
--- @field private drawShadow boolean
--- @field private drawTextShadow boolean
--- @field private mouseInElement boolean
--- @field private mouseDownOnElement boolean
--- @field package data table
---
local element = {}
element.__index = element


local defaults = {
    -- User Interface
    width = "fit", height = "fit",
    maxWidth = math.huge, maxHeight = math.huge,
    x = 0, y = 0,
    layoutDirection = "leftToRight",
    horizontalAlign = "left", verticalAlign = "top",
    childSpacing = 0, paddingAll = 0,
    horizontalPadding = 0, verticalPadding = 0,
    paddingLeft = 0, paddingRight = 0,
    paddingTop = 0, paddingBottom = 0,
    textHorizontalAlign = "left", textVerticalAlign = "top",
    textShadowOffsetX = 0, textShadowOffsetY = 0,
    font = love.graphics.newFont( 14 ),
    round = false,
    color = artist.mixPaint( 0, 0, 0 ), backgroundColor = artist.mixPaint( 0, 0, 0, 0 ),
    shadowOffsetX = 0, shadowOffsetY = 0,
    shadowColor = artist.mixPaint( 0, 0, 0, 128 ),
    scale = 1, rotation = 0,
    mouseButton = captain.mouseButton.left,
    visible = true,
    inputActive = false,

    -- Internal
    internalHeight = 0, internalWidth = 0,
    minWidth = 0, minHeight = 0,
    userSetMinWidth = false, userSetMinHeight = false,
    drawShadow = false, drawTextShadow = false,
    mouseInElement = false, mouseDownOnElement = false
}
defaults.__index = defaults
setmetatable( element, defaults )


--- @type table< string, fun( slime : GUI.Element, key : string, value : any ) >
local setters = {}


setters.x = function ( slime, key, value )
    slime.data[ key ] = value
    slime:setPosition( "x", "internalWidth", slime.horizontalAlign )
end


setters.y = function ( slime, key, value )
    slime.data[ key ] = value
    slime:setPosition( "y", "internalHeight", slime.verticalAlign )
end


local proxyMT = {
    __index = function ( self, key )
        if self.data[ key ] ~= nil then return self.data[ key ] end
        if defaults[ key ] ~= nil then return defaults[ key ] end

        return element[ key ]
    end,

    __newindex = function ( self, key, value )
        local setter = setters[ key ]
        if setter then setter( self, key, value ) return end
        self.data[ key ] = value
    end
}


--- @param slime GUI.Setup
--- @return GUI.Element
function gooey.makeSlime( slime )
    --- @cast slime GUI.Element
    slime.parent = nil
    slime.children = teacher.makeList()

    setmetatable( slime, element )

    slime:init()

    if not( elementStack:isEmpty() ) then
        local parent = elementStack:back()
        parent:addChild( slime )
    end

    elementStack:append( slime )

    local proxy = setmetatable( { data = slime }, proxyMT )

    return proxy
end


--- @package
function element:init()
    local width = self.width
    if type( width ) == "number" then self.internalWidth = width end

    local height = self.height
    if type( height ) == "number" then self.internalHeight = height end

    if not( self.minHeight == 0 ) then self.userSetMinHeight = true end
    if not( self.minWidth == 0 ) then self.userSetMinWidth = true end

    if not( self.paddingAll == 0 ) then
        local padding = self.paddingAll
        self.paddingLeft, self.paddingRight = padding, padding
        self.paddingTop, self.paddingBottom = padding, padding
    end

    self.horizontalPadding = self.paddingLeft + self.paddingRight
    self.verticalPadding = self.paddingTop + self.paddingBottom

    if not( self.shadowOffsetX == 0 ) or not( self.shadowOffsetY == 0 ) then
        self.drawShadow = true
    end

    if not( self.textShadowOffsetX == 0 ) or not( self.textShadowOffsetY == 0 ) then
        self.drawTextShadow = true
    end

    self:setupText()

    local texture = self.texture
    if texture then
        if not( self:isFixed( "internalWidth" ) ) and not( self.userSetMinWidth ) then
            self.minWidth = texture:getWidth() + self.horizontalPadding
        end

        if not( self:isFixed( "internalHeight" ) ) and not( self.userSetMinHeight ) then
            self.minHeight = texture:getHeight() + self.verticalPadding
        end
    end
end


-- Setup Functions

--- @package
function element:setupText()
    local text = self.text

    if not( text ) then return end

    local font = self.font

    if not( self:isFixed( "internalWidth" ) ) then self:setupTextWidth( text, font ) end
    if not( self:isFixed( "internalHeight" ) ) then self:setupTextHeight( font ) end
end


--- @private
--- @param text string
--- @param font love.Font
function element:setupTextWidth( text, font )
    local widest = 0

    for word in string.gmatch( text, "%S+" ) do
        widest = max( widest, font:getWidth( word ) )
    end

    self.minWidth = max( self.minWidth, widest )
    self.internalWidth = min( self.minWidth, self.maxWidth )
end


--- @private
--- @param font love.Font
function element:setupTextHeight( font )
    local padding = self.verticalPadding
    self.minHeight = max( self.minHeight, font:getHeight() + padding )
end


-- Child and Parents

--- @package
--- @param child  GUI.Element
function element:addChild( child )
    child.parent = self
    self.children:append( child )
end


function gooey.gatherSlimelets()
    assert( not( elementStack:isEmpty() ) )

    --- @type GUI.Element
    local next = elementStack:popBack()
    next:close()
end


--- @package
function element:close()
    local horizontalAlign = self.horizontalAlign
    local verticalAlign = self.verticalAlign

    self:fit( "internalWidth" )
    self:tryExpandAndShrink( "internalWidth" )

    self:tryFitToText()

    self:fit( "internalHeight" )
    self:tryExpandAndShrink( "internalHeight" )

    if self.parent then return end

    self:setPosition( "x", "internalWidth", horizontalAlign )
    self:setPosition( "y", "internalHeight", verticalAlign )
end


do

local queue = teacher.makeQueue()

--- @private
--- @param dimension GUI.Dimension
function element:tryExpandAndShrink( dimension )
    if self.parent then return end

    queue:clear()
    queue:enqueue( self )

    while not( queue:isEmpty() ) do
        --- @type GUI.Element
        local current = queue:next()

        for _, child in ipairs( current.children ) do
            queue:enqueue( child )
        end

        current:expandAndShrink( dimension )
    end
end
end


--- @private
--- @param dimension GUI.Dimension
--- @return boolean
function element:isFixed( dimension )
    dimension = string.lower( dimension:gsub( "internal", "" ) )
    return type( self[ dimension ] ) == "number"
end


--- @private
--- @param dimension GUI.Dimension
--- @return number
function element:getPaddingByDimension( dimension )
    if dimension == "internalWidth" then
        return self.horizontalPadding
    else
        return self.verticalPadding
    end
end


--- @private
--- @param dimension GUI.Dimension
--- @return boolean
function element:getAlongAxis( dimension )
    if dimension == "internalWidth" and self.layoutDirection == "leftToRight" then
        return true
    end

    if dimension == "internalHeight" and self.layoutDirection == "topToBottom" then
        return true
    end

    return false
end


--- @private
--- @param dimension GUI.Dimension
--- @return boolean
function element:isExpand( dimension )
    if dimension == "internalWidth" and self.width == "expand" then return true end
    if dimension == "internalHeight" and self.height == "expand" then return true end
    return false
end


--- @param dimension GUI.Dimension
--- @return "minWidth" | "minHeight"
local function makeDimensionMin( dimension )
    dimension = dimension:gsub( "internal", "" )
    return "min"..dimension
end


--- @param dimension GUI.Dimension
--- @return "maxWidth" | "maxHeight"
local function makeDimensionMax( dimension )
    dimension = dimension:gsub( "internal", "" )
    return "max"..dimension
end



--- @private
--- @param dimension GUI.Dimension
function element:fit( dimension )
    local padding = self:getPaddingByDimension( dimension )
    local minDimension, maxDimension = makeDimensionMin( dimension ), makeDimensionMax( dimension )
    self[ dimension ] = self[ dimension ] + padding

    if not( self:isExpand( dimension ) ) then self[ dimension ] = max( self[ dimension ], self[ minDimension ] ) end

    local childSpacing = ( #self.children  - 1 ) * self.childSpacing
    if self:getAlongAxis( dimension ) then self[ dimension ] = self[ dimension ] + childSpacing end

    local parent = self.parent

    if not( parent ) then
        if self:isFixed( dimension ) then return end

        for _, child in ipairs( self.children ) do
            self[ dimension ] = max( self[ dimension ], child[ dimension ] + padding )
        end

        return
    end

    if parent:isFixed( dimension ) then return end

    local alongAxis = parent:getAlongAxis( dimension )

    if alongAxis then
        parent[ dimension ] = min( parent[ dimension ] + self[ dimension ], parent[ maxDimension ] )
        parent[ minDimension ] = min( parent[ minDimension ] + self[ minDimension ], parent[ maxDimension ] )
    else
        parent[ dimension ] = min( max( parent[ dimension ], self[ dimension ] ), parent[ maxDimension ] )
        parent[ minDimension ] = min( max( parent[ minDimension ], self[ minDimension ] ), parent[ maxDimension ] )
    end
end


--- @private
--- @param dimension GUI.Dimension
--- @param remainingSpace number
--- @param children List<GUI.Element>
--- @param grow boolean
--- @return number, List<GUI.Element>
local function growOrShrink( dimension, remainingSpace, children, grow )
    local extremum = max
    local minDimension = makeDimensionMin( dimension )
    local maxDimension = makeDimensionMax( dimension )
    local extreme = children[1][ dimension ]
    local secondExtreme = 0
    local spaceToAdd = remainingSpace

    if grow then secondExtreme = math.huge end
    if grow then extremum = min end

    for _, child in ipairs( children ) do
        local size = child[ dimension ]

        if ( grow and size < extreme ) or ( not( grow ) and size > extreme ) then
            secondExtreme = extreme
            extreme = size
        end

        if ( grow and size > extreme ) or ( not( grow ) and size < extreme ) then
            secondExtreme = extremum( secondExtreme, size )
            spaceToAdd = secondExtreme - extreme
        end
    end

    spaceToAdd = extremum( spaceToAdd, remainingSpace / #children )

    for _, child in ipairs( children ) do
        if not( child[ dimension ] == extreme ) then goto skip end

        local previousSize = child[ dimension ]
        child[ dimension ] = child[ dimension ] + spaceToAdd

        if grow then
            remainingSpace = remainingSpace - spaceToAdd

            if child[ dimension ] >= child[ maxDimension ] then
                child[ dimension ] = child[ maxDimension ]
                children:erase( child )
            end
        else
            remainingSpace = remainingSpace - ( child[ dimension ] - previousSize )

            if child[ dimension ] <= child[ minDimension ] then
                child[ dimension ] = child[ minDimension ]
                children:erase( child )
            end
        end

        ::skip::
    end

    return remainingSpace, children
end


do -- Keep growable and shrinkable out of scope for the rest of the libray

-- These are here so that hundreds of new lists dont have to be created
--- @type List<GUI.Element>, List<GUI.Element>
local growable, shrinkable = teacher.makeList(), teacher.makeList()


--- @private
--- @param dimension GUI.Dimension
function element:expandAndShrink( dimension )
    local padding = self:getPaddingByDimension( dimension )
    local remainingSpace = self[ dimension ] - padding
    local maxSpace = remainingSpace
    local children = self.children
    local minDimension = makeDimensionMin( dimension )
    local alongAxis = self:getAlongAxis( dimension )

    if not( alongAxis ) then
        for _, child in ipairs( children ) do
            if child:isExpand( dimension ) or child[ dimension ] > maxSpace then
                child[ dimension ] = maxSpace
            end
        end

        return
    end

    growable:clear()
    shrinkable:clear()

    for _, child in ipairs( children ) do
        remainingSpace = remainingSpace - child[ dimension ]

        if child:isExpand( dimension ) then growable:append( child ) end
        if child[ dimension ] > child[ minDimension ] and not( child:isFixed( dimension ) ) then shrinkable:append( child ) end
    end

    remainingSpace = remainingSpace - ( #children - 1 ) * self.childSpacing

    while remainingSpace > 0 and not( growable:isEmpty() ) do
        remainingSpace = growOrShrink( dimension, remainingSpace, growable, true )

        if math.abs( remainingSpace ) < 0.0001 then
            return
        end
    end

    if shrinkable:isEmpty() then return end

    while remainingSpace < 0 do
        remainingSpace, shrinkable = growOrShrink( dimension, remainingSpace, shrinkable, false )
    end
end

end


do
    local queue = teacher.makeQueue()

    --- @package
    function element:tryFitToText()
        if self.parent then return end

        queue:clear()
        queue:enqueue( self )

        while not( queue:isEmpty() ) do
            local current = queue:next()

            current:fitToText()

            for _, child in ipairs( current.children ) do
                queue:enqueue( child )
            end
        end
    end
end


--- @package
function element:fitToText()
    if not( self.text ) then return end
    if self:isFixed( "internalHeight" ) then return end

    local font = self.font
    local _, lines = font:getWrap( self.text, self.internalWidth - self.horizontalPadding )
    local height = font:getHeight()

    self.minHeight = max( #lines * height + self.verticalPadding, self.minHeight )
    self.internalHeight = min( self.minHeight, self.maxHeight )

    local parent = self.parent

    if not( parent ) then return end
    if not( parent.height == "fit" ) then return end

    parent.internalHeight = parent.internalHeight + ( #lines - 1 ) * font:getHeight()
end


--- @private
--- @param axis GUI.Axis
--- @return number
function element:getTopLeftPadding( axis )
    if axis == "x" then
        return self.paddingLeft or self.paddingAll
    else
        return self.paddingTop or self.paddingAll
    end
end


--- @private
--- @param axis GUI.Axis
--- @return number
function element:getBottomRightPadding( axis )
    if axis == "x" then
        return self.paddingRight
    else
        return self.paddingBottom
    end
end


--- @param dimension GUI.Dimension
--- @return "horizontalAlign" | "verticalAlign"
local function getAlignFromDimension( dimension )
    if dimension == "internalWidth" then
        return "horizontalAlign"
    else
        return "verticalAlign"
    end
end


--- @param alignment GUI.HorizontalAlign | GUI.VerticalAlign
--- @return "none" | "center" | "push"
local function getJustify( alignment )
    if alignment == "left" or alignment == "top" then
        return "none"
    elseif alignment == "center" then
        return "center"
    else
        return "push"
    end
end


--- @package
--- @param axis GUI.Axis
--- @param dimension GUI.Dimension
--- @param alignment GUI.HorizontalAlign | GUI.VerticalAlign
function element:setPosition( axis, dimension, alignment )
    local children = self.children
    local padding = self:getTopLeftPadding( axis )
    local offset = 0
    local childSpacing = self.childSpacing
    local justify = getJustify( alignment )
    local justifyOffset = 0
    local alongAxis = self:getAlongAxis( dimension )

    if alongAxis and ( justify == "center" or justify == "push" ) then
        justifyOffset = self[ dimension ] - padding - self:getBottomRightPadding( axis )

        for _, child in ipairs( children ) do
            justifyOffset = justifyOffset - child[ dimension ]
        end

        justifyOffset = justifyOffset - ( #children - 1 ) * childSpacing

        if justify == "center" then justifyOffset = justifyOffset * 0.5 end
    end

    for _, child in ipairs( children ) do
        child[ axis ] = self[ axis ] + padding

        if alongAxis then
            child[ axis ] = child[ axis ] + offset + justifyOffset
            offset = offset + child[ dimension ]

        elseif justify == "center" or justify == "push" then
            local oppositePadding = self:getBottomRightPadding( axis )
            local remainingSpace = ( self[ dimension ] - padding - oppositePadding - child[ dimension ] )

            if justify == "center" then remainingSpace = remainingSpace * 0.5 end

            child[ axis ] = child[ axis ] + remainingSpace
        end

        offset = offset + childSpacing

        child:setPosition( axis, dimension, child[ getAlignFromDimension( dimension ) ] )
    end
end


-- Input


--- @package
--- @return GUI.Element
function element:findTopOfTree()
    if self.parent then return self.parent:findTopOfTree() end
    return self
end


function element:handleTreeInput( mouseX, mouseY )
    local top = self:findTopOfTree()
    top:handleInput( mouseX, mouseY )
end


--- @package
function element:handleInput( mouseX, mouseY )
    self:mouseMoved( mouseX, mouseY )
    self:tryPressed()
    self:tryReleased()

    for _, child in ipairs( self.children ) do
        child:handleInput( mouseX, mouseY )
    end
end


--- @package
--- @param x number
--- @param y number
function element:mouseMoved( x, y )
    if not( self.inputActive ) then return end

    local inX = x > self.x and x < self.x + self.internalWidth
    local inY = y > self.y and y < self.y + self.internalHeight

    if self.mouseInElement and ( not( inX ) or not( inY ) ) then
        if self.mouseExited then self:mouseExited() end
        self.mouseInElement = false
        self.mouseDownOnElement = false

    elseif not( self.mouseInElement ) and inX and inY then
        if self.mouseEntered then self:mouseEntered() end
        self.mouseInElement = true
    end
end


--- @package
function element:tryPressed()
    if not( self.inputActive ) then return end
    if not( captain.isMouseButtonJustPressed( self.mouseButton ) ) then return end
    if not( self.mouseInElement ) then return end
    if not( self.mousePressed ) then return end

    self.mouseDownOnElement = true
    self:mousePressed()
end


--- @package
function element:tryReleased()
    if not( self.inputActive ) then return end
    if not( self.mouseDownOnElement ) then return end
    if captain.isMouseButtonDown( self.mouseButton ) then return end
    if not( self.mouseInElement ) then return end
    if not( self.mouseReleased ) then return end

    self.mouseDownOnElement = false
    self:mouseReleased()
end


--- @package
--- @return GUI.Element?
function element:getParent()
    return self.parent
end


--- @package
--- @return List< GUI.Element >
function element:getChildren()
    return self.children
end


-- Draw

do
    local queue = teacher.makeQueue()

    function element:draw()
        if not( self.visible ) then return end

        queue:clear()
        queue:enqueue( self )

        while not( queue:isEmpty() ) do
            --- @type GUI.Element
            local current = queue:next()

            if current.visible then
                for _, child in ipairs( current.children ) do
                    queue:enqueue( child )
                end

                current:drawSelf()
            end
        end
    end
end


--- @package
function element:drawSelf()
    love.graphics.push()

    local round = self.round
    local x, y = self.x, self.y
    local width, height = self.internalWidth, self.internalHeight
    local texture = self.texture

    if not( self.scale == 1 ) then
        artist.scale( self.scale, x + width * 0.5, y + height * 0.5 )
    end

    if not( self.rotation == 0 ) then
        artist.rotate( self.rotation, x + width * 0.5, y + height * 0.5)
    end

    if self.drawShadow then
        if round then
            artist.paintRectangleRound( "fill", x + self.shadowOffsetX, y + self.shadowOffsetY, width, height, self.shadowColor )
        else
            artist.paintRectangle( "fill", x + self.shadowOffsetX, y + self.shadowOffsetY, width, height, self.shadowColor )
        end
    end

    if round then
        artist.paintRectangleRound( "fill", x, y, width, height, self.backgroundColor )
    else
        artist.paintRectangle( "fill", x, y, width, height, self.backgroundColor )
    end

    if texture then
        artist.paintTexture( texture, x + self.paddingLeft, y + self.paddingTop )
    end

    if self.text then
        local limit = self.internalWidth - self.horizontalPadding

        local verticalAlign = self.textVerticalAlign
        local font = self.font
        local verticalPush = self.paddingTop

        if verticalAlign == "center" or verticalAlign == "bottom" then
            local _, lines = font:getWrap( self.text, limit )
            local textHeight = #lines * font:getHeight()

            local remainingSpace = self.internalHeight - self.horizontalPadding - textHeight

            if verticalAlign == "center" then remainingSpace = remainingSpace * 0.5 end

            verticalPush = verticalPush + remainingSpace
        end

        if self.drawTextShadow then
            local textX = x + self.paddingLeft + self.textShadowOffsetX
            local textY = y + self.textShadowOffsetY + verticalPush

            artist.write( self.text, textX, textY, limit, self.textHorizontalAlign, self.shadowColor, font )
        end

        artist.write( self.text, x + self.paddingLeft, y + verticalPush, limit, self.textHorizontalAlign, self.color, font )
    end

    love.graphics.pop()
end

--#endregion


--#region === LOVE ===

--- @param directory string
function _G.loadDirectory( directory )
    --- @type string[]
    local files = love.filesystem.getDirectoryItems( directory )

    for _, file in ipairs( files ) do
        if not( file:find( ".lua" ) ) then
            loadDirectory( directory.."/"..file )
        else
            require( string.gsub( directory..".", "/", "." )..file:gsub( ".lua", "" ) )
        end
    end
end


local callbacks = {}


--- @param width integer
--- @param height integer
function callbacks.resize( width, height )
    stage.windowWidth, stage.windowHeight = width, height

    scale = min( width / stage.internalWidth, height / stage.internalHeight )

    if forcePixelPerfectScaling then
        scale = math.floor( scale )
    end

    translateX = ( width - stage.internalWidth * scale ) * 0.5
    translateY = ( height - stage.internalHeight * scale ) * 0.5

    local x, y = love.mouse.getPosition()

    mouseScreenX = math.clamp( math.floor( ( x - translateX ) / scale + 0.5 ), 0, stage.internalWidth )
    mouseScreenY = math.clamp( math.floor( ( y - translateY ) / scale + 0.5 ), 0, stage.internalHeight )
end


--- @param key love.KeyConstant
function callbacks.keypressed( key )
    keysDown:append( key )
    keysJustPressed:append( key )

    backspace = key == "backspace"
end


function callbacks.keyreleased( key )
    keysDown:erase( key )
end


function callbacks.mousepressed( _, _, button )
    mouseButtonsDown:append( button )
    mouseButtonsJustPressed:append( button )
end


function callbacks.mousereleased( _, _ ,button )
    mouseButtonsDown:erase( button )
end


function callbacks.mousemoved( x, y )
    mouseScreenX = math.floor( ( x - translateX ) / scale + 0.5 )
    mouseScreenY = math.floor( ( y - translateY ) / scale + 0.5 )
end


function callbacks.textinput( t )
    textThisFrame = t
end


local function resetKeysJustPressed()
    keysJustPressed:clear()
end


local function resetMouseButtonsPressed()
    mouseButtonsJustPressed:clear()
end


function love.run()
    if love.load then love.load() end

    love.timer.step()

    local deltaTime = 0

    return function ()
        love.event.pump()

        -- Events
        for name, a, b, c, d, e, f in love.event.poll() do
            local callback = callbacks[ name ]
            if callback then
                callback( a, b, c, d, e, f )
            elseif name == "quit" then
                ---@diagnostic disable-next-line: undefined-field
                if not love.quit or not love.quit() then
                    return a or 0
                end
            else
                ---@diagnostic disable-next-line: undefined-field
                love.handlers[ name ]( a,b,c,d,e,f )
            end
        end

        deltaTime = love.timer.step()

        director.update( deltaTime )

        resetKeysJustPressed()
        resetMouseButtonsPressed()

        love.graphics.origin()
        love.graphics.clear()

        director.draw()

        love.graphics.present()

        backspace = false
        textThisFrame = ""

        love.timer.sleep( 0.001 )
    end
end


-- Init
setInternalDimensions( 800, 600 )
callbacks.resize( 800, 600 )

--#endregion

