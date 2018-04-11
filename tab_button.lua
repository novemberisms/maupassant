local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Button = require(_PACKAGE .. "/button")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local TabButton = Button:extend()
TabButton.classname = "TabButton"

function TabButton:new(args)
  Button.new(self, args)
  self.tab = args.tab
  self.tab_container = args.tab_container
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TabButton:mouseovered(x, y)
  if self.state == "unpressed" then
    self:setState("hovered")
  end
  if self.onMouseOver then self.onMouseOver() end
end

function TabButton:mouseleft(x, y)
  if self.state == "hovered" then
    self:setState("unpressed")
  end
  if self.onMouseLeft then self.onMouseleft() end
end

function TabButton:pressed(button)
  self.tab_container:activateTab(self.tab.name)
  if self.onPressed then self.onPressed() end
end

function TabButton:releasedAnywhere() 
  -- override
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function TabButton:activate()
  self:setState("pressed")
end

function TabButton:deactivate()
  self:setState("unpressed")
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return TabButton