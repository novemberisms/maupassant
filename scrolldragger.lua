local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Button = require(_PACKAGE .. "/button")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local ScrollDragger = Button:extend()
ScrollDragger.classname = "ScrollDragger"

function ScrollDragger:new(args)
  Button.new(self, args)
  self.orientation = args.orientation
  if self.orientation == "horizontal" then
    self.mousedragged = self.mousedragged_horizontal
  else
    self.mousedragged = self.mousedragged_vertical
  end
  self.grablocation = nil
end

function ScrollDragger:pressed(button, x, y)
  self:setState("pressed")
  self.grablocation = Vector(x, y) - self.pos
end

function ScrollDragger:releasedAnywhere()
  if self.flags.MOUSEOVERED then
    self:setState("hovered")
  else
    self:setState("unpressed")
  end
  self.grablocation = nil
end

function ScrollDragger:mousedragged_vertical(x, y)
  self.y = y - self.grablocation.y
  local scrollbar = self.parent.v_scrollbar

  local distance_from_top = self.pos.y - scrollbar.pos.y
  local max_distance_from_top = scrollbar.size.y - self.size.y

  if distance_from_top < 0 then
    self.y = scrollbar.pos.y
    distance_from_top = 0
  elseif distance_from_top > max_distance_from_top then
    self.y = scrollbar.pos.y + max_distance_from_top
    distance_from_top = max_distance_from_top
  end

  local max_camera_offset = self.parent:getMaxCameraOffset()

  self.parent.camera_offset.y = max_camera_offset.y * (distance_from_top / max_distance_from_top)

end

function ScrollDragger:mousedragged_horizontal(x, y)
  self.x = x - self.grablocation.x
  local scrollbar = self.parent.h_scrollbar

  local distance_from_left = self.pos.x - scrollbar.pos.x
  local max_distance_from_left = scrollbar.size.x - self.size.x

  if distance_from_left < 0 then
    self.x = scrollbar.pos.x
    distance_from_left = 0
  elseif distance_from_left > max_distance_from_left then
    self.x = scrollbar.pos.x + max_distance_from_left
    distance_from_left = max_distance_from_left
  end

  local max_camera_offset = self.parent:getMaxCameraOffset()

  self.parent.camera_offset.x = max_camera_offset.x * (distance_from_left / max_distance_from_left)

end

function ScrollDragger:scrollTo(x, y)

end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return ScrollDragger