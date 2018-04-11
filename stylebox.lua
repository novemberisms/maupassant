local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local dep = require(_PACKAGE .. "/dep")
local Object = dep.Object
-- local util = require(_PACKAGE .. "/util")
-- local Vector = dep.Vector

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- used in panels and classes that inherit from panel to draw on the screen

-- there are 3 kinds:
  -- Basic: flat rectangular boxes drawn with love.graphics geometry
  -- Sprite: still images scaled according to the gui size
  -- Nineslice: dynamically-scaled 9-slice tiles

local StyleBox = Object:extend()

function StyleBox:new(args)
end
function StyleBox:updateSize(newsize)
end
function StyleBox:draw(pos, size)
end
function StyleBox:copy(new_args)
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return StyleBox