FatedTicket = FatedTicket or {}

local FileCl = SERVER and AddCSLuaFile or include
local FileSv = SERVER and include or function() end

FileSv('fated_ticket/sv_init.lua')
FileCl('fated_ticket/cl_init.lua')

if SERVER then
	resource.AddWorkshop('2924839375')
	resource.AddFile('materials/fated_ticket/close_btn.png')
	resource.AddFile('materials/fated_ticket/star.png')
end
