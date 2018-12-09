
local module = {}

module.DEVICE_NAME = "device_name_here"

GPIO0   =   3
GPIO1   =   10
GPIO2   =   4
GPIO3   =   9
GPIO4   =   2
GPIO5   =   1
GPIO9   =   11
GPIO10  =   12
GPIO12  =   6
GPIO13  =   7
GPIO14  =   5
GPIO15  =   8
GPIO16  =   0

function module.save_setting(name, value)
    file.open(name .. '.sav', 'w') -- you don't need to do file.remove if you use the 'w' method of writing
    file.writeline(value)
    file.close()
end

function module.load_setting(name)
    if (file.open(name .. '.sav')~=nil) then
        result = string.sub(file.readline(), 1, -2) -- to remove newline character
        file.close()
        return true, result
    else
        return false, nil
    end
end

function module.read_setting_num(name)
    res, val = module.read_setting(name)
    return res, tonumber(val)
end

module.LED_STATUS = GPIO2
module.TELNET = false

gpio.mode(module.RELAY_1, gpio.OUTPUT)
gpio.mode(module.RELAY_2, gpio.OUTPUT)
gpio.mode(module.RELAY_3, gpio.OUTPUT)
gpio.mode(module.RELAY_4, gpio.OUTPUT)

gpio.write(module.RELAY_1, 0)
gpio.write(module.RELAY_2, 0)
gpio.write(module.RELAY_3, 0)
gpio.write(module.RELAY_4, 0)

-- rtc
module.TIMEZONE = 3

-- WiFi
res, module.WIFI_SSID = module.load_setting('WIFI_SSID')
if not res then module.WIFI_SSID = 'Manuna' end
res, module.WIFI_PASS = module.load_setting('WIFI_PASS')

-- Alarms
module.WIFI_ALARM_ID = tmr.create()
module.WIFI_LED_BLINK_ALARM_ID = tmr.create()
module.WIFI_LED_CONNECTED_ALARM_ID = tmr.create()

-- MQTT
res, module.MQTT_CLIENTID = module.load_setting('MQTT_CLIENTID')
if not res then module.MQTT_CLIENTID = module.DEVICE_NAME end

res, module.MQTT_HOST = module.load_setting('MQTT_HOST')
if not res then module.MQTT_HOST = '192.168.14.32' end
module.MQTT_PORT = 1883
module.MQTT_MAINTOPIC = "/devices/" .. module.MQTT_CLIENTID

-- Confirmation message
print("\nGlobal variables loaded...\n")

return module
