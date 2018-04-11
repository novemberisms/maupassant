_PACKAGE = (...):match "^(.+)[%./][^%./]+" or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Button = require(_PACKAGE .. "/button")
local Input = require(_PACKAGE .. "/input")

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Slider = Input:extend()
Slider.classname = "Slider"

function Slider:new(args)
  Input.new(self, args)

  self:listenMousePressed()
  self:listenMouseMoved()

  self.onReleased = args.onReleased
  self.onDragged = args.onDragged

  self.stylebox_filled = args.stylebox_filled or self.stylebox
  self.stylebox_empty = args.stylebox_empty or self.stylebox

  self.min_value = args.min_value or 0
  self.max_value = args.max_value or 100

  self._value = args.value or 50

  self.sliderhead = args.sliderhead or self:createSliderhead(args)
  self:addChild(self.sliderhead)
  self:moveSliderHeadToValue()
end

function Slider:__get_value()
  return self._value
end
function Slider:__get_ratio()
  return (self.value - self.min_value) / (self.max_value - self.min_value)
end
function Slider:__get_percent()
  return 100 * self.ratio
end

function Slider:__set_value(v)
  self._value = v
  self:moveSliderHeadToValue()
end
function Slider:__set_ratio(r)
  self.value = self.min_value + r * (self.max_value - self.min_value)
end
function Slider:__set_percent(p)
  self.ratio = p / 100
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- own callbacks
function Slider:pressed(button, x, y)
  self.sliderhead.x = x - self.sliderhead.size.x / 2
  self:setValueOnHead()
  if self.onReleased then self.onReleased() end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- Sliderhead stuff

function Slider:ready()
  Input.ready(self)
  self.sliderhead:ready()
end

function Slider:createSliderhead(args)
  local sliderhead = Button {
    name = "sliderhead",
    size_x = args.sliderhead_size_x or self.size.y,
    size_y = args.sliderhead_size_y or self.size.y,
    stylebox = args.sliderhead_stylebox_unpressed,
    stylebox_unpressed = args.sliderhead_stylebox_unpressed,
    stylebox_pressed = args.sliderhead_stylebox_pressed,
    stylebox_hovered = args.sliderhead_stylebox_hovered
  }

  sliderhead.pressed = self.onSliderHeadPressed
  sliderhead.releasedAnywhere = self.onSliderHeadReleasedAnywhere
  sliderhead.mousedragged = self.onSliderHeadDragged
  sliderhead.slider = self

  return sliderhead
end

function Slider:moveSliderHeadToValue()
  local dist = self.ratio * (self.size.x - self.sliderhead.size.x)
  self.sliderhead:move(
    self.pos.x + dist,
    self.pos.y + (self.size.y - self.sliderhead.size.y) / 2
  )
end

function Slider:setValueOnHead()
  -- we use @_value because we don't want to trigger the setter
  -- which will move the slider head again
  local dist = self.sliderhead.pos.x - self.pos.x
  local max_dist = self.size.x - self.sliderhead.size.x

  self.value = self.min_value + (dist / max_dist) * (self.max_value - self.min_value)
end

-- callbacks

function Slider.onSliderHeadPressed(head, button, x, y)
  head:setState("pressed")
  head.grablocation = Vector(x, y) - head.pos
end
function Slider.onSliderHeadReleasedAnywhere(head)
  if head.flags.MOUSEOVERED then
    head:setState("hovered")
  else
    head:setState("unpressed")
  end
  head.grablocation = nil
  if head.slider.onReleased then head.slider.onReleased() end
end
function Slider.onSliderHeadDragged(head, x, y)
  head.x = x - head.grablocation.x
  local slider = head.slider
  local distance_from_left = head.pos.x - slider.pos.x
  local max_distance_from_left = slider.size.x - head.size.x

  if distance_from_left < 0 then
    head.x = slider.pos.x
    distance_from_left = 0
  elseif distance_from_left > max_distance_from_left then
    head.x = slider.pos.x + max_distance_from_left
    distance_from_left = max_distance_from_left
  end

  slider:setValueOnHead()

  if slider.onDragged then slider.onDragged() end
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- draw stuff

function Slider:draw()
  local filled_size = Vector(self.ratio * self.size.x, self.size.y)
  self.stylebox_empty:draw(self.pos, self.size)
  if self._value > self.min_value then
    self.stylebox_filled:draw(self.pos, filled_size)
  end
  self:drawChildren()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Slider