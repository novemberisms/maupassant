local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Organizer = require(_PACKAGE .. "/organizer")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local GridOrganizer = Organizer:extend()
GridOrganizer.classname = "GridOrganizer"

-- columns
-- h_separation
-- v_separation
-- tile_size_x
-- tile_size_y

-- the grid organizer is special in that its size is determined by its children

function GridOrganizer:new(args)
  Organizer.new(self, args)
  self.columns = args.columns or 5
  self.separation_vec = Vector(args.h_separation or self.separation, args.v_separation or self.separation)

  self.tile_size = Vector(args.tile_size_x, args.tile_size_y)
  if self.tile_size == Vector(0, 0) then
    print("maupassant WARNING: GridOrganizer has no tile_size set")
  end 
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function GridOrganizer:organizeChildren()
  local base_pos = self.pos + self.margin_tl

  for i, child in ipairs(self.children) do
    -- these grid coordinates start from 0
    local grid_y_s0 = math.floor((i - 1) / self.columns)
    local grid_x_s0 = (i - 1) % self.columns
    local dest_pos = base_pos + ((self.tile_size + self.separation_vec) % Vector(grid_x_s0, grid_y_s0))
    child:move(dest_pos:split())
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


function GridOrganizer:resizeOnChildren()
  local last_child_x = self.children[self.columns]  -- get any child in the last column
  local last_child_y = self.children[#self.children] -- get any child in the last row
  if not last_child_x then last_child_x = last_child_y end
  local extent_x = last_child_x.pos.x + last_child_x.size.x + self.margin_br.x - self.pos.x
  local extent_y = last_child_y.pos.y + last_child_y.size.y + self.margin_br.y - self.pos.y
  self.size = Vector(extent_x, extent_y)
  self:update()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return GridOrganizer