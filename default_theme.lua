-- sample theme

local _PACKAGE = (...):match("^(.+)[%./][^%./]+") or ""
local Theme = require(_PACKAGE .. "/theme")
local BasicStyleBox = require(_PACKAGE .. "/stylebox_basic")

-- -- COMMENT THE PREVIOUS THREE OUT AND UNCOMMENT THE FOLLOWING
-- -- WHEN MAKING YOUR OWN CUSTOM THEME
-- local gui = require(<path to maupassant>)
-- local Theme = gui.Theme
-- local BasicStyleBox = gui.BasicStyleBox
-- local EmptyStyleBox = gui.EmptyStyleBox
-- local NineSliceStyleBox = gui.NineSliceStyleBox
-- local SpriteStyleBox = gui.SpriteStyleBox

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--@     DEFAULT THEME
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- FONTS

local font = love.graphics.newFont(16)

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
local colors = {
  white = {255, 255, 255, 255},
  light = {200, 200, 200, 255},
  grey = {155, 173, 183, 255},
  dark = {34, 32, 52, 255},
  teal = {45, 45, 84, 255},
  blue = {91, 110, 225, 255},
  shadow = {0, 0, 0, 100},
  black = {0, 0, 0, 255},
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- PANEL STYLES

local stylebox_panel = BasicStyleBox {
  back_color = colors.teal,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,

  border_enabled = true,
  border_width = 5,
  border_color = colors.dark,

  shadow_enabled = true,
  shadow_color = colors.shadow,
  shadow_distance = 3,
  shadow_angle = math.pi / 2,
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- BUTTON STYLES

local stylebox_button = BasicStyleBox {
	back_color = colors.white,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,

  border_enabled = false,

  shadow_enabled = true,
  shadow_color = colors.grey,
  shadow_distance = 3,
  shadow_angle = math.pi / 2,
}
local stylebox_button_hover = BasicStyleBox {
  back_color = colors.white,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,

  border_enabled = true,
  border_width = 1,
  border_color = colors.blue,

  shadow_enabled = true,
  shadow_color = colors.grey,
  shadow_distance = 3,
  shadow_angle = math.pi / 2,
}
local stylebox_button_pressed = BasicStyleBox {
  back_color = colors.white,
  box_offset_x = 0,
  box_offset_y = 3,
  box_radius = 5,

  border_enabled = true,
  border_width = 1,
  border_color = colors.blue,

  shadow_enabled = false
}
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- SCROLLBOX STYLES

local stylebox_scrolldragger = BasicStyleBox {
  back_color = colors.white,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,

  border_enabled = false,
  shadow_enabled = false
}

local stylebox_scrolldragger_hover = BasicStyleBox {
  back_color = colors.white,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,

  border_enabled = true,
  border_width = 1,
  border_color = colors.blue,

  shadow_enabled = false
}

local stylebox_scrolldragger_pressed = BasicStyleBox {
  back_color = colors.grey,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,

  border_enabled = true,
  border_width = 1,
  border_color = colors.blue,

  shadow_enabled = false
}

local stylebox_scrollbar = BasicStyleBox {
  back_color = colors.dark,
  box_offset_x = 0,
  box_offset_y = 0,
  box_radius = 5,
  border_enabled = false,
  shadow_enabled = false
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- CHECKBOX STYLES

local stylebox_checkbox_on = BasicStyleBox {
  back_color = colors.blue,
  box_radius = 3,
  border_enabled = true,
  border_width = 2,
  border_color = colors.white,
  shadow_enabled = false
}

local stylebox_checkbox_off = BasicStyleBox {
  back_color = colors.black,
  box_radius = 3,
  border_enabled = true,
  border_width = 2,
  border_color = colors.white,
  shadow_enabled = false
}
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- SLIDERHEAD STYLES

local sliderhead_radius = 10

local stylebox_sliderhead = BasicStyleBox {
  back_color = colors.white,
  box_radius = sliderhead_radius,

  border_enabled = true,
  border_width = 1,
  border_color = colors.grey,

  shadow_enabled = false
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- TOGGLEBOX STYLES

local stylebox_toggle_off = BasicStyleBox {
  back_color = colors.dark,
  box_radius = sliderhead_radius,
  border_enabled = true,
  border_width = 2,
  border_color = colors.white,
  shadow_enabled = false
}

local stylebox_toggle_on = BasicStyleBox {
  back_color = colors.blue,
  box_radius = sliderhead_radius,
  border_enabled = true,
  border_width = 2,
  border_color = colors.white,
  shadow_enabled = false
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- TEXTINPUT STYLES

local stylebox_textinput = BasicStyleBox {
  back_color = colors.white,
  box_radius = 5,

  border_enabled = true,
  border_width = 1,
  border_color = colors.dark,

  shadow_enabled = false
}

local stylebox_textinput_hovered = BasicStyleBox {
  back_color = colors.white,
  box_radius = 5,

  border_enabled = true,
  border_width = 2,
  border_color = colors.blue,

  shadow_enabled = false
}

local stylebox_textinput_focused = BasicStyleBox {
  back_color = colors.light,
  box_radius = 5,

  border_enabled = true,
  border_width = 2,
  border_color = colors.blue,

  shadow_enabled = false
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- MENU STYLES

local stylebox_menu = BasicStyleBox {
  back_color = colors.dark,
  box_radius = 0,
  border_enabled = true,
  border_width = 1,
  border_color = colors.light,
  shadow_enabled = false
}

local stylebox_menu_highlighted = BasicStyleBox {
  back_color = colors.teal,
  box_radius = 0,
  border_enabled = false,
  shadow_enabled = false
}

local stylebox_menu_selected = BasicStyleBox {
  back_color = colors.blue,
  box_radius = 0,
  border_enabled = false,
  shadow_enabled = false
}


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local stylebox_tab_button = BasicStyleBox {
  back_color = colors.dark,
  box_radius = 0,
  border_enabled = true,
  border_color = colors.white,
  border_width = 1,
  shadow_enabled = false
}

local stylebox_tab_button_hovered = BasicStyleBox {
  back_color = colors.blue,
  box_radius = 0,
  border_enabled = true,
  border_color = colors.white,
  border_width = 1,
  shadow_enabled = false
}

local stylebox_tab_button_pressed = BasicStyleBox {
  back_color = colors.grey,
  box_radius = 0,
  border_enabled = true,
  border_color = colors.white,
  border_width = 1,
  shadow_enabled = false
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

local stylebox_slider_empty = BasicStyleBox {
  back_color = colors.dark,
  box_radius = 5,
  border_enabled = false,
  shadow_enabled = false
}

local stylebox_slider_filled = BasicStyleBox {
  back_color = colors.blue,
  box_radius = 5,
  border_enabled = false,
  shadow_enabled = false
}

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


return Theme {

	Container = {
    name = "container",
	},

	Panel = {
    name = "panel",
		stylebox = stylebox_panel,
    margin_x = 10,
    margin_y = 10,
	},

  Label = {
    name = "label",
    font = font,
    text_color = colors.white
  },

  Button = {
    name = "button",
    margin_x = 10,
    margin_y = 10,
    stylebox = stylebox_button,
    stylebox_unpressed = stylebox_button,
    stylebox_hovered = stylebox_button_hover,
    stylebox_pressed = stylebox_button_pressed,
    text_color = colors.dark
  },

  ScrollBox = {
    name = "scrollbox",
    stylebox_scrollbar = stylebox_scrollbar
  },

  ScrollDragger = {
    name = "scrolldragger",
    stylebox = stylebox_scrolldragger,
    stylebox_unpressed = stylebox_scrolldragger,
    stylebox_hovered = stylebox_scrolldragger_hover,
    stylebox_pressed = stylebox_scrolldragger_pressed,
  },

  CheckBox = {
    name = "checkbox",
    size_x = 20,
    size_y = 20,
    stylebox_on = stylebox_checkbox_on,
    stylebox_off = stylebox_checkbox_off,
  },

  ToggleBox = {
    name = "togglebox",
    size_x = 3.5 * sliderhead_radius,
    size_y = 2 * sliderhead_radius,
    stylebox_on = stylebox_toggle_on,
    stylebox_off = stylebox_toggle_off,
    stylebox_sliderhead = stylebox_sliderhead,
    sliderhead_width = 2 * sliderhead_radius,
    sliderhead_height = 2 * sliderhead_radius,
  },

  TextInput = {
    name = "textinput",
    stylebox_unfocused = stylebox_textinput,
    stylebox_hovered = stylebox_textinput_hovered,
    stylebox_focused = stylebox_textinput_focused,
    text_color = colors.dark,
    font = font,
    margin_left = 10
  },

  NumberInput = {
    name = "numberinput",
    stylebox_unfocused = stylebox_textinput,
    stylebox_hovered = stylebox_textinput_hovered,
    stylebox_focused = stylebox_textinput_focused,
    text_color = colors.dark,
    font = font,
    margin_left = 10
  },

  Menu = {
    name = "menu",
    stylebox = stylebox_menu,
    stylebox_highlighted = stylebox_menu_highlighted,
    stylebox_selected = stylebox_menu_selected,
    font = font,
    text_color = colors.white,
    text_color_highlighted = colors.white,
    text_color_selected = colors.white
  },

  TabButton = {
    name = "tab_button",
    stylebox = stylebox_tab_button,
    stylebox_unpressed = stylebox_tab_button,
    stylebox_hovered = stylebox_tab_button_hovered,
    stylebox_pressed = stylebox_tab_button_pressed
  },

  Tab = {
    name = "tab",
    stylebox = stylebox_tab_button,
    margin_x = 10,
    margin_y = 10,
    size_x = 1,
    size_y = 1
  },

  DropDown = {
    name = "dropdown",
    stylebox = stylebox_button,
    stylebox_unpressed = stylebox_button,
    stylebox_hovered = stylebox_button_hover,
    stylebox_pressed = stylebox_button_pressed,
    font = font,
    text_color = colors.dark,
  },

  ProgressBar = {
    name = "progressbar",
    stylebox_filled = stylebox_slider_filled,
    stylebox_empty = stylebox_slider_empty,
  },

  Slider = {
    name = "slider",
    stylebox_filled = stylebox_slider_filled,
    stylebox_empty = stylebox_slider_empty,
    size_x = 150,
    size_y = 10
  }
}

