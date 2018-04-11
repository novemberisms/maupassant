local Object = {}
Object.__index = Object

Object.name = "Object"

function Object:new()
end

function Object:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = function(t,k)
    if rawget(cls,"__get_"..k) then return cls["__get_"..k](t) end
    return cls[k]
  end
  cls.__newindex = function(t,k,v)
    if rawget(cls,"__set_"..k) then return cls["__set_"..k](t,v) end
    rawset(t, k, v)
  end
  cls.super = self
  setmetatable(cls, self)
  return cls
end


function Object:implement(...)
  for _, cls in pairs({...}) do
    for k, v in pairs(cls) do
      if self[k] == nil and type(v) == "function" then
        self[k] = v
      end
    end
  end
end


function Object:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end


function Object:__tostring()
  return self.name
end


function Object:__call(...)
  local obj = setmetatable({}, self)
  obj:new(...)
  return obj
end

return Object