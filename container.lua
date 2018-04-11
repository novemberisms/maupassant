local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Object = dep.Object
local Vector = dep.Vector

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local Container = Object:extend()
Container.classname = "Container" -- required for the theme!

Container.default_theme = require(_PACKAGE .. "/default_theme")
Container.theme = Container.default_theme

function Container:new(args)

  -- apply theme to args
  local theme = args.theme or Container.theme
  theme:apply(self, args)
  
  if (not args.size_x or not args.size_y) then
    print(("maupassant WARNING: %s Element set with no size_x or size_y (%s)"):format(self.classname, args.name))
  end

  self.name = args.name
  self.anchor = Vector(args.anchor_x, args.anchor_y)
  self.margin_tl = Vector(args.margin_left or args.margin_x, args.margin_top or args.margin_y)
  self.margin_br = Vector(args.margin_right or args.margin_x, args.margin_bottom or args.margin_y)
  self.size = Vector(args.size_x, args.size_y)

  -- automatically set
  self.pos = Vector()

  self.scale_x_with_parent = args.scale_x_with_parent or false
  self.scale_y_with_parent = args.scale_y_with_parent or false
  self.original_size = self.size.copy

  self.visible = util.tern(args.visible == nil, true, args.visible)

  self.children = {}
  self.parent = args.parent

  self.flags = {}

  self.z_height = args.z_height or 1

  if args.children then
    for name, child in pairs(args.children) do
      if type(name) == "string" then
        child.name = name
      end
      self:addChild(child)
    end
  end

end

function Container.setTheme(new_theme)
  Container.theme = new_theme or Container.default_theme
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Container:addChild(child)
  table.insert(self.children, child)
  child.parent = self
  child:update()
  child:ready()
  return child
end

function Container:setVisible(value)
  self.visible = value
  for _,child in ipairs(self.children) do
    child:setVisible(value)
  end
end

-- called when parent and children are available!
function Container:ready()
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function Container:__set_anchor_x(x) self:reanchor(x, self.anchor.y) end
function Container:__set_anchor_y(y) self:reanchor(self.anchor.x, y) end

function Container:__set_x(x) self:move(x, self.pos.y) end
function Container:__set_y(y) self:move(self.pos.x, y) end

-- note that if scale_(xy)_with_parent is true, this setting size will be ignored
function Container:__set_size_x(x) self:resize(x, self.size.y) end
function Container:__set_size_y(y) self:resize(self.size.x, y) end

function Container:__set_margin_left(x)   self.margin_tl.x = x; self:update() end
function Container:__set_margin_right(x)  self.margin_br.x = x; self:update() end
function Container:__set_margin_top(y)    self.margin_tl.y = y; self:update() end
function Container:__set_margin_bottom(y) self.margin_br.y = y; self:update() end

function Container:__set_margin_x(x) 
  self.margin_tl.x = x
  self.margin_br.x = x
  self:update()
end
function Container:__set_margin_y(y)
  self.margin_tl.y = y
  self.margin_br.y = y
  self:update()
end

function Container:__get_height() return self.size.y end
function Container:__get_width() return self.size.x end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Container:updatePos()
  -- get that rectangle in the top left where the container's pos can be, given:
  --    the parent's position and size
  --    the parent's margins
  --    the container's size
  if not self.parent then return end
  local top_left = self.parent.pos + self.parent.margin_tl
  local bot_right = self.parent.pos + self.parent.size - self.parent.margin_br - self.size
  -- set position based on anchor ratios
  self.pos = top_left + self.anchor % (bot_right - top_left)
end

function Container:updateSize()
  if not self.parent then return end
  if self.scale_x_with_parent or self.scale_y_with_parent then
    local child_parent_ratio = self.original_size % self.parent.original_size.inverse
    local new_child_size = self.parent.size % child_parent_ratio
    if self.scale_x_with_parent then
      self.size.x = new_child_size.x
    end
    if self.scale_y_with_parent then
      self.size.y = new_child_size.y
    end
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function Container:reanchor(x, y)
  self.anchor.x = x
  self.anchor.y = y
  self:update()
end

function Container:resize(w, h)
  if self.scale_x_with_parent and (w ~= self.size.x) then error("cannot change width because scale_x_with_parent is true") end
  if self.scale_y_with_parent and (h ~= self.size.y) then error("cannot change height because scale_y_with_parent is true") end
  self.size.x = w
  self.size.y = h
  self:update()
end

function Container:move(x, y)
  -- find the anchor necessary to put it at position x relative to the parent
  local new_pos = Vector(x, y)
  local top_left = self.parent.pos + self.parent.margin_tl
  local bot_right = self.parent.pos + self.parent.size - self.parent.margin_br - self.size
  self.anchor = (new_pos - top_left) % (bot_right - top_left).inverse
  util.removeNaN(self.anchor)
  self:update()
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Container:pathGet(path)
  -- exit condition, for when the path is just a name with no '/'s
  for _,child in ipairs(self.children) do
    if child.name == path then
      return child
    end
  end
  -- else, recurse
  local child_to_search = path:match("[^/]*")     -- if "abc/def/ghi", will give "abc"
  local next_path = path:sub(path:find("/") + 1)  -- if "abc/def/ghi", will give "def/ghi"
  for _,child in ipairs(self.children) do
    if child.name == child_to_search then
      return child:pathGet(next_path)
    end
  end
  return nil
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Container:draw()
  self:drawChildren()
end

function Container:drawChildren()
  for i = 1, #self.children do
    if self.children[i].visible then
      self.children[i]:draw()
    end
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- this is the regular UI update that happens when elements are moved or added to the tree
-- not to be confused with timedUpdate(dt), which is called in gui.update(dt)
function Container:update()
  self:updateSize()
  self:updatePos()
  self:updateChildren()
end

function Container:updateChildren()
  for i = 1, #self.children do
    self.children[i]:update()
  end
end

function Container:timedUpdate(dt) end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


return Container



