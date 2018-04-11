local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local TimedUpdateManager = require(_PACKAGE .. "/timed_update_manager")

local CheckBox = require(_PACKAGE .. "/checkbox")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local ToggleBox = CheckBox:extend()
ToggleBox.classname = "ToggleBox"
ToggleBox.ANIMATION_TIME = 0.5

function ToggleBox:new(args)
  CheckBox.new(self, args)

  self.stylebox_sliderhead = args.stylebox_sliderhead
  self.sliderhead_size = Vector(args.sliderhead_width, args.sliderhead_height)
  self.sliderhead_offset = self.value and self.size - self.sliderhead_size or Vector(0, 0)
  self.sliderhead_desired_offset = self.sliderhead_offset.copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ToggleBox:toggleValue()
  CheckBox.toggleValue(self)
  -- sliderhead
  self.sliderhead_desired_offset = self.value and self.size - self.sliderhead_size or Vector(0, 0)
  TimedUpdateManager:register(self)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ToggleBox:draw()
  self.stylebox:draw(self.pos, self.size)
  self.stylebox_sliderhead:draw(self.pos + self.sliderhead_offset, self.sliderhead_size)
  self:drawChildren()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ToggleBox:timedUpdate(dt)
  local dir = (self.sliderhead_desired_offset - self.sliderhead_offset).normalized
  local vel = (self.size.length / self.ANIMATION_TIME) * dir
  self.sliderhead_offset = self.sliderhead_offset + dt * vel
  if (self.sliderhead_desired_offset - self.sliderhead_offset).length2 < 0.1 then
    self.sliderhead_offset = self.sliderhead_desired_offset.copy
    TimedUpdateManager:unregister(self)
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return ToggleBox