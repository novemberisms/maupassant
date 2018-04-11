local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Container = require(_PACKAGE .. "/container")

local ScrollDragger = require(_PACKAGE .. "/scrolldragger")
local Panel = require(_PACKAGE .. "/panel")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local ScrollBox = Container:extend()
ScrollBox.classname = "ScrollBox"

function ScrollBox:new(args)
  Container.new(self, args)

  self.canvas_size = self.size - self.margin_tl - self.margin_br
  self.canvas = love.graphics.newCanvas(self.canvas_size:split())
  self.camera_offset = Vector()

  self.scrollbar_width = args.scrollbar_width or 10

  self.v_scrolldragger = args.v_scrolldragger or ScrollDragger {
    name = "__v_scrolldragger",
    parent = self,
    orientation = "vertical",
    size_x = self.scrollbar_width,
    size_y = 100,
    anchor_x = 1,
    anchor_y = 0,
    visible = false
  }
  self.h_scrolldragger = args.h_scrolldragger or ScrollDragger {
    name = "__h_scrolldragger",
    parent = self,
    orientation = "horizontal",
    size_x = 100,
    size_y = self.scrollbar_width,
    anchor_x = 0,
    anchor_y = 1,
    visible = false
  }
  self.v_scrollbar = args.v_scrollbar or Panel {
    name = "__v_scrollbar",
    size_x = self.scrollbar_width,
    size_y = self.canvas_size.y - self.scrollbar_width,
    anchor_x = 1,
    anchor_y = 0,
    visible = false,
    stylebox = args.stylebox_scrollbar,
    parent = self
  }
  self.h_scrollbar = args.h_scrollbar or Panel {
    name = "__h_scrollbar",
    size_x = self.canvas_size.x - self.scrollbar_width,
    size_y = self.scrollbar_width,
    anchor_x = 0,
    anchor_y = 1,
    visible = false,
    stylebox = args.stylebox_scrollbar,
    parent = self
  }

  -- self.camera_limit -> set by updateLimit()
  self:updateLimit()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ScrollBox:ready()
  self:checkForNestedScrollBox()
  self:tagDescendants(self)
end

function ScrollBox:checkForNestedScrollBox()
  local curr_ancestor = self.parent
  while curr_ancestor do
    if curr_ancestor.classname == "ScrollBox" then
      error("maupassant ERROR: no nested scrollboxes allowed (" .. self.name .. ")")
    end
    curr_ancestor = curr_ancestor.parent
  end
  return false
end

function ScrollBox:tagDescendants(element)
  for _,child in ipairs(element.children) do  
    child.flags.IS_WITHIN_SCROLLBOX = true
    child.__ANCESTOR_SCROLLBOX = self
    self:tagDescendants(child)
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function ScrollBox:isPointWithinCanvas(x, y)
  if not self.visible then return false end
  if self.v_scrolldragger:isPointWithinSelf(x, y) then return false end
  if self.h_scrolldragger:isPointWithinSelf(x, y) then return false end
  local hit_tl = self.pos + self.margin_tl
  local hit_br = hit_tl + self.canvas_size
  if x < hit_tl.x then return false end
  if y < hit_tl.y then return false end
  if x >= hit_br.x then return false end  -- the >= ensures that if hitbox size is 0 then no detection
  if y >= hit_br.y then return false end
  return true
end

function ScrollBox:transformScreenPoint(x, y)
  -- transforms a point on the screen into the canvas world
  -- this assumes that the point is already inside the canvas screen
  local trans = Vector(x, y)  + self.camera_offset
  return trans.x, trans.y
end

function ScrollBox:getMaxCameraOffset()
  return self.camera_limit - self.canvas_size - self.pos
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function ScrollBox:updateSize()
  Container.updateSize(self)
  self:resizeCanvas()
  self:resizeScrollbars()

end

function ScrollBox:resizeScrollbars()
  self.v_scrollbar.size_y = self.canvas_size.y - self.scrollbar_width
  self.h_scrollbar.size_x = self.canvas_size.x - self.scrollbar_width
end

function ScrollBox:resizeCanvas()
  self.canvas_size = self.size - self.margin_tl - self.margin_br
  self.canvas = love.graphics.newCanvas(self.canvas_size:split())
end

function ScrollBox:resizeScrollDraggers()
  local camera_limit_size = self.camera_limit - self.pos
  local dragger_ratios = (self.canvas_size % camera_limit_size.inverse)
  self.v_scrolldragger.size_y = self.v_scrollbar.size.y * dragger_ratios.y
  self.h_scrolldragger.size_x = self.h_scrollbar.size.x * dragger_ratios.x
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ScrollBox:update()
  Container.update(self)    -- calls updateSize, updatePos, and updateChildren
  self:updateLimit()
  self:updateScrollBars()
  self:checkForNestedScrollBox()
  self:tagDescendants(self)
end

function ScrollBox:updateLimit()
  -- updates the camera bounds and also updates the size of the scrolldraggers
  local furthest_x = 0
  local furthest_y = 0
  for _, child in ipairs(self.children) do
    local extent = child.pos + child.size
    furthest_x = math.max(extent.x, furthest_x)
    furthest_y = math.max(extent.y, furthest_y)
  end
  self.camera_limit = Vector(furthest_x, furthest_y) + Vector(self.scrollbar_width, self.scrollbar_width)

  -- do either of the scrolldraggers need to be visible?

  local camera_limit_size = self.camera_limit - self.pos
  if camera_limit_size.x <= self.canvas_size.x then
    -- hide horizontal screendragger
    self.h_scrollbar.visible = false
    self.h_scrolldragger.visible = false
  else
    -- show horizontal screendragger
    self.h_scrollbar.visible = true
    self.h_scrolldragger.visible = true
  end
  if camera_limit_size.y <= self.canvas_size.y then
    -- hide vertical screendragger
    self.v_scrollbar.visible = false
    self.v_scrolldragger.visible = false
  else
    -- show vertical screendragger
    self.v_scrollbar.visible = true
    self.v_scrolldragger.visible = true
  end

  self:resizeScrollDraggers()
end

function ScrollBox:updateScrollBars()
  self.h_scrollbar:update()
  self.v_scrollbar:update()
  self.h_scrolldragger:update()
  self.v_scrolldragger:update()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function ScrollBox:draw()
  local drawpos = self.pos + self.margin_tl
  self.canvas:renderTo(function()
    love.graphics.clear()
    love.graphics.push()
      local translate_pos = -(drawpos + self.camera_offset)
      love.graphics.translate(translate_pos:split())
        self:drawChildren()
    love.graphics.pop()
  end)
  love.graphics.draw(self.canvas, drawpos.x, drawpos.y)
  self:drawScrollbars()
end

function ScrollBox:drawScrollbars()
  if self.h_scrollbar.visible then
    self.h_scrollbar:draw()
    self.h_scrolldragger:draw()
  end
  if self.v_scrollbar.visible then
    self.v_scrollbar:draw()
    self.v_scrolldragger:draw()
  end
end





--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return ScrollBox