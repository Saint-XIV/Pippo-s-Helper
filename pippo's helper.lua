--#region === TEACHER ===

_G.teacher = {}


--- @class Class
--- @field super any
local class = {}


--- @private
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
local list = {}


--- @private
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

--#endregion


--#region === SPRING ===


--- @class Spring
--- @field private stiffness number
--- @field private dampening number
--- @field private mass number
--- @field private velocity number
--- @field private target number
--- @field private value number
--- @field private initValue number
local spring = {}


--- @private
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


--- @param stiffness number
--- @param dampening number
--- @param mass number
--- @param initValue number
--- @return Spring
function _G.newSpring( stiffness, dampening, mass, initValue )
    local obj = {
        stiffness = stiffness,
        dampening = dampening,
        mass = mass,
        target = initValue or 0,
        velocity = 0,
        value = initValue or 0,
        initValue = initValue or 0
    }

    setmetatable( obj, spring )

    return obj
end

--#endregion


--#region === STATE MACHINE ===

-- State Machine
--- @class StateMachine
--- @field private currentState State
local stateMachine = {}


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


function _G.newStateMachine()
    local obj = { currentState = nil }
    setmetatable( obj, stateMachine )
    return obj
end


--- @private
stateMachine.__index = stateMachine


-- State
--- @class State
--- @field enter fun()
--- @field exit fun()
--- @field update fun( deltaTime : number )
--- @field draw fun()


--- @return State
function _G.newState()
    return {}
end


--#endregion


--#region === COMMAND ===

-- Command Result


--- @class Command
--- @field perform fun( ... ) : CommandResult


--- @enum CommandResult
_G.commandResult = {
    SUCCESS = 0,
    FAILURE = 1
}



--- @return Command
function  _G.newCommand()
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


--#region === ARTIST ===

_G.artist = {}


local function setLineWidth( newLineWidth )
    if not( newLineWidth ) then love.graphics.setLineWidth( 1 ) return end
    love.graphics.setLineWidth( newLineWidth )
end


local function setColor( color )
    if not( color ) then love.graphics.setColor( 1, 1, 1, 1 ) return end
    color:setDrawColor()
end


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
function artist.mixPaint( red, green, blue, alpha )
    local object = { red = red, green = green, blue = blue, alpha = alpha or 255 }
    setmetatable( object, baseColor )
    return object
end


function baseColor:setDrawColor()
    love.graphics.setColor( self.red / 255, self.green / 255, self.blue / 255, self.alpha / 255 )
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
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param color Color?
--- @param lineWidth number?
function artist.drawRectangleRound( mode, x, y, width, height, color, lineWidth )
    setColor( color )
    setLineWidth( lineWidth )

    local rounding = math.min( width * 0.1, height * 0.1 )

    love.graphics.rectangle( mode, x, y, width, height, rounding, rounding )
end


--- @param mode love.DrawMode
--- @param x number
--- @param y number
--- @param radius number
--- @param color Color?
--- @param lineWidth number?
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

--#endregion


--#region === WRITER ===

_G.writer = {}


--- @class Font
--- @field private path string?
--- @field private sizeStep number?
--- @field private sizes table<number, love.Font>
--- @field private hinting love.HintingMode
local customFont = {}


--- @private
customFont.__index = customFont


--- @package
function customFont:initSizes()
    local sizeStep = self.sizeStep
    local path = self.path
    for size = sizeStep, sizeStep * 8, sizeStep do
        self:makeFont( size, path )
    end
end


--- @package
--- @param path string?
--- @param size number
function customFont:makeFont( size, path )
    local font

    if path then
        font = love.graphics.newFont( path, size, self.hinting )
    else
        font = love.graphics.newFont( size, self.hinting )
    end

    self.sizes[ size ] = font
end


--- @param size number
--- @return love.Font
function customFont:getFont( size )
    local font = self.sizes[ size ]
    if font then return font end

    self:makeFont( size, self.path )
    return self.sizes[ size ]
end


--- @param path string?
--- @param sizeStep number
--- @param hintingMode love.HintingMode?
--- @return Font
function writer.makeFont( sizeStep, path, hintingMode )
    local obj = { path = path, sizes = {}, sizeStep = sizeStep, hintingMode = hintingMode }
    if not( hintingMode ) then obj.hintingMode = "normal" end
    setmetatable( obj, customFont )
    obj:initSizes()
    return obj
end


local defualtFont = writer.makeFont( 12 )


--#endregion


--#region === GUI ===


_G.gui = {}


local elementStack = teacher.makeList()


--- @enum GUI.Sizing
gui.sizing = {
    expand = "expand",
    shrink = "shrink"
}


--- @enum GUI.LayoutDirection
gui.layoutDirection = {
    leftToRight = "leftToRight",
    topToBottom = "topToBottom"
}


--- @class GUI.Element
--- @field private parent GUI.Element?
--- @field private children List<GUI.Element>
--- @field private sizing { width : GUI.Sizing|number, height : GUI.Sizing|number }
--- @field private width number
--- @field private height number
--- @field private minWidth number
--- @field private minHeight number
--- @field private backgroundColor Color
--- @field private x number
--- @field private y number
--- @field private padding { left : number, right : number, top : number, bottom : number }
--- @field private layoutDirection GUI.LayoutDirection
--- @field private childSpacing number
--- @field private color Color
--- @field private textAlign love.AlignMode
--- @field private font Font
--- @field private textSize number
--- @field private rounded boolean
--- @field private texture love.Texture
local base = {}


--- @param setup {
--- backgroundColor : Color,
--- sizing : { width : GUI.Sizing|number, height : GUI.Sizing | number },
--- position : { x : number, y : number },
--- padding : { left : number, right : number, top : number, bottom : number },
--- layoutDirection : GUI.LayoutDirection,
--- childSpacing : number,
--- color : Color,
--- text : string,
--- textAlign : love.AlignMode,
--- font : Font,
--- textSize : number,
--- rounded : boolean,
--- texture : love.Texture,
--- file : string,
--- }
--- @return GUI.Element
---
function gui.newSlime( setup )
    local obj = setmetatable( {}, base )
    obj:init( setup )

    if not( elementStack:isEmpty() ) then
        local parent = elementStack:back()
        parent:addChild( obj )
    end

    elementStack:append( obj )
    return obj
end


--- @package
function base:init( setup )
    self.parent = nil
    self.children = teacher.makeList()

    self:setupBackgroundColor( setup.backgroundColor )
    self:setupPosition( setup.position )
    self:setupSizing( setup.sizing )
    self:setupPadding( setup.padding )
    self:setupTextAlign( setup.textAlign )
    self:setupTextSize( setup.textSize )
    self:setupFont( setup.font )
    self:setupText( setup.text )
    self:setupLayoutDirection( setup.layoutDirection )
    self:setupChildSpacing( setup.childSpacing )
    self:setupColor( setup.color )
    self:setupRounded( setup.rounded )
    self:setupTexture( setup.texture )
    self:setupFile( setup.file )
end


-- Setup Functions

--- @private
function base:setupBackgroundColor( color )
    if not( color ) then
        self.backgroundColor = artist.mixPaint( 0, 0, 0, 0 )
    else
        self.backgroundColor = color
    end
end


--- @private
function base:setupPosition( position )
    if not( position ) then
        self.x = 0
        self.y = 0
    else
        self.x = position.x
        self.y = position.y

        if not( position.x ) then self.x = 0 end
        if not( position.y ) then self.y = 0 end
    end
end


--- @private
function base:setupSizing( sizing )
    -- Defaults if no sizing provided
    if not( sizing ) then
        self.sizing = { width = gui.sizing.shrink, hegiht = gui.sizing.shrink }
    else
        self.sizing = sizing

        -- Check if only width or height was set
        if not( sizing.width ) then
            self.sizing.width = gui.sizing.shrink
        end

        if not( sizing.height ) then
            self.sizing.height = gui.sizing.shrink
        end
    end

    if type( self.sizing.width ) == "number" then
        self.width = sizing.width
        self.minWidth = sizing.width
    else
        self.width = 0
        self.minWidth = 0
    end

    if type( self.sizing.height ) == "number" then
        self.height = sizing.height
        self.minHeight = sizing.height
    else
        self.height = 0
        self.minHeight = 0
    end
end


--- @private
function base:setupPadding( padding )
    if not( padding ) then
        self.padding = { bottom = 0, left = 0, right = 0, top = 0 }
        return
    end

    self.padding = padding

    if not( padding.left ) then self.padding.left = 0 end
    if not( padding.right ) then self.padding.right = 0 end
    if not( padding.top ) then self.padding.top = 0 end
    if not( padding.bottom ) then self.padding.bottom = 0 end
end


--- @private
function base:setupLayoutDirection( direction )
    if not( direction ) then
        self.layoutDirection = gui.layoutDirection.leftToRight
        return
    end

    self.layoutDirection = direction
end


--- @private
function base:setupChildSpacing( spacing )
    if not( spacing ) then
        self.childSpacing = 0
        return
    end

    self.childSpacing = spacing
end


--- @private
function base:setupColor( color )
    if not( color ) then
        self.color = artist.mixPaint( 0, 0, 0 )
        return
    end

    self.color = color
end


--- @private
function base:setupTextAlign( align )
    if not( align ) then self.textAlign = "left" return end
    self.textAlign = align
end


--- @private
function base:setupTextSize( size )
    if not( size ) then self.textSize = 12 return end
    self.textSize = size
end


--- @private
function base:setupFont( font )
    if not( font ) then self.font = defualtFont return end
    self.font = font
end


--- @private
function base:setupText( text )
    if not( text ) then
        self.text = nil
        return
    end

    self.text = text

    local font = self.font:getFont( self.textSize )
    local widest = 0

    for word in string.gmatch( text, "%S+" ) do
        widest = math.max( widest, font:getWidth( word ) )
    end

    local padding = self.padding

    self.minWidth = widest + padding.right + padding.left
    self.width = font:getWidth( text )
end


--- @private
function base:setupRounded( isRounded )
    if isRounded then self.rounded = true return end
    self.rounded = false
end


--- @private
function base:setupFile( filepath )
    if not( filepath ) then return end
    self:setupTexture( love.graphics.newImage( filepath ) )
end


--- @private
--- @param texture love.Texture
function base:setupTexture( texture )
    if not( texture ) then self.texture = nil return end

    self.texture = texture

    self.minHeight = self.minHeight + texture:getHeight()
    self.minWidth = self.minWidth + texture:getWidth()

    self.width = self.minWidth
    self.height = self.minHeight
end


-- Child and Parents

--- @package
--- @param child  GUI.Element
function base:addChild( child )
    child:setParent( self )
    self.children:append( child )
end


function gui.gatherSlimelets()
    assert( not( elementStack:isEmpty() ) )

    --- @type GUI.Element
    local element = elementStack:popBack()
    element:close()
end


--- @return GUI.Element
function base:__call()
    gui.gatherSlimelets()
    return self
end


--- @package
function base:close()
    self:fitShrinkWidths()
    self:expandAndShrinkWidths()
    self:wrapText()
    self:fitShrinkHeights()
    self:expandAndShrinkHeights()
end


--- @package
function base:fitShrinkWidths()
    local padding = self.padding

    self.width = self.width + padding.left + padding.right

    local parent = self.parent

    if not( parent ) then
        if not( self.sizing.width == gui.sizing.shrink ) then return end

        local max = math.max

        for _, child in ipairs( self.children ) do
            self.width = max( self.width, child.width + padding.left + padding.right )
        end

        return
    end

    local childSpacing = ( parent:getAmountOfChildren() - 1 ) * parent.childSpacing
    local parentSizing = parent.sizing

    -- Left to Right
    if parent:getLayoutDirection() == gui.layoutDirection.leftToRight then
        if not( parentSizing.width == gui.sizing.shrink ) then return end

        parent.width = parent.width + childSpacing
        parent.width = parent.width + self.width
        parent.minWidth = parent.minWidth + self.minWidth

    -- Top to Bottom
    else
        if not( parentSizing.width == gui.sizing.shrink ) then return end

        parent.width = math.max( parent.width, self.width )
        parent.minWidth = math.max( parent.width, self.minWidth)
    end
end

--- @package
function base:expandAndShrinkWidths()
    local padding = self.padding
    local remainingWidth = self.width - padding.left - padding.right
    local maxWidth = remainingWidth

    --- @type List<GUI.Element>, List<GUI.Element>
    local growable, shrinkable = teacher.makeList(), teacher.makeList()

    local max, min = math.max, math.min

    for _, child in ipairs( self.children ) do
        remainingWidth = remainingWidth - child.width

        if child.sizing.width == gui.sizing.expand then growable:append( child ) end
        if child.width > child.minWidth then shrinkable:append( child ) end
    end

    remainingWidth = remainingWidth - ( #self.children - 1 ) * self.childSpacing

    -- Left to Right
    if self.layoutDirection == gui.layoutDirection.leftToRight then
        -- Grow
        while remainingWidth > 0 and not( growable:isEmpty() ) do
            local smallest = growable[1].width
            local secondSmallest = math.huge
            local widthToAdd = remainingWidth

            for _, child in ipairs( growable ) do
                local width = child.width

                if width < smallest then
                    secondSmallest = smallest
                    smallest = width
                end

                if width > smallest then
                    secondSmallest = min( secondSmallest, width )
                    widthToAdd = secondSmallest - smallest
                end
            end

            widthToAdd = min( widthToAdd, remainingWidth / #growable )

            for _, child in ipairs( growable ) do
                if not( child.width == smallest ) then goto skip end

                child.width = child.width + widthToAdd
                remainingWidth = remainingWidth - widthToAdd

                ::skip::
            end
        end

        if math.abs( remainingWidth ) < 0.0001 or shrinkable:isEmpty() then
            return
        end

        -- Shrink
        while remainingWidth < 0 do
            local largest = shrinkable[1].width
            local secondLargest = 0
            local widthToAdd = remainingWidth

            for _, child in ipairs( shrinkable ) do
                local width = child.width

                if width > largest then
                    secondLargest = largest
                    largest = width
                end

                if width < largest then
                    secondLargest = max( secondLargest, width )
                    widthToAdd = secondLargest - largest
                end
            end

            widthToAdd = max( widthToAdd, remainingWidth / #shrinkable )

            for _, child in ipairs( shrinkable ) do
                local previousWidth = child.width
                if not( child.width == largest ) then goto skip end

                child.width = child.width + widthToAdd -- is negative so it will shrink
                remainingWidth = remainingWidth - ( child.width - previousWidth )

                if child.width <= child.minWidth then
                    child.width = child.minWidth
                    shrinkable:erase( child )
                end

                ::skip::
            end
        end

    -- Top to Bottom
    else
        for _, child in ipairs( growable ) do
            child.width = maxWidth
        end
    end
end


--- @package
function base:wrapText()
    for _, child in ipairs( self.children ) do
        if child.text then
            child:sizeToText()
        end

        child:wrapText()
    end
end


--- @package
function base:sizeToText()
    local font = self.font:getFont( self.textSize )
    local padding = self.padding
    local _, lines = font:getWrap( self.text, self.width - padding.left - padding.right )
    self.minHeight = #lines * font:getHeight() + padding.top + padding.bottom
    self.height = self.minHeight
end


--- @package
function base:fitShrinkHeights()
    local padding = self.padding

    self.height = self.height + padding.top + padding.bottom

    local parent = self.parent

    if not( parent ) then
        if not( self.sizing.height == gui.sizing.shrink ) then return end

        local max = math.max

        for _, child in ipairs( self.children ) do
            self.height = max( self.height, child.height + padding.top + padding.bottom )
        end

        return
    end

    local childSpacing = ( parent:getAmountOfChildren() - 1 ) * parent.childSpacing
    local parentSizing = parent:getSizing()

    -- Left to Right
    if parent:getLayoutDirection() == gui.layoutDirection.leftToRight then
        if not( parentSizing.height == gui.sizing.shrink ) then return end

        parent.height = math.max( parent.height, self.height )
        parent.minHeight = math.max( parent.minHeight, self.minHeight )

    -- Top to Bottom
    else
        if not( parentSizing.height == gui.sizing.shrink ) then return end

        parent.height = parent.height + childSpacing
        parent.height = parent.height + self.height
        parent.minHeight = parent.minHeight + self.minHeight
    end
end


--- @package
function base:expandAndShrinkHeights()
    local padding = self.padding
    local remainingHeight = self.height - padding.top - padding.bottom
    local maxHeight = remainingHeight

    --- @type List<GUI.Element>, List<GUI.Element>
    local growable, shrinkable = teacher.makeList(), teacher.makeList()

    local min, max = math.min, math.max

    for _, child in ipairs( self.children ) do
        remainingHeight = remainingHeight - child.height

        if child.sizing.height == gui.sizing.expand then growable:append( child ) end
        if child.height > child.minHeight then shrinkable:append( child ) end
    end

    remainingHeight = remainingHeight - ( #self.children - 1 ) * self.childSpacing

    -- Left to Right
    if self.layoutDirection == gui.layoutDirection.leftToRight then
        for _, child in ipairs( growable ) do
            child.height = maxHeight
        end
    -- Top to Bottom
    else
        while remainingHeight > 0 and not( growable:isEmpty() ) do
            local smallest = growable[1].height
            local secondSmallest = math.huge
            local heightToAdd = remainingHeight

            for _, child in ipairs( growable ) do
                local height = child.height

                if height < smallest then
                    secondSmallest = smallest
                    smallest = height
                end

                if height > smallest then
                    secondSmallest = min( secondSmallest, height )
                    heightToAdd = secondSmallest - smallest
                end
            end

            heightToAdd = min( heightToAdd, remainingHeight / #growable )

            for _, child in ipairs( growable ) do
                if not( child.height == smallest ) then goto skip end

                child.height = child.height + heightToAdd
                remainingHeight = remainingHeight - heightToAdd

                ::skip::
            end
        end

        if math.abs( remainingHeight ) < 0.0001 or shrinkable:isEmpty() then
            return
        end

        -- Shrink
        while remainingHeight < 0 do
            local largest = shrinkable[1].height
            local secondLargest = 0
            local heightToAdd = remainingHeight

            for _, child in ipairs( shrinkable ) do
                local height = child.height

                if height > largest then
                    secondLargest = largest
                    largest = height
                end

                if height < largest then
                    secondLargest = max( secondLargest, height )
                    heightToAdd = secondLargest - largest
                end
            end

            heightToAdd = max( heightToAdd, remainingHeight / #shrinkable )

            for _, child in ipairs( shrinkable ) do
                local previousHeight = child.height
                if not( child.height == largest ) then goto skip end

                child.height = child.height + heightToAdd -- is negative so it will shrink
                remainingHeight = remainingHeight - ( child.height - previousHeight )

                if child.height <= child.minHeight then
                    child.height = child.minHeight
                    shrinkable:erase( child )
                end

                ::skip::
            end
        end
    end
end


-- Getter and Setter Functions

--- @package
--- @param minHeight number
function base:setMinHeight( minHeight )
    self.minHeight = minHeight
end


--- @package
--- @param minWidth number
function base:setMinWidth( minWidth )
    self.minWidth = minWidth
end


--- @package
--- @return number
function base:getMinWidth()
    return self.minWidth
end


--- @package
--- @return number
function base:getMinHeight()
    return self.minHeight
end


--- @package
--- @param width number
function base:setWidth( width )
    self.width = width
end


--- @package
--- @param height  number
function base:setHeight( height )
    self.height = height
end


--- @package
--- @return GUI.LayoutDirection
function base:getLayoutDirection()
    return self.layoutDirection
end


--- @package
--- @return number
function base:getAmountOfChildren()
    return #self.children
end


--- @package
--- @return { width : GUI.Sizing|number, height : GUI.Sizing|number }
function base:getSizing()
    return self.sizing
end


--- @package
function base:setParent( parent )
    self.parent = parent
end


--- @package
--- @return number
function base:getWidth()
    return self.width
end


--- @package
--- @return number
function base:getHeight()
    return self.height
end


function base:draw()
    love.graphics.push()

    if self.rounded then
        artist.drawRectangleRound( "fill", self.x, self.y, self.width, self.height, self.backgroundColor )
    else
        artist.drawRectangle( "fill", self.x, self.y, self.width, self.height, self.backgroundColor )
    end

    local padding = self.padding

    love.graphics.translate( padding.left, padding.top )

    if self.texture then
        artist.drawTexture( self.texture, 0, 0 )
    end

    if self.text then
        local limit = self.width - padding.left - padding.right
        local font = self.font:getFont( self.textSize )
        artist.write( self.text, self.x, self.y, limit, self.textAlign, self.color, font )
    end

    love.graphics.translate( self.x, self.y )

    for _, child in ipairs( self.children ) do
        child:draw()

        local childSpacing = self.childSpacing
        if self.layoutDirection == gui.layoutDirection.leftToRight then
            love.graphics.translate( child:getWidth() + childSpacing, 0 )
        else
            love.graphics.translate( 0, child:getHeight() + childSpacing )
        end
    end

    love.graphics.pop()
end


--- @private
base.__index = base

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
    mainCanvas:setFilter( "nearest", "nearest" )
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
--- @field private subfilters List< Filter >
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
--- @field private filter Filter
--- @field private entities List< table >
--- @field private isPre boolean
local baseSystem = {}


--- @private
baseSystem.__index = baseSystem


--- Returns all the entities that this system will apply to with its filter.
--- @return List< table >
function baseSystem:getEntities()
    return self.entities
end


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
--- @return boolean
function baseSystem:getIsPre()
    return self.isPre
end


--- @param filter Filter
--- @param isPre boolean
local function newSystem( filter, isPre )
    local obj = {}

    obj.filter = filter
    obj.entities = teacher.makeList()
    obj.isPre = isPre

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
--- @param isPreDrawSystem boolean If true, will execute BEFORE the scene.draw function. If false it will execute AFTER.
--- @return DrawSystem
function ecs.newDrawSystem( filter, isPreDrawSystem )
    local system = newSystem( filter, isPreDrawSystem )
    system.draw = function() end

    setmetatable( system, baseDrawSystem )

    return system
end


--- @class UpdateSystem : System
--- @field update fun( entity : table, deltaTime : number )
local baseUpdateSystem = {}
setmetatable( baseUpdateSystem, baseSystem )


--- @private
baseUpdateSystem.__index = baseUpdateSystem


--- @param filter Filter
--- @param isPreUpdateSystem boolean If true, will execute BEFORE the scene.update function. If false it will execute AFTER.
--- @return UpdateSystem
function ecs.newUpdateSystem( filter, isPreUpdateSystem )
    local system = newSystem( filter, isPreUpdateSystem )
    system.update = function() end

    setmetatable( system, baseUpdateSystem )

    return system
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


-- Scenes

--- @class Scene
--- @field private preDrawSystems List< DrawSystem >
--- @field private postDrawSystems List< DrawSystem >
--- @field private preUpdateSystems List< UpdateSystem >
--- @field private postUpdateSystems List< UpdateSystem >
--- @field private allSystems List< System >
--- @field private entities List< table >
--- @field private entityTrash List< table >
--- @field enter fun()
--- @field exit fun()
--- @field update fun( deltaTime : number )
--- @field draw fun()
local baseScene = {}


--- @private
baseScene.__index = baseScene


--- @param entity table
function baseScene:addEntity( entity )
    self.entities:append( entity )

    for _, system in ipairs( self.allSystems ) do
        system:addEntity( entity )
    end
end


--- @param system System
function baseScene:addSystem( system )
    for _, entity in ipairs( self.entities ) do
        system:addEntity( entity )
    end

    local metatable = getmetatable( system )

    if metatable == baseDrawSystem then
        if system:getIsPre() then
            self.preDrawSystems:append( system )
        else
            self.postDrawSystems:append( system )
        end
    elseif metatable == baseUpdateSystem then
        if system:getIsPre() then
            self.preUpdateSystems:append( system )
        else
            self.postUpdateSystems:append( system )
        end
    end

    self.allSystems:append( system )
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
--- @return List< UpdateSystem >
function baseScene:getPreUpdateSystems()
    return self.preUpdateSystems
end


--- @package
--- @return List< UpdateSystem >
function baseScene:getPostUpdateSystems()
    return self.postUpdateSystems
end


--- @package
--- @return List< DrawSystem >
function baseScene:getPreDrawSystems()
    return self.preDrawSystems
end


--- @package
--- @return List< DrawSystem >
function baseScene:getPostDrawSystems()
    return self.postDrawSystems
end


--- @return Scene
function sceneManager.newScene()
    local object = {}

    object.preDrawSystems = teacher.makeList()
    object.postDrawSystems = teacher.makeList()
    object.preUpdateSystems = teacher.makeList()
    object.postUpdateSystems = teacher.makeList()
    object.allSystems = teacher.makeList()
    object.entities = teacher.makeList()
    object.entityTrash = teacher.makeList()

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
