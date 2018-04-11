local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local StyleBox = require(_PACKAGE .. "/stylebox")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local SpriteStyleBox = StyleBox:extend()

function SpriteStyleBox:new(args)
  self.sprite = args.sprite
  self.size = Vector(
    args.size_x or self.sprite:getWidth(), 
    args.size_y or self.sprite:getHeight()
  )
  self.image_size = Vector(self.sprite:getDimensions())
  self.quad = args.quad
  self.args = args

  if self.quad then self.draw = self.drawQuad end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function SpriteStyleBox:updateSize(newsize)
  self.size = newsize.copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function SpriteStyleBox:copy(newargs) 
  local args = util.copyTable(self.args)
  for k,v in pairs(newargs or {}) do args[k] = v end
  local copy = SpriteStyleBox(args)
  return copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function SpriteStyleBox:draw(pos, size)
  love.graphics.draw(
    self.sprite, 
    pos.x, pos.y, 
    0, 
    self.size.x / self.sprite:getWidth(), 
    self.size.y / self.sprite:getHeight()
  )
end

function SpriteStyleBox:drawQuad(pos, size)
  local x, y, w, h = self.quad:getViewport()
  love.graphics.draw(
    self.sprite, 
    self.quad,
    pos.x, pos.y, 
    0, 
    self.size.x / w, 
    self.size.y / h
  )
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
return SpriteStyleBox