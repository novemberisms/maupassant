local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Container = require(_PACKAGE .. "/container")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Organizer = Container:extend()
Organizer.classname = "Organizer"

-- automatically arranges children when you add new children to it
-- when in "vertical" mode, it will stack children from top to bottom
--    the children's anchor_y will not work, but their anchor_x will
--    vice versa for "horizontal" mode
-- if autospace is enabled, separation does not do anything because
--    children will be automatically spaced out to occupy the whole size of the organizer

function Organizer:new(args)
  Container.new(self, args)
  self.mode = args.mode or "vertical" -- "horizontal", "vertical"
  self.separation = args.separation or 0
  self.autospace = args.autospace or false
end

function Organizer:ready()
  self.addChild = self.addChildAfterReady
  self:organizeChildren()
end

function Organizer:addChildAfterReady(child)
  Container.addChild(self, child)
  self:organizeChildren()
  return child
end

function Organizer:updateChildren()
  Container.updateChildren(self)
  self:organizeChildren()
end

function Organizer:resizeOnChildren()
  -- get the last child's position and size
  local last_child = self.children[#self.children]
  self.size = last_child.pos + last_child.size + self.margin_br - self.pos
  self:update()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local function moveChild(child, newpos, axis)
  local destpos = child.pos.copy
  destpos[axis] = newpos[axis]
  
  child:move(destpos:split())
end

function Organizer:organizeChildren()
  local axis = "y"
  if self.mode == "horizontal" then axis = "x" end

  local separation_vec = self:getSeparationVec()

  local current_pos = self.pos + self.margin_tl
  if self.autospace then current_pos = current_pos + separation_vec / 2 end

  for _, child in ipairs(self.children) do
    moveChild(child, current_pos, axis)
    current_pos = current_pos + child.size + separation_vec
  end
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Organizer:getSeparationVec()
  if not self.autospace then return Vector(self.separation, self.separation) end
  -- determine the separation between children such that they will be equally spaced
  local available_space = self.size - self.margin_tl - self.margin_br
  for _, child in ipairs(self.children) do
    available_space = available_space - child.size
  end
  return available_space / #self.children
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Organizer