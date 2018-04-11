local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Container = require(_PACKAGE .. "/container")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Image = Container:extend()
Image.classname = "Image"

function Image:new(args)
  Container.new(self,args)
  self.image = args.image or args.source or args.sprite
  self.quad = args.quad
  self.color = args.color or {255, 255, 255, 255}
  if self.quad then 
    self.draw = self.drawQuad 
  else
    self.draw = self.drawImage
  end
end

function Image:drawQuad()
  local qx, qy, qw, qh = self.quad:getViewport()
  love.graphics.setColor(unpack(self.color))
    love.graphics.draw(self.image, self.quad, self.pos.x, self.pos.y, 0, 
      self.size.x / qw,
      self.size.y / qh
    )
  love.graphics.setColor(255, 255, 255, 255)
  self:drawChildren()
end

function Image:drawImage()
  love.graphics.setColor(unpack(self.color))
    love.graphics.draw(self.image, self.pos.x, self.pos.y, 0,
      self.size.x / self.image:getWidth(),
      self.size.y / self.image:getHeight()
    )
  love.graphics.setColor(255, 255, 255, 255)
  self:drawChildren()
end

function Image:drawAt(x, y) -- mainly used by the menu class, but can be used anywhere really
  local oldpos = self.pos
  self.pos = Vector(x, y)
    self:draw()
  self.pos = oldpos
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Image