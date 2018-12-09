
local module = {}

local wifiReady = 0
local firstPass = 0
local ledOn = false
local wifiBlinkCounter = 0


local function turnWiFiLedOn()
    gpio.write(config.LED_STATUS, gpio.LOW)
    ledOn = true
end

local function turnWiFiLedOff()
    gpio.write(config.LED_STATUS, gpio.HIGH)
    ledOn = false
end

local function turnWiFiLedOnOff()
--    tmr.alarm(WIFI_LED_BLINK_ALARM_ID, 200, 0, function()
        if ledOn then
            turnWiFiLedOff()
        else
            turnWiFiLedOn()
        end
--    end)
end

local function signalWiFiConnected()
    if wifiBlinkCounter >= 6 then
        return
    end
    if ledOn then
        turnWiFiLedOff()
    else
        turnWiFiLedOn()
    end
    wifiBlinkCounter = wifiBlinkCounter + 1
    tmr.alarm(config.WIFI_LED_CONNECTED_ALARM_ID, 200, 0, signalWiFiConnected)
end

local function after_network_connected()
    -- load_lib("ota")
    if config.TELNET then 
        load_lib("telnet") 
    else
        load_lib("ota")
    end

    -- mqttc = require("mqtt_client")
    rtc = require("rtc_sync")
    rtc.sync()
    -- mqttc.start()
end

local function wifi_watch() 
    local status = wifi.sta.status()
    -- only do something if the status actually changed (5: STATION_GOT_IP.)
    if status == 5 and wifiReady == 0 then
        wifiReady = 1
        print("WiFi: connected with " .. wifi.sta.getip())
--        load_lib("broker")
    elseif status == 5 and wifiReady == 1 then
        if firstPass == 0 then
            firstPass = 1

            after_network_connected()

            tmr.stop(config.WIFI_LED_BLINK_ALARM_ID)
            turnWiFiLedOff()
            wifiBlinkCounter = 0
            signalWiFiConnected()
        end
    else
        if wifiReady == 1 then
            wifiBlinkCounter = 0
        end
        wifiReady = 0
        if wifiBlinkCounter < 10 then
            wifiBlinkCounter = wifiBlinkCounter + 1
            turnWiFiLedOnOff()
        end
        
        print("WiFi: (re-)connecting")

    end
end

function module.connect()
    gpio.mode(config.LED_STATUS, gpio.OUTPUT)
    wifi.setmode(wifi.STATION)
    wifi.sta.config(config.WIFI_SSID, config.WIFI_PASS)
    tmr.alarm(config.WIFI_ALARM_ID, 2000, tmr.ALARM_AUTO, wifi_watch)
end

return module
