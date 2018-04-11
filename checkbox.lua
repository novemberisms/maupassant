local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Cursors = require(_PACKAGE .. "/cursors")

local Input = require(_PACKAGE .. "/input")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local CheckBox = Input:extend()
CheckBox.classname = "CheckBox"

function CheckBox:new(args)
  Input.new(self, args)

  self:listenMouseMoved()
  self:listenMousePressed()
  self:listenMouseReleased()

  self.value = args.value or false
  self.state = self.value and "on" or "off"

  self.stylebox_on = args.stylebox_on
  self.stylebox_off = args.stylebox_off
  self:setStyleBoxNoUpdate(self.value and args.stylebox_on or args.stylebox_off)

  self.onToggleOn = args.onToggleOn
  self.onToggleOff = args.onToggleOff
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function CheckBox:getValue()
  return self.value
end

function CheckBox:toggleValue()
  self.value = not self.value
  self:setState(self.value and "on" or "off")
  -- callbacks
  if self.onToggleOn and self.value then
    self.onToggleOn()
  elseif self.onToggleOff and not self.value then
    self.onToggleOff()
  end 
end

function CheckBox:setState(state)
  self.state = state
  self:setStyleBox(self["stylebox_" .. state])
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function CheckBox:mouseovered(x, y)
  Cursors.setCursor("hand")
end

function CheckBox:mouseleft(x, y)
  Cursors.setCursor("normal")
end

function CheckBox:pressed(x, y, button)
  self:toggleValue()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function CheckBox:draw()
  self.stylebox:draw(self.pos, self.size)
  self:drawChildren()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return CheckBox