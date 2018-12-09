local module = {}

module.enabled = true

local function cron_tick()
	if not module.enabled then
		return
	end
	tm = rtctime.epoch2cal(rtctime.get() + config.TIMEZONE * 3600)
	for task,ct in pairs(CRONTABLE) do
		if cronutil.match(ct.mask, tm) then
			print('Running task ' .. task)
			ct.callback()
			ct.last = rtc.get_formatted_time_string(tm)
		end
	end
end

function module.init()
	cron.reset()
	cron.schedule("* * * * *", cron_tick)	
end

local function _add_or_update_crontab_row(name, mask_, callback_, enabled_)
	CRONTABLE[name] = {tp = task_pointer, mask = mask_, callback = callback_, enabled = enabled_ }
end

function module.add_or_update_task(name, mask, callback, enabled)
	_add_or_update_crontab_row(name, mask, callback, enabled)
	-- init_cron()
	print(string.format("Task %s scheduled with %s", name, mask))
	return task, mask, callback
end

function module.tasks( ... )
	local result = {}
	local counter = 0
	for k,v in pairs(CRONTABLE) do
		counter = counter + 1
		result[counter] = {k, v.mask, (v.enabled and "enabled" or "disabled"), v.last}
	end
	return result
end

function module.print_tasks( ... )
	local tasklist = module.tasks()
	for i = 1, #tasklist do
		print(string.format("| %s | %s | %s | %s |", tasklist[i][1], tasklist[i][2], tasklist[i][3], tasklist[i][4]))
	end
end


return module
