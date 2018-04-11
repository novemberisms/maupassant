-- LAST UPDATED: 4/11/18

local _PACKAGE = string.gsub(...,"%.","/") or ""

local gui = {}

-- indentation denotes inheritance tree

gui.StyleBox = require(_PACKAGE .. "/stylebox") 
    gui.BasicStyleBox = require(_PACKAGE .. "/stylebox_basic")
    gui.NineSliceStyleBox = require(_PACKAGE .. "/stylebox_nineslice")
    gui.SpriteStyleBox = require(_PACKAGE .. "/stylebox_sprite")
    gui.EmptyStyleBox = require(_PACKAGE .. "/stylebox_empty")
    
gui.Theme = require(_PACKAGE .. "/theme")
        
gui.Container = require(_PACKAGE .. "/container")
    gui.Image = require(_PACKAGE .. "/image")
    gui.Label = require(_PACKAGE .. "/label")
    gui.Organizer = require(_PACKAGE .. "/organizer")
        gui.GridOrganizer = require(_PACKAGE .. "/grid_organizer")
    gui.Panel = require(_PACKAGE .. "/panel")
        gui.Tab = require(_PACKAGE .. "/tab")
        gui.ProgressBar = require(_PACKAGE .. "/progress")
        gui.Input = require(_PACKAGE .. "/input")
            gui.Slider = require(_PACKAGE .. "/slider")
            gui.TextInput = require(_PACKAGE .. "/textinput")
                gui.NumberInput = require(_PACKAGE .. "/numberinput")
            gui.CheckBox = require(_PACKAGE .. "/checkbox")
                gui.ToggleBox = require(_PACKAGE .. "/togglebox")
            gui.Menu = require(_PACKAGE .. "/menu")
            gui.Button = require(_PACKAGE .. "/button") -- requires Label
                gui.ScrollDragger = require(_PACKAGE .. "/scrolldragger")
                gui.TabButton = require(_PACKAGE .. "/tab_button")
                gui.DropDown = require(_PACKAGE .. "/dropdown") -- requires menu
    gui.TabContainer = require(_PACKAGE .. "/tab_container")
    gui.ScrollBox = require(_PACKAGE .. "/scrollbox") -- requires ScrollDragger, Panel

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- root for the gui tree. represents the user's screen itself. 
gui.Screen = gui.Container {
  name = "Screen",
  anchor_x = 0,
  anchor_y = 0,
  size_x = love.graphics.getWidth(),
  size_y = love.graphics.getHeight(),
  margin_x = 0,
  margin_y = 0
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function gui:addChild(child)
  return gui.Screen:addChild(child)
end

function gui:pathGet(path)
  return gui.Screen:pathGet(path)
end

function gui:setTheme(theme)
  gui.Screen:setTheme(theme)
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local TimedUpdateManager = require(_PACKAGE .. "/timed_update_manager")

function gui.update(dt) 
  TimedUpdateManager:update(dt)
end

function gui.draw() 
  gui.Screen:draw()
end

function gui.resize(w, h)
  gui.Screen:resize(w, h)
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- INPUT STUFF

function gui.getMouseoveredElement()
  return gui.Input.getMouseoveredElement()
end

function gui.textinput(...)
  gui.Input.__textinput(...)
end

function gui.keypressed(...)  -- needed for backspace
  gui.Input.__keypressed(...)
end

function gui.mousemoved(...)
  gui.Input.__mousemoved(...)
end

function gui.mousepressed(...)
  gui.Input.__mousepressed(...)
end

function gui.mousereleased(...)
  gui.Input.__mousereleased(...)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- actions

function gui.confirm()
end

function gui.back()
end

function gui.alternate()
end

function gui.move_up()
end

function gui.move_down()
end

function gui.move_left()
end

function gui.move_right()
end

function gui.tab_left()
end

function gui.tab_right()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return gui