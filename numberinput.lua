local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local TextInput = require(_PACKAGE .. "/textinput")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local NumberInput = TextInput:extend()
NumberInput.classname = "NumberInput"

function NumberInput:new(args)
  TextInput.new(self, args)
  self.min = args.min or -math.huge
  self.max = args.max or math.huge
  self.float = util.tern(args.float == nil, true, args.float)

  self.init_value = args.value or 0
  self.clear_on_refocus = util.tern(
    args.clear_on_refocus == nil,
    true,
    args.clear_on_refocus
  )

  self.units = args.units
  self.previous_text = tostring(self.init_value)
  self.text = tostring(self.init_value)
end

function NumberInput:__get_value()
  return tonumber(self.text)
end
function NumberInput:__set_value(v)
  self.text = tostring(v)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NumberInput:onGainFocus()
  self.previous_text = self.text
  TextInput.onGainFocus(self)
end

function NumberInput:onLoseFocus()
  TextInput.onLoseFocus(self)
  self:validateText()
end

function NumberInput:validateText()
  if not tonumber(self.text) then
    self.text = self.previous_text
  end
  if self.value < self.min then
    self.value = self.min
  elseif self.value > self.max then
    self.value = self.max
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NumberInput:getCaret()
  local caret = TextInput.getCaret(self)
  if self.units and (self.state ~= "focused") then
    return " " .. self.units
  else
    return caret
  end
end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return NumberInput