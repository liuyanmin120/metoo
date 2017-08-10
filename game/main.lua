local skynet = require "skynet"
local snax = require "skynet.snax"
local cluster = require "skynet.cluster"

local config = {
	{ name = "s_config", key = "id" },
	{ name = "s_roleinit", key = "id" },
}

local user = {
	{ name = "d_user", key = "uid" },
	{ name = "d_building", key = "id", indexkey = "uid" },
}

local common = {
	{ name = "d_user", key = "name", columns = "name" },
}

skynet.start(function()
	local log = skynet.uniqueservice("log")
	skynet.call(log, "lua", "start")
	
	skynet.newservice("debug_console", tonumber(skynet.getenv("debug_port")))

	local dbmgr = skynet.uniqueservice("dbmgr")
	skynet.call(dbmgr, "lua", "start", config, user, common)

	local dcmgr = skynet.uniqueservice("dcmgr")
	skynet.call(dcmgr, "lua", "start")

	skynet.uniqueservice("online")

	local gate = skynet.uniqueservice("gated")		-- 启动游戏服务器
	skynet.call(gate, "lua", "init")				-- 初始化，预先分配若干agent
	skynet.call(gate, "lua", "open" , {
		port = tonumber(skynet.getenv("port")) or 8888,
		maxclient = tonumber(skynet.getenv("maxclient")) or 1024,
		servername = NODE_NAME,
	})

	cluster.open(NODE_NAME)
end)

