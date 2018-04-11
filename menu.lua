local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""

local util = require(_PACKAGE .. "/util")
local dep = require(_PACKAGE .. "/dep")
local Vector = dep.Vector

local Input = require(_PACKAGE .. "/input")
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local Menu = Input:extend()
Menu.classname = "Menu"

local default_font = love.graphics.newFont(12)

function Menu:new(args)
  Input.new(self, args)
  self:listenMouseMoved()
  self:listenMousePressed()
  self:listenMouseReleased()

  self.font = args.font or default_font
  self.text_color = args.text_color
  self.text_color_highlighted = args.text_color_highlighted or self.text_color
  self.text_color_selected = args.text_color_selected or self.text_color

  self.item_height = args.item_height or self.font:getHeight()
  self.item_size = Vector(self.size.x - self.margin_tl.x - self.margin_br.x, self.item_height)

  self.stylebox_highlighted = self:copyStyleBox(args.stylebox_highlighted or self.stylebox)
  self.stylebox_selected = self:copyStyleBox(args.stylebox_selected or self.stylebox)

  self.onSelectItem = args.onSelectItem or self.onSelectItem

  self.h_align = args.h_align or "left"
  self.image_align = args.image_align or "left"
  self.image_distance_from_text = args.image_distance_from_text or 10
  self.show_text = util.tern(args.show_text == nil, true, args.show_text)

  self.highlighted_index = -1
  self.selected_index = -1

  self.items = {}
  self.images = {}  -- can be a sparse table since not all items need to have an image
                    -- these images MUST be of type gui.Image
  for _, item in ipairs(args.items) do
    if type(item) == "table" then
      if item[2] and not (item[2].classname == "Image") then
        error("maupassant ERROR: images supplied to menu must be maupassant Images (" .. self.name .. ")")
      end
      self:addItem(item[1], item[2])    -- table with {"item name", image}
    else
      self:addItem(item)   -- just a string
    end
  end
end

function Menu:__get_value()
  return self:getValue()
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Menu.onSelectItem(index, item_name, image) end

function Menu:getValue()
  if self.selected_index == -1 then return nil, nil, nil end
  return self.selected_index, self.items[self.selected_index], self.images[self.selected_index]
end

function Menu:addItem(item, image)
  local last_index = #self.items
  self.items[last_index + 1] = item
  self.images[last_index + 1] = image
end

function Menu:getItemIndexUnder(x, y)
  if not self:isMouseOvered() then return -1 end
  local offset = Vector(x, y) - (self.pos + self.margin_tl)
  -- check if it is in the margins
  if offset.x < 0 then return -1 end
  if offset.y < 0 then return -1 end
  if offset.x > self.item_size.x then return -1 end
  if offset.y > self.size.y - self.margin_br.y - self.margin_br.y then return -1 end

  local index = math.ceil(offset.y / self.item_height)
  if index > #self.items then return -1 end
  return index
end

function Menu:copyStyleBox(stylebox)
  if not stylebox.size then return stylebox end
  local copy = stylebox:copy {
    size_x = self.item_size.x,
    size_y = self.item_size.y
  }
  copy:updateSize(self.item_size)
  return copy
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Menu:updateSize()
  Input.updateSize(self)
  self.item_size = Vector(self.size.x - self.margin_tl.x - self.margin_br.x, self.item_height)
  self.stylebox_highlighted:updateSize(self.item_size)
  self.stylebox_selected:updateSize(self.item_size)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Menu:mousemoved(x, y, dx, dy)
  Input.mousemoved(self, x, y, dx, dy)
  self.highlighted_index = self:getItemIndexUnder(x, y)
end

function Menu:pressed(button, x, y)
  if self.highlighted_index < 1 then return end
  self.selected_index = self:getItemIndexUnder(x, y)
  self.onSelectItem(self:getValue())
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

function Menu:draw()
  self.stylebox:draw(self.pos, self.size)
  self:drawItems()
  self:drawChildren()
end

function Menu:drawItems()
  local current_pos = self.pos + self.margin_tl
  local text_pos = Vector(current_pos.x, current_pos.y + (self.item_size.y - self.font:getHeight()) / 2) 
  local oldfont = love.graphics.getFont()

  love.graphics.setFont(self.font)

    for i = 1, #self.items do
      local color = self.text_color
      -- draw stylebox for selected and highlighted items
      if i == self.selected_index then
        self.stylebox_selected:draw(current_pos, self.item_size)
        color = self.text_color_selected
      elseif i == self.highlighted_index then
        self.stylebox_highlighted:draw(current_pos, self.item_size)
        color = self.text_color_highlighted
      end

      local text_start = text_pos.x -- for use with images
      local image = self.images[i]
      if image then
        local image_x = current_pos.x
        local image_y = current_pos.y + (self.item_size.y - image.size.y) / 2
        if self.image_align == "left" then
          text_start = text_start + image.size.x + self.image_distance_from_text
        elseif self.image_align == "right" then
          image_x = current_pos.x + self.item_size.x - image.size.x
        elseif self.image_align == "center" then
          image_x = current_pos.x + (self.item_size.x - image.size.x) / 2
        end
        image:drawAt(image_x, image_y)
      end
      -- draw text
      love.graphics.printf({color, self.items[i]}, text_start, text_pos.y, self.item_size.x, self.h_align)
      -- update current_pos and text_pos
      current_pos.y = current_pos.y + self.item_size.y
      text_pos.y = text_pos.y + self.item_size.y
    end

  love.graphics.setFont(oldfont)
end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

return Menu