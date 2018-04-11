local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Cursors = require(_PACKAGE .. "/cursors")
local TimedUpdateManager = require(_PACKAGE .. "/timed_update_manager")

local Input = require(_PACKAGE .. "/input")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local TextInput = Input:extend()
TextInput.classname = "TextInput"

function TextInput:new(args)
  Input.new(self, args)

  self:listenMouseMoved()
  self:listenMousePressed()
  self:listenMouseReleased()
  self:listenTextInput()
  self:listenKeyPressed()

  self.stylebox_unfocused = args.stylebox_unfocused
  self.stylebox_hovered = args.stylebox_hovered or args.stylebox_unfocused
  self.stylebox_focused = args.stylebox_focused or args.stylebox_unfocused

  self:setStyleBoxNoUpdate(self.stylebox_unfocused)

  self.state = "unfocused"

  self.h_align = args.h_align or "left"
  -- self.v_align is always "center" due to the way printf works.

  self.font = args.font
  self.text = args.text or ""
  self.text_color = args.text_color

  self.clear_on_refocus = args.clear_on_refocus or false

  self.caret_enabled = util.tern(args.caret_enabled == nil, true, false)
  self.caret_blink_period = 1
  self.caret_visible = false
  self.caret_timer = 0
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function TextInput:setState(state)
  self.state = state
  self:setStyleBox(self["stylebox_" .. state])
end

function TextInput:backspace()
  self.text = self.text:sub(1, -2)    -- get the text starting from char 1 to char -2 (second from the last)
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TextInput:textinput(char)
  -- already assumes that we have focus
  self.text = self.text .. char
end

function TextInput:mouseovered()
  if not self:isFocused() then
    self:setState("hovered")
  end
  Cursors.setCursor("ibeam")
end

function TextInput:mouseleft()
  if self.state == "hovered" then
    self:setState("unfocused")
  end
  Cursors.setCursor("normal")
end

function TextInput:onGainFocus()
  self:setState("focused")
  TimedUpdateManager:register(self)
  love.keyboard.setKeyRepeat(true)
  if self.clear_on_refocus then self.text = "" end
end

function TextInput:onLoseFocus()
  self:setState("unfocused")
  TimedUpdateManager:unregister(self)
  love.keyboard.setKeyRepeat(false)
  self.caret_visible = false
end

function TextInput:keypressed(key)
  if key == "backspace" then
    self:backspace()
  elseif key == "return" then
    -- lose focus
    Input.stealFocus(nil)
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TextInput:draw()
  self.stylebox:draw(self.pos, self.size)
  local oldfont = love.graphics.getFont()
  love.graphics.setFont(self.font)
    love.graphics.setColor(unpack(self.text_color))
      local caret = self:getCaret() 
      local limit = self.size.x - self.margin_tl.x - self.margin_br.x
      local draw_x = self.pos.x + self.margin_tl.x
      local draw_y = self.pos.y + (self.size.y - self.font:getHeight())/2
      love.graphics.printf(self.text .. caret, draw_x, draw_y, limit, self.h_align)
    love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setFont(oldfont)
  self:drawChildren()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TextInput:timedUpdate(dt)
  if not self.caret_enabled then return end
  self.caret_timer = self.caret_timer + dt
  if self.caret_timer > self.caret_blink_period / 2 then
    self.caret_visible = not self.caret_visible
    self.caret_timer = 0
  end
end

function TextInput:getCaret()
  if not self.caret_enabled then return "" end
  if not self.caret_visible then return "" end
  return "|"    -- amazing technology
end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return TextInput