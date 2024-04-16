local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')

local brightness_widget = {}

local function widget_constructor()
    brightness_widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        {
            text = '\u{f185}',
            widget = wibox.widget.textbox,
        },
        {
            id = 'brightness',
            text = 'test',
            margin = 30,
            widget = wibox.widget.textbox,
        },
    }
    gears.timer {
        timeout = 1,
        call_now = true,
        autostart = true,
        callback = function()
            awful.spawn.easy_async([[brightnessctl g]], function(stdout, _, _, _)
                local percent = tonumber(stdout) // 1200
                local widget = brightness_widget:get_children_by_id('brightness')[1]
                widget.text = percent .. '%'

                brightness_widget:emit_signal('widget::layout_changed')
                brightness_widget:emit_signal('widget::redraw_needed')

            end)
        end
    }
    return brightness_widget
end

return setmetatable(brightness_widget, { __call = function()
    return widget_constructor()
end})


