local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local StyleBox = require(_PACKAGE .. "/stylebox")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local BasicStyleBox = StyleBox:extend()

function BasicStyleBox:new(args)
  self.back_color = args.back_color or {203, 219, 252, 255}
  self.box_offset = Vector(args.box_offset_x, args.box_offset_y)
  self.box_radius = args.box_radius or 0

  self.border_enabled = args.border_enabled or false
  self.border_width = args.border_width or 0
  self.border_color = args.border_color or {34, 32, 52, 255} or {185, 207, 250, 255}

  self.shadow_enabled = args.shadow_enabled or false
  self.shadow_color = args.shadow_color or {0, 0, 0, 100}
  self.shadow_distance = args.shadow_distance or 5
  self.shadow_angle = args.shadow_angle or math.pi / 2

  self.args = args
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function BasicStyleBox:copy(newargs) 
  local args = util.copyTable(self.args)
  for k,v in pairs(newargs or {}) do args[k] = v end
  local copy = BasicStyleBox(args)
  return copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function BasicStyleBox:draw(pos, size)
  if self.shadow_enabled then
    local shadow_dir = Vector(1, 0):angled(self.shadow_angle)
    local border_offset = -Vector(self.border_width, self.border_width) / 2
    local shadow_pos = pos + shadow_dir * (self.shadow_distance) + border_offset
    love.graphics.setColor(unpack(self.shadow_color))
    love.graphics.rectangle("fill", 
      shadow_pos.x,
      shadow_pos.y,
      size.x + self.border_width, 
      size.y + self.border_width,
      self.box_radius, self.box_radius
    )
  end
  -- draw main rectangle
  local boxpos = pos + self.box_offset

  love.graphics.setColor(unpack(self.back_color))
    love.graphics.rectangle("fill", 
      boxpos.x, 
      boxpos.y, 
      size.x, size.y,
      self.box_radius, self.box_radius
    )
  -- draw border
  if self.border_enabled and (self.border_width > 0) then
  love.graphics.setColor(unpack(self.border_color))
    love.graphics.setLineWidth(self.border_width)
      love.graphics.rectangle("line", 
        boxpos.x, 
        boxpos.y, 
        size.x,
        size.y,
        self.box_radius, 
        self.box_radius
      )
    love.graphics.setLineWidth(1)
  end
  love.graphics.setColor(255, 255, 255, 255)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
return BasicStyleBox