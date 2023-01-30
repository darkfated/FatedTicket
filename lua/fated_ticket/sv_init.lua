util.AddNetworkString('FatedTicket-Msg')
util.AddNetworkString('FatedTicket-Send')
util.AddNetworkString('FatedTicket-UpdateClientData')
util.AddNetworkString('FatedTicket-AdminAction')
util.AddNetworkString('FatedTicket-Rating')
util.AddNetworkString('FatedTicket-RatingResult')

local function FatedNotify(pl, txt)
	net.Start('FatedTicket-Msg')
		net.WriteString(txt)

	if pl == true then
		net.Broadcast()
	else
		net.Send(pl)
	end
end

FatedTicket.reports = FatedTicket.reports or {}

local function FatedUpdateClient()
	net.Start('FatedTicket-UpdateClientData')
		net.WriteTable(FatedTicket.reports)
	net.Broadcast()
end

net.Receive('FatedTicket-Send', function(_, pl)
	local reason = net.ReadString()
	local target = net.ReadEntity()

	if reason == '' then
		FatedNotify(pl, 'Укажите причину.')

		return
	end

	if string.len(reason) > 120 then
		FatedNotify(pl, 'Причина слишком длинная.')

		return
	end

	if !IsValid(target) then
		FatedNotify(pl, 'Выберите игрока.')
		
		return
	end

	FatedNotify(pl, 'Жалоба отправлена!')

	FatedTicket.reports[pl] = {
		reason = reason,
		target = target,
	}

	FatedUpdateClient()
end)

net.Receive('FatedTicket-AdminAction', function(_, pl)
	local mode_close = net.ReadBool()
	local ticket_ply = net.ReadEntity()

	if !IsValid(ticket_ply) then
		FatedNotify(pl, 'Этот игрок больше не существует.')

		return
	end

	if !pl:IsAdmin() then
		FatedNotify(pl, 'У вас нет прав на выполнение этого действия.')
		
		return
	end

	if ticket_ply == pl then
		FatedNotify(pl, 'Нельзя разбирать свою жалобу!')

		return
	end

	local players = player.GetAll()
	local current_ticket = FatedTicket.reports[ticket_ply]

	if mode_close then
		if current_ticket.admin then
			if current_ticket.admin != pl then
				FatedNotify(pl, 'Это не ваша жалоба.')

				return
			else
				pl:SetNWInt('fated_ticket', pl:GetNWInt('fated_ticket', 0) + 1)

				net.Start('FatedTicket-Rating')
					net.WriteEntity(pl)
				net.Send(ticket_ply)
			end
		end

		FatedTicket.reports[ticket_ply] = nil

		FatedUpdateClient()
		FatedNotify(true, pl:Name() .. ' (' .. pl:SteamID() .. ') закрыл жалобу ' .. ticket_ply:Name())
	else
		current_ticket.admin = pl

		FatedUpdateClient()
		FatedNotify(true, pl:Name() .. ' (' .. pl:SteamID() .. ') взял жалобу ' .. ticket_ply:Name())

		pl:SetPos(ticket_ply:GetPos())
	end
end)

net.Receive('FatedTicket-RatingResult', function(_, pl)
	local admin = net.ReadEntity()

	if !IsValid(admin) then
		return
	end

	local rating = net.ReadInt(5)

	admin:SetNWInt('fated_ticket_rating', pl:GetNWInt('fated_ticket_rating', 0) + rating)

	DarkRP.notify(admin, NOTIFY_GENERIC, 2.5, 'Вас оценили на ' .. rating .. '.')
end)

hook.Add('PlayerInitialSpawn', 'FatedTicket', function(pl)
	if pl:GetPData('fated_ticket') != nil then
		pl:SetNWInt('fated_ticket', pl:GetPData('fated_ticket'))
	end

	if pl:GetPData('fated_ticket_rating') != nil then
		pl:SetNWInt('fated_ticket_rating', pl:GetPData('fated_ticket_rating'))
	end
end)

hook.Add('PlayerDisconnected', 'FatedTicket', function(pl)
	if FatedTicket.reports[pl] then
		FatedTicket.reports[pl] = nil

		FatedUpdateClient()
		FatedNotify(notify_ply, 'Жалоба ' .. pl:Name() .. ' отменена - игрок вышел.')
	end

	if pl:GetNWInt('fated_ticket') != nil then
		pl:SetPData('fated_ticket', pl:GetNWInt('fated_ticket'))
	end

	if pl:GetNWInt('fated_ticket_rating') != nil then
		pl:SetPData('fated_ticket_rating', pl:GetNWInt('fated_ticket_rating'))
	end
end)
