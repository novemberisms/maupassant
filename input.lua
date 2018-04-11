local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Panel = require(_PACKAGE .. "/panel")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- Listener lists
local mousemoved_listeners = {}
local mousepressed_listeners = {}
local mousereleased_listeners = {}
local keypressed_listeners = {}
local textinput_listeners = {}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Input = Panel:extend()
Input.classname = "Input"

function Input:new(args)
  Panel.new(self, args)
  self.enabled = util.tern(args.enabled == nil, true, args.enabled)

  self.hitbox_mask_tl = Vector(0, 0)
  self.hitbox_mask_br = Vector(1, 1)

  self.z_level = 1 -- updated during :ready()
end

function Input:ready()
  self.z_level = self:findZLevel()
end

function Input:listenMouseMoved()
  table.insert(mousemoved_listeners, self)
end
function Input:listenMousePressed()
  table.insert(mousepressed_listeners, self)
end
function Input:listenMouseReleased()
  table.insert(mousereleased_listeners, self)
end
function Input:listenTextInput()
  table.insert(textinput_listeners, self)
end
function Input:listenKeyPressed()
  table.insert(keypressed_listeners, self)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- methods


function Input:disable()
  self.enabled = false
end

function Input:enable()
  self.enabled = true
end

function Input:findZLevel()
  -- z level is merely based on how deep it is in the gui tree. to artificially boost the z level,
  -- add the property 'z_height' to the parent
  local z = self.z_height
  local curr_ancestor = self.parent
  while curr_ancestor do
    z = z + curr_ancestor.z_height
    curr_ancestor = curr_ancestor.parent
  end
  return z
end

function Input:isPointWithinSelf(x, y)
  if not self.visible then return false end
  local hit_tl = self.pos + (self.size % self.hitbox_mask_tl)
  local hit_br = self.pos + (self.size % self.hitbox_mask_br)
  if x < hit_tl.x then return false end
  if y < hit_tl.y then return false end
  if x >= hit_br.x then return false end  -- the >= ensures that if hitbox size is 0 then no detection
  if y >= hit_br.y then return false end
  return true
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- static callbacks
local mouseovered_element -- the only element that is mouseovered
local focused_element -- the only element that is focused

function Input.getMouseoveredElement() return mouseovered_element end
function Input.getFocusedElement() return focused_element end

function Input:isMouseOvered() return mouseovered_element == self end
function Input:isFocused() return focused_element == self end

function Input.updateMouseOveredElement(x, y)
  -- find the element that the mouse is over (there can only be one)
  mouseovered_element = nil
  local highest_z = 0
  for i = 1, #mousemoved_listeners do
    local listener = mousemoved_listeners[i]
    if listener.visible and listener.enabled and (listener.z_level > highest_z) then
      if listener.flags.IS_WITHIN_SCROLLBOX then
        local ancestor_scrollbox = listener.__ANCESTOR_SCROLLBOX
        if ancestor_scrollbox:isPointWithinCanvas(x, y) then
          if listener:isPointWithinSelf(ancestor_scrollbox:transformScreenPoint(x, y)) then     
            mouseovered_element = listener
            highest_z = listener.z_level
          end
        end
      elseif listener:isPointWithinSelf(x, y) then
        mouseovered_element = listener
        highest_z = listener.z_level
      end
    end
  end
end

function Input.stealFocus(element)
  if focused_element then focused_element:onLoseFocus() end
  if element then element:onGainFocus() end
  focused_element = element
end

function Input.applytransforms(element, x, y)
  if element.flags.IS_WITHIN_SCROLLBOX then
    local ancestor_scrollbox = element.__ANCESTOR_SCROLLBOX
    if ancestor_scrollbox:isPointWithinCanvas(x, y) then
      return ancestor_scrollbox:transformScreenPoint(x, y)
    end
  end
  return x, y
end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Input.__mousemoved(x, y, dx, dy)

  Input.updateMouseOveredElement(x, y)

  for i = 1, #mousemoved_listeners do
    local element = mousemoved_listeners[i]
    if element.enabled then
      element:mousemoved(Input.applytransforms(element, x, y))
    end
  end
end

function Input.__mousepressed(x, y, button)
  for i = 1, #mousepressed_listeners do
    local element = mousepressed_listeners[i]
    if element.enabled then
      local x, y = Input.applytransforms(element, x, y)
      element:mousepressed(x, y, button)
    end
  end

  if not mouseovered_element then Input.stealFocus(nil) end
end

function Input.__mousereleased(x, y, button)
  for i = 1, #mousereleased_listeners do
    local element = mousereleased_listeners[i]
    if element.enabled then
      local x, y = Input.applytransforms(element, x, y)
      element:mousereleased(x, y, button)
    end
  end
end

function Input.__textinput(...)
  for i = 1, #textinput_listeners do
    if textinput_listeners[i].enabled then
      textinput_listeners[i]:ontextinput(...)
    end
  end
end

function Input.__keypressed(...)
  for i = 1, #keypressed_listeners do
    if keypressed_listeners[i].enabled then
      keypressed_listeners[i]:onkeypressed(...)
    end
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- INTERMEDIATE CALLBACKS (CALLBACKS THAT CALL OTHER CALLBACKS)


function Input:mousemoved(x, y, dx, dy)
  local is_over_me = self:isMouseOvered()
  -- if already mouseovered and mouse just left
  if (self.flags.MOUSEOVERED) and (not is_over_me) then
    self.flags.MOUSEOVERED = nil
    self.flags.MOUSEDOWN = nil
    self:mouseleft(x, y)
  -- if not mouseovered yet and mouse just entered
  elseif (not self.flags.MOUSEOVERED) and (is_over_me) then
    self.flags.MOUSEOVERED = true
    self:mouseovered(x, y)
  -- if mouse clicked on top of element and mouse moved
  elseif self.flags.MOUSEDOWN and is_over_me then
    self.flags.DRAGGED = true
  end

  if self.flags.DRAGGED then
    self:mousedragged(x, y, dx, dy)
  end
end

function Input:mousepressed(x, y, button)
  self:pressedAnywhere(button, x, y)
  if self:isMouseOvered() then
    self.flags.MOUSEDOWN = true
    Input.stealFocus(self)
    -- the reason button comes first is because this library focuses on keyboard and controller input as well
    self:pressed(button, x, y)  
  end
end

function Input:mousereleased(x, y, button)
  if self.flags.DRAGGED then
    self:dragReleased(button, x, y)
  end
  self.flags.MOUSEDOWN = nil
  self.flags.DRAGGED = nil
  self:releasedAnywhere(button, x, y)
  -- if self:isMouseOvered() then
  --   self:released(button, x, y)
  -- end
end

function Input:ontextinput(char)
  if self:isFocused() then
    self:textinput(char)
  end
end

function Input:onkeypressed(key)
  if self:isFocused() then
    self:keypressed(key)
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- OVERRIDEABLE CALLBACKS
function Input:mouseovered(x, y) end
function Input:mouseleft(x, y) end
function Input:mousedragged(x, y, dx, dy) end
function Input:pressed(button, x, y) end
function Input:pressedAnywhere(button, x, y) end
-- function Input:released(button, x, y) end
function Input:dragReleased(button, x, y) end
function Input:releasedAnywhere(button, x, y) end
function Input:keypressed(key) end
function Input:textinput(char) end
function Input:onGainFocus() end
function Input:onLoseFocus() end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Input