local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Label = require(_PACKAGE .. "/label")
local Input = require(_PACKAGE .. "/input")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Button = Input:extend()
Button.classname = "Button"

function Button:new(args)
  Input.new(self, args)
  self:listenMouseMoved()
  self:listenMousePressed()
  self:listenMouseReleased()
  -- useful callbacks
  self.onMouseOver = args.onMouseOver
  self.onMouseLeft = args.onMouseLeft
  self.onPressed = args.onPressed
  self.onReleased = args.onReleased
  self.onDragged = args.onDragged
  self.onDragReleased = args.onDragReleased
  -- styleboxes and state
  self.state = "unpressed"  -- "hovered", pressed", "disabled"
  self.stylebox_unpressed = args.stylebox or args.stylebox_unpressed
  self.stylebox_hovered = args.stylebox_hovered or self.stylebox_unpressed
  self.stylebox_pressed = args.stylebox_pressed or self.stylebox_unpressed
  self.stylebox_disabled = args.stylebox_disabled or self.stylebox_unpressed

  self:setStyleBoxNoUpdate(self.stylebox_unpressed)

  -- there are two ways to add text to a button:
    -- add a label in the button as a child: provides all the flexibility of labels (color change, alignment, etc)
    -- use the text property in the button (not as flexible, but allows not having to manage the anchors and sizes manually)
 
  self.text_color = args.text_color
  self:setText(args.text)
end

function Button:__get_text()
  if self.__label then 
    return self.__label.text 
  else
    return ""
  end
end
function Button:__set_text(text)
  self:setText(text)
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Button:setText(text)
  if not text then return end
  if not self.__label then
    local label_size = self.size - self.margin_tl - self.margin_br
    self.__label = self:addChild(Label {
      name = "button label",
      text = text,
      text_color = self.text_color,
      anchor_x = 0.5,
      anchor_y = 0.5,
      size_x = label_size.x,
      size_y = label_size.y,
      h_align = "center",
      v_align = "center"
    })
  else
    self.__label.text = text
  end
end

function Button:setState(state)
  self.state = state
  self:setStyleBox(self["stylebox_" .. state])
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Button:mouseovered(x, y)
  self:setState("hovered")
  if self.onMouseOver then self:onMouseOver(x, y) end
end

function Button:mouseleft(x, y)
  if not self.flags.DRAGGED then
    self:setState("unpressed")
  end
  if self.onMouseLeft then self:onMouseLeft(x, y) end
end

function Button:pressed(button, x, y)
  self:setState("pressed")
  if self.onPressed then self:onPressed(button, x, y) end
end

function Button:releasedAnywhere(button, x, y)
  if self.flags.MOUSEOVERED then
    self:setState("hovered")
    if self.onReleased then self:onReleased(button, x, y) end
  else
    self:setState("unpressed")
  end
end

function Button:mousedragged(x, y, dx, dy)
  if self.onDragged then self:onDragged(x, y, dx, dy) end
end

function Button:dragReleased(button, x, y)
  if self.onDragReleased then self:onDragReleased(button, x, y) end
end
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Button:draw()
  self.stylebox:draw(self.pos, self.size)
  self:drawChildren()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Button