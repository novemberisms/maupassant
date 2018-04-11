local Cursors = {}

Cursors.normal = love.mouse.getSystemCursor("arrow")
Cursors.ibeam = love.mouse.getSystemCursor("ibeam")
Cursors.hand = love.mouse.getSystemCursor("hand")

function Cursors.setCursor(name)
  love.mouse.setCursor(Cursors[name] or Cursors.normal)
end

return Cursors