local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Panel = require(_PACKAGE .. "/panel")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local ProgressBar = Panel:extend()
ProgressBar.classname = "ProgressBar"

function ProgressBar:new(args)
  Panel.new(self,args)

  self.stylebox_filled = args.stylebox_filled or self.stylebox
  self.stylebox_empty = args.stylebox_empty or self.stylebox

  self.min_value = args.min_value or 0
  self.max_value = args.max_value or 100
  self.value = args.value or 0
end

function ProgressBar:__get_ratio()
  return (self.value - self.min_value) / (self.max_value - self.min_value)
end

function ProgressBar:__set_ratio(ratio)
  self.value = self.min_value + ratio * (self.max_value - self.min_value)
end

function ProgressBar:__get_percent()
  return 100 * self.ratio
end

function ProgressBar:__set_percent(percent)
  self.ratio = percent / 100
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ProgressBar:getFilledSize()
  return Vector(self.ratio * self.size.x, self.size.y)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ProgressBar:draw()
  local filled_size = self:getFilledSize()
  self.stylebox_empty:draw(self.pos, self.size)
  if not (self.value <= self.min_value) then
    self.stylebox_filled:draw(self.pos, filled_size)
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return ProgressBar