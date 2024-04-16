local awful = require('awful')

awful.spawn.with_shell([[nmcli device disconnect wlan0]])

