local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local StyleBox = require(_PACKAGE .. "/stylebox")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local NineSliceStyleBox = StyleBox:extend()

function NineSliceStyleBox:new(args)
  self.sprite = args.sprite
  self.slices = self:create9Slice(self.sprite, args.vcut1, args.vcut2, args.hcut1, args.hcut2)

  local init_size = Vector(args.size_x, args.size_y)
  self.size = init_size

  self.batch = love.graphics.newSpriteBatch(self.sprite, self:estimateMaxSprites(init_size), "static")

  self.args = args
end

function NineSliceStyleBox:copy(newargs) 
  local args = util.copyTable(self.args)
  for k,v in pairs(newargs or {}) do args[k] = v end
  local copy = NineSliceStyleBox(args)
  return copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NineSliceStyleBox:create9Slice(sprite, vcut1, vcut2, hcut1, hcut2)
  -- 9 slices are made with 4 cuts: 2 vertical, and 2 horizontal 
  -- the position of the vertical slices are vcut1 and vcut2, from left to right
  -- the position of the horizontal slices are hcut1 and hcut2, from top to bottom 
  if not sprite then return {} end
  -- get the sprite's total dimensions
  local dx, dy = sprite:getDimensions()
  -- if no cuts are given, then assume divide into equal areas
  local vcut1 = vcut1 or math.floor(dx / 3)
  local vcut2 = vcut2 or math.floor(2 * dx / 3)
  local hcut1 = hcut1 or math.floor(dy / 3)
  local hcut2 = hcut2 or math.floor(2 * dy / 3)
  -- get the widths of the columns
  local w1 = vcut1
  local w2 = vcut2 - vcut1
  local w3 = dx - vcut2
  -- get the heights of the rows
  local h1 = hcut1
  local h2 = hcut2 - hcut1
  local h3 = dy - hcut2

  -- get the quads in a table
  local slices = {}

  slices.top_left   = love.graphics.newQuad(0,      0,      w1, h1, dx, dy)
  slices.top_mid    = love.graphics.newQuad(vcut1,  0,      w2, h1, dx, dy)
  slices.top_right  = love.graphics.newQuad(vcut2,  0,      w3, h1, dx, dy)

  slices.mid_left   = love.graphics.newQuad(0,      hcut1,  w1, h2, dx, dy)
  slices.mid_mid    = love.graphics.newQuad(vcut1,  hcut1,  w2, h2, dx, dy)
  slices.mid_right  = love.graphics.newQuad(vcut2,  hcut1,  w3, h2, dx, dy)

  slices.bot_left   = love.graphics.newQuad(0,      hcut2,  w1, h3, dx, dy)
  slices.bot_mid    = love.graphics.newQuad(vcut1,  hcut2,  w2, h3, dx, dy)
  slices.bot_right  = love.graphics.newQuad(vcut2,  hcut2,  w3, h3, dx, dy)

  -- we need to have a copy of these dimensions for drawing later
  slices.w1 = w1
  slices.w2 = w2
  slices.w3 = w3
  slices.h1 = h1
  slices.h2 = h2
  slices.h3 = h3

  return slices
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NineSliceStyleBox:createBatch(size)
  self.batch:clear()
  local slices = self.slices
  -- add the four corners first, unscaled and untiled
  self.batch:add( slices.bot_right,
    size.x - slices.w3, size.y - slices.h3,
    0, 1, 1
  )
  self.batch:add( slices.bot_left,
    0, size.y - slices.h3,
    0, 1, 1
  )
  self.batch:add( slices.top_right, 
    size.x - slices.w3, 0,
    0, 1, 1
  )
  self.batch:add( slices.top_left, 
    0, 0,
    0, 1, 1
  )
  -- how many divisions along the middle do we need?
  local midwidth = size.x - slices.w1 - slices.w3
  local midheight = size.y - slices.h1 - slices.h3

  local grid_w = math.max(1, util.round(midwidth / slices.w2))
  local grid_h = math.max(1, util.round(midheight / slices.h2))

  local tile_w = midwidth / grid_w
  local tile_h = midheight / grid_h

  -- fill in the middle
  for gy = 0, grid_h - 1 do
    local posy = slices.h1 + gy * tile_h
    for gx = 0, grid_w - 1 do
      local posx = slices.w1 + gx * tile_w
      self.batch:add( slices.mid_mid,
        posx, posy, 0,
        tile_w / slices.w2,
        tile_h / slices.h2
      )
    end
  end
  -- fill in the top edge
  for gx = 0, grid_w - 1 do
    local posx = slices.w1 + gx * tile_w
    self.batch:add( slices.top_mid,
      posx, 0, 0,
      tile_w / slices.w2,
      1
    )
  end
  -- fill in the bottom edge
  for gx = 0, grid_w - 1 do
    local posx = slices.w1 + gx * tile_w
    self.batch:add( slices.bot_mid,
      posx, size.y - slices.h3, 0,
      tile_w / slices.w2,
      1
    )
  end
  -- fill in the left edge
  for gy = 0, grid_h - 1 do
    local posy = slices.h1 + gy * tile_h
    self.batch:add( slices.mid_left,
      0, posy, 0,
      1,
      tile_h / slices.h2
    )
  end
  -- fill in the right edge
  for gy = 0, grid_h - 1 do
    local posy = slices.h1 + gy * tile_h
    self.batch:add( slices.mid_right,
      size.x - slices.w3, posy, 0,
      1,
      tile_h / slices.h2
    )
  end

end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NineSliceStyleBox:estimateMaxSprites(size)
  local panel_area = size.x * size.y
  local sprite_area = self.sprite:getWidth() * self.sprite:getHeight()
  return math.ceil(9 * panel_area / sprite_area) + 25 -- for good measure
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NineSliceStyleBox:updateSize(newsize)
  self.batch:setBufferSize(self:estimateMaxSprites(newsize))
  self:createBatch(newsize)
  self.size = newsize.copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function NineSliceStyleBox:draw(pos, size)
  love.graphics.draw(self.batch, pos.x, pos.y)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return NineSliceStyleBox