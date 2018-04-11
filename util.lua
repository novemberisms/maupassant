local util = {}

function util.tern(condition, if_true, if_false)
  if condition then
    return if_true
  else
    return if_false
  end
end

function util.round(value)  -- only works on positive numbers!
  return math.fmod(value, 1.0) < 0.5 and math.floor(value) or math.ceil(value)
end

function util.has(table, value)
  for _,v in pairs(table) do
    if v == value then return true end
  end
  return false
end

function util.copyTable(table, exclude_types, created_tables)
  local copy = {}
  local exclude_types = exclude_types or {}
  local created_tables = created_tables or {}

  for k, v in pairs(table) do
    if util.has(exclude_types, type(v)) then
      goto continue
    end
    if type(v) == "table" then
      if created_tables[v] then
        copy[k] = created_tables[v]
      elseif v == table then
        copy[k] = copy
        created_tables[v] = copy
      else
        copy[k] = util.copyTable(v, exclude_types, created_tables)
        if getmetatable(v) then
          setmetatable(copy[k], getmetatable(v))
        end
        created_tables[v] = copy[k]
      end
    else
      copy[k] = v
    end
    ::continue::
  end

  return copy
end

function util.debugrect(x, y, w, h, color)
  local color = color or {255, 0, 0, 255}
  love.graphics.setColor(unpack(color))
  love.graphics.rectangle("line", x, y, w, h)
  love.graphics.setColor(255, 255, 255, 255)
end

function util.nop() end

function util.hasNaN(vector)
  if vector.x ~= vector.x then return true end
  if vector.y ~= vector.y then return true end
  return false
end

function util.removeNaN(vector)
  if vector.x ~= vector.x then vector.x = 0 end
  if vector.y ~= vector.y then vector.y = 0 end
end

function util.signvec(vector)
  if vector.x < 0 then vector.x = -1 end
  if vector.x > 0 then vector.x = 1 end
  if vector.y < 0 then vector.y = -1 end
  if vector.y > 0 then vector.y = 1 end
end

return util