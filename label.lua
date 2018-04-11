local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Container = require(_PACKAGE .. "/container")

local DEFAULT_FONT = love.graphics.newFont(16)
local DEFAULT_COLOR = {34, 32, 52, 255}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Label = Container:extend()
Label.classname = "Label"

function Label:new(args)
  Container.new(self, args)
  self.font = args.font or DEFAULT_FONT
  self.raw_text = args.text
  
  self.h_align = args.h_align or "left"
  self.v_align = args.v_align or "top"
  self.colortable = {args.text_color or DEFAULT_COLOR, self.raw_text}

  self.text_obj = love.graphics.newText(self.font)

  self:updateText()

end

function Label:ready()
  if self.size.x == 0 then -- ie. not set, autofill to end of parent's container box
    self.size.x = self.parent.pos.x + self.parent.size.x - self.parent.margin_br.x - self.pos.x
  end
  self:updateText()
  if self.size.y == 0 then
    self.size.y = self.text_obj:getHeight()
  end
  self:update()
end

function Label:__set_text(text) -- replaces all colors and text with the specified one
  self.raw_text = text
  local newcolortable = {self.colortable[1], self.raw_text}
  self.colortable = newcolortable
  self:update()
end
function Label:__get_text()
  return self.raw_text
end
function Label:__set_text_color(color)
  self.colortable[1] = color
  self:update()
end
function Label:__get_text_color()
  return self.colortable[1]
end
function Label:__get_text_width() return self.text_obj:getWidth() end
function Label:__get_text_height() return self.text_obj:getHeight() end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

-- appends to the last added color
function Label:append(text)
  self.raw_text = self.raw_text .. text
  local last_text = self.colortable[#self.colortable]
  last_text = last_text .. text
  self.colortable[#self.colortable] = last_text
  self:updateText()
end

function Label:appendColor(color, text)
  self.raw_text = self.raw_text .. text
  table.insert(self.colortable, color)
  table.insert(self.colortable, text)
  self:updateText()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


function Label:updateText()
  self.text_obj:setf(self.colortable, self.size.x, self.h_align)
end

function Label:update()
  Container.update(self)
  self:updateText()
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Label:draw()
  local posx = math.floor(self.pos.x) -- text may appear blurry when drawn at non-integer locations
  -- align top
  local posy = self.pos.y -- text may appear blurry when drawn at non-integer locations
  if self.v_align == "center" then
    posy = posy + (self.size.y - self.text_height) / 2
  elseif self.v_align == "bottom" then
    posy = posy + self.size.y - self.text_height
  end
  posy = math.floor(posy)
  love.graphics.draw(self.text_obj, posx, posy)

  -- love.graphics.setColor(255,0,0,255)
  -- love.graphics.rectangle("line",self.pos.x,self.pos.y,self.size.x,self.size.y)
  -- love.graphics.setColor(255,255,255,255)

  self:drawChildren()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Label