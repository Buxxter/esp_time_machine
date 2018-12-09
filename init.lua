tmr.delay(3000000)
if file.open("init_test.lc") then
    file.close()
    dofile("init_test.lc")
else
    dofile("init_test.lua")
end

