-- GLOBAL VARIABLES --
DEBUG = false
CRONTABLE = {}
--
if DEBUG then
    print('DEBUG is true. Delay for 3s')
    tmr.delay(3000000)
end

-- init all globals
function load_lib(fname)
    if file.open(fname .. ".lc") then
        file.close()
        dofile(fname .. ".lc")
    else
        dofile(fname .. ".lua")
    end
end

-- load_lib("gpio_defines")
-- load_lib("config")
config = require("config")
network = require("network")
mqttc = nil
rtc = nil
cronutil = require("cronutil")
crontab = require("crontab")

cronutil.debug = false
crontab.init()




-- Configure
network.connect()

html_utils = require("html_utils")

-- Button
--load_lib('button')               -- call for new created button Module

load_lib("load_crontasks")
