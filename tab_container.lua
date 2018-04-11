local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Organizer = require(_PACKAGE .. "/organizer")
local TabButton = require(_PACKAGE .. "/tab_button")
local Button = require(_PACKAGE .. "/button")

local Container = require(_PACKAGE .. "/container")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local TabContainer = Container:extend()
TabContainer.classname = "TabContainer"

function TabContainer:new(args)
  Container.new(self, args)

  self.margin_tl = Vector() -- margins are ignored!
  self.margin_br = Vector()

  self.header_autofill = args.header_autofill or false
  self.header_height = args.header_height or 20   -- no matter where the header is, this is the same
  self.header_width = args.header_width or 100
  self.header_location = args.header_location or "top" -- can either be top, left, bottom, or right
  self.header_separation = args.header_separation or 0

  self.init_active_tab = util.tern(args.init_active_tab == nil, true, args.init_active_tab)

  self.header_size = self:getHeaderSize()

  self.headers = {}   -- contains the buttons to go to each tab
  self.tabs = {}

  self:createHeaders()
end

function TabContainer:ready()
  for _, child in ipairs(self.children) do
    if child.classname == "Tab" then
      child.size = self:getContentSize().copy
      child.original_size = child.size.copy
      child.anchor = self:getContentAnchor().copy
      child:setVisible(false)
      child:update()
    end
  end
  if self.init_active_tab then
    for _, child in ipairs(self.children) do
      if child.classname == "Tab" then
        self:activateTab(child.name)
        return
      end
    end
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TabContainer:hideAllTabs()
  for _, child in ipairs(self.children) do
    if child.classname == "Tab" then
      child:setVisible(false)
    end
  end
  for _, header in ipairs(self.headers) do
    header:deactivate()
  end
end

function TabContainer:activateTab(tab_name)
  self:hideAllTabs()
  local tab_to_activate = self:getTabByName(tab_name)
  local header_to_activate = self:getHeaderByTabName(tab_name)
  tab_to_activate:setVisible(true)
  header_to_activate:activate()
end

function TabContainer:getTabByName(tab_name)
  for _, child in ipairs(self.children) do
    if (child.classname == "Tab") and (child.name == tab_name) then
      return child
    end
  end
end

function TabContainer:getHeaderByTabName(tab_name)
  for _, header in ipairs(self.headers) do
    if header.tab.name == tab_name then
      return header
    end
  end
end

function TabContainer:getActiveTab()
  for _, child in ipairs(self.children) do
    if (child.classname == "Tab") and (child.visible == true) then
      return child
    end
  end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TabContainer:createHeaders()
  local header_organizer = self:createHeaderOrganizer()
  -- add buttons to the organizer
  for _, child in ipairs(self.children) do
    if child.classname == "Tab" then
      local header = header_organizer:addChild( TabButton {
        name = child.name .. "_header",
        size_x = self.header_width,
        size_y = self.header_height,
        text = child.header_name,
        tab = child,
        scale_x_with_parent = true,
        scale_y_with_parent = true,
        tab_container = self
      })
      table.insert(self.headers, header)
    end
  end
end

function TabContainer:createHeaderOrganizer()
  -- create organizer child
  local organizer_mode = "horizontal"
  local anchor_x = 0
  local anchor_y = 0
  local size_x, size_y = self.header_size:split()

  if self.header_location == "top" then
  elseif self.header_location == "bottom" then
    anchor_y = 1
  elseif self.header_location == "left" then
    organizer_mode = "vertical"
  elseif self.header_location == "right" then
    organizer_mode = "vertical"
    anchor_x = 1
  end

  local header_organizer = Organizer {
    name = "header_organizer",
    mode = organizer_mode,
    separation = self.header_separation,
    anchor_x = anchor_x,
    anchor_y = anchor_y,
    size_x = size_x,
    size_y = size_y,
    scale_x_with_parent = true,
    scale_y_with_parent = true,
  }

  self:addChild(header_organizer)
  return header_organizer
end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TabContainer:getHeaderSize()
  local size_x
  local size_y

  if self.header_location == "top" then
    size_x = self.size.x
    size_y = self.header_height
  elseif self.header_location == "bottom" then
    size_x = self.size.x
    size_y = self.header_height
  elseif self.header_location == "left" then
    size_x = self.header_width
    size_y = self.size.y
  elseif self.header_location == "right" then
    size_x = self.header_width
    size_y = self.size.y
  end

  return Vector(size_x, size_y)
end

function TabContainer:getContentSize()
  if self.header_location == "top" then
    return self.size - Vector(0, self.header_size.y)
  elseif self.header_location == "bottom" then
    return self.size - Vector(0, self.header_size.y)
  elseif self.header_location == "left" then
    return self.size - Vector(self.header_size.x, 0)
  elseif self.header_location == "right" then
    return self.size - Vector(self.header_size.x, 0)
  end
  error("maupassant ERROR: invalid header location (" .. self.name .. ")")
end

function TabContainer:getContentAnchor()
  if self.header_location == "top" then
    return Vector(0, 1)
  elseif self.header_location == "bottom" then
    return Vector(0, 0)
  elseif self.header_location == "left" then
    return Vector(1, 0)
  elseif self.header_location == "right" then
    return Vector(0, 0)
  end
  error("maupassant ERROR: invalid header location (" .. self.name .. ")")
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TabContainer:draw()
  util.debugrect(self.pos.x, self.pos.y, self.size.x, self.size.y)
  Container.draw(self)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return TabContainer