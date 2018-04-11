local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Object = dep.Object

-- CANNOT REQUIRE ANY OF THE GUI ELEMENT CLASSES. WILL CAUSE CIRCULAR DEPENDENCY

local Theme = Object:extend()

function Theme:new(classtable)
  self.classtable = classtable
end

function Theme:apply(instance, args)
  -- get theme args based on instance classname
  local theme_args = self.classtable[instance.classname]
  if not theme_args then return end
  for key, value in pairs(theme_args) do
    if args[key] == nil then
      args[key] = value
    end
  end
end

return Theme