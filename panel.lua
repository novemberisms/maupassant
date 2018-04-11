local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Container = require(_PACKAGE .. "/container")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Panel = Container:extend()
Panel.classname = "Panel"

function Panel:new(args)
  Container.new(self,args)
  -- for 9slice styleboxes, since they need to be resized
  self:setStyleBoxNoUpdate(args.stylebox)
end

function Panel:setStyleBoxNoUpdate(new_stylebox)
  if not new_stylebox then return end
  if new_stylebox.size and (new_stylebox.size ~= self.size) then
    self.stylebox = new_stylebox:copy {size_x = self.size.x, size_y = self.size.y}
  else
    self.stylebox = new_stylebox
  end
end

function Panel:setStyleBox(new_stylebox)
  if new_stylebox.size and (new_stylebox.size ~= self.size) then
    self.stylebox = new_stylebox:copy {size_x = self.size.x, size_y = self.size.y}
  else
    self.stylebox = new_stylebox
  end
  self:update()
end

function Panel:updateSize()
  Container.updateSize(self)
  if self.stylebox then
    self.stylebox:updateSize(self.size)
  end
end

function Panel:draw()
  self.stylebox:draw(self.pos, self.size)
  self:drawChildren()
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Panel