local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local wibox = require("wibox")

local wifi_widget = {}

local function widget_constructor()
    wifi_widget = wibox.widget {
        layout = wibox.layout.align.vertical,
        strategy = 'min',

        {
            text = "Wifi",
            padding = 20,
            widget = wibox.widget.textbox,
        },
        {
            id = "wifi_status",
            widget = wibox.widget.checkbox,
        },
        nil,
    }

    gears.timer {
        timeout = 1,
        call_now = true,
        autostart = true,
        callback = function()
            -- TODO: Use better string handling
            awful.spawn.easy_async([[sh -c 'nmcli device show wlan0 | grep GENERAL.STATE | cut -c 44-']], function(stdout, _, _, _)
                local status_widget = wifi_widget:get_children_by_id('wifi_status')[1]
                status_widget.checked = string.find(stdout, "disconnected") == nil

                status_widget:emit_signal('widget::layout_changed')
                status_widget:emit_signal('widget::redraw_needed')

            end)
        end
    }

    wifi_widget:connect_signal('button::press', function(_, _, _, _, _)
        local status_widget = wifi_widget:get_children_by_id('wifi_status')[1]

        local is_on = status_widget.checked ~= nil
        local command = is_on and [[nmcli device disconnect wlan0]] or [[nmcli device connect wlan0]]

        awful.spawn.easy_async(command, function(_, stderr, _, exit_code)
            if exit_code ~= 0 then
                naughty.notify {
                    title = "Failed to switch wifi",
                    text = "Command (" .. command .. ") exited with error message:\n" .. stderr,
                    bg = "#f80001f8",
                    ontop = true,

                }
                return
            end

            status_widget.checked = not is_on

            status_widget:emit_signal('widget::layout_changed')
            status_widget:emit_signal('widget::redraw_needed')
        end)
    end)

    return wifi_widget

end

return setmetatable(wifi_widget, { __call = function(_)
    return widget_constructor()
end})

