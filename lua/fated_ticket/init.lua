--[[
	* FatedTicket *
	GitHub: https://github.com/darkfated/FatedTicket
	Author's discord: darkfated
]]--

local function run_scripts()
	local cl = SERVER and AddCSLuaFile or include
	local sv = SERVER and include or function() end

	sv('server.lua')

	cl('client.lua')
end

local function init()
	if SERVER then
        resource.AddWorkshop('2924839375')
        resource.AddFile('materials/fated_ticket/roll_btn.png')
        resource.AddFile('materials/fated_ticket/star.png')
	end

	FatedTicket = FatedTicket or {}

	run_scripts()
end

init()