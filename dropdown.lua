local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector
local Menu = require(_PACKAGE .. "/menu")

local TimedUpdateManager = require(_PACKAGE .. "/timed_update_manager")

local Button = require(_PACKAGE .. "/button")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local DropDown = Button:extend()
DropDown.classname = "DropDown"

function DropDown:new(args)
  Button.new(self, args)
  self.value = args.value or ""
  assert(args.menu, "maupassant ERROR: must supply a menu object to dropdown (" .. self.name ..")")
  self:createMenu(args.menu)
  self.canvas = love.graphics.newCanvas(self.menu.size.x, self.menu.size.y)

  self.onSelectItem = args.onSelectItem
end

function DropDown:createMenu(args_menu)
  self.menu = args_menu   -- you need to supply this yourself
  self:addChild(self.menu)
  self.menu:setVisible(false)
  self.menu.onSelectItem = function(index, item)
    self:setText(item)
    if self.onSelectItem then self.onSelectItem(index, item) end
  end
  self.menu:move(self.pos.x, self.pos.y + self.size.y)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function DropDown:setValue(value)
  self:setText(value)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function DropDown:updateSize()
  Button.updateSize(self)
  self.canvas = love.graphics.newCanvas(self.menu.size.x, self.menu.size.y)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function DropDown:pressed(button, x, y)
  self:setState("pressed")
  self.menu:setVisible(true)
end

function DropDown:releasedAnywhere()
  -- do nothing
end

function DropDown:mouseleft()
  -- do nothing
end

function DropDown:onLoseFocus()
  self:setState("unpressed")
  self.menu:setVisible(false)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
return DropDown