local color_green = Color(96,221,92)

net.Receive('FatedTicket-Msg', function()
    local txt = net.ReadString()

    chat.AddText(color_green, '[FatedTicket] ', color_white, txt)
    chat.PlaySound()
end)

local color_blue_1 = Color(80, 107, 181)
local color_blue_2 = Color(61, 61, 138)

net.Receive('FatedTicket-Msg', function()
    local txt = net.ReadString()

    chat.AddText(color_blue_1, '[', color_blue_2, 'FatedTicket', color_blue_1, '] ', color_white, txt)
    chat.PlaySound()
end)

local mat_btn_roll = Material('fated_ticket/roll_btn.png')
local mat_star = Material('fated_ticket/star.png')
local color_player_panel_action = Color(74,86,100)
local color_player_btn = Color(24,24,26)
local color_action_btn = Color(76,76,76)
local color_panel_target = Color(204,64,64)
local color_gray = Color(80,80,80)

local function safeText(text)
    return string.match(text, '^#([a-zA-Z_]+)$') and text .. ' ' or text
end

local function DrawNonParsedText(text, font, x, y, color, xAlign)
    return draw.DrawText(safeText(text), font, x, y, color, xAlign)
end

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub('.', function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        if totalWidth >= remainingWidth then
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth

            return '\n' .. char
        end

        return char
    end)

    return text, totalWidth
end

local function textWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')

    text = text:gsub('(%s?[%S]+)', function(word)
            local char = string.sub(word, 1, 1)

            if char == '\n' or char == '\t' then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize(word)

            totalWidth = totalWidth + wordlen

            if wordlen >= maxWidth then
                local splitWord, splitPoint = charWrap(word, maxWidth - totalWidth + wordlen, maxWidth)

                totalWidth = splitPoint

                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end

            if char == ' ' then
                totalWidth = wordlen - spaceWidth

                return '\n' .. string.sub(word, 2)
            end

            totalWidth = wordlen

            return '\n' .. word
        end)

    return text
end

local function CreateAdminTicketMenu(tickets_count)
    FatedTicket.admin_menu = vgui.Create('DFrame')
    Mantle.ui.frame(FatedTicket.admin_menu, 'Количество жалоб: ' .. tickets_count, 300, 200, true)
    FatedTicket.admin_menu:SetPos(15, 52)
    FatedTicket.admin_menu.default_size = {300, 200}

    FatedTicket.admin_menu.btn_roll = vgui.Create('DButton', FatedTicket.admin_menu)
    FatedTicket.admin_menu.btn_roll:SetSize(20, 20)
    FatedTicket.admin_menu.btn_roll:SetPos(FatedTicket.admin_menu:GetWide() - 44, 2)
    FatedTicket.admin_menu.btn_roll:SetText('')
    FatedTicket.admin_menu.btn_roll.Paint = function(_, w, h)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat_btn_roll)
        surface.DrawTexturedRect(0, 0, w, h)
    end
    FatedTicket.admin_menu.btn_roll.DoClick = function()
        if FatedTicket.admin_menu:GetTall() == 24 then
            FatedTicket.admin_menu:SetSize(FatedTicket.admin_menu.default_size[1], FatedTicket.admin_menu.default_size[2])
            FatedTicket.admin_menu.btn_roll:SetPos(FatedTicket.admin_menu:GetWide() - 44, 2)
        else
            FatedTicket.admin_menu:SetSize(FatedTicket.admin_menu.default_size[1] * 0.7, 24)
            FatedTicket.admin_menu.btn_roll:SetPos(FatedTicket.admin_menu:GetWide() - 22, 2)
        end
    end

    FatedTicket.admin_menu.sp = vgui.Create('DScrollPanel', FatedTicket.admin_menu)
    Mantle.ui.sp(FatedTicket.admin_menu.sp)
    FatedTicket.admin_menu.sp:Dock(FILL)

    function FatedTicket.admin_menu.sp:CreateItems(tickets_count)
        FatedTicket.admin_menu.sp:Clear()
        FatedTicket.admin_menu.title_text = 'Количество жалоб: ' .. tickets_count

        for ply, ticket_data in pairs(FatedTicket.reports_cl) do
            local ticket_pan = vgui.Create('DPanel', FatedTicket.admin_menu.sp)
            ticket_pan:Dock(TOP)
            ticket_pan:DockMargin(0, 0, 0, 4)
            ticket_pan:SetTall(30)
            ticket_pan.Paint = function(_, w, h)
                draw.RoundedBox(0, 0, 0, w - 90, h, ticket_data.admin and color_player_panel_action or Mantle.color.panel[2])

                draw.SimpleText(ply:Name(), 'Fated.22', 30, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            ticket_pan.avatar = vgui.Create('AvatarImage', ticket_pan)
            ticket_pan.avatar:Dock(LEFT)
            ticket_pan.avatar:DockMargin(3, 3, 0, 3)
            ticket_pan.avatar:SetWide(24)
            ticket_pan.avatar:SetPlayer(ply)

            ticket_pan.btn = vgui.Create('DButton', ticket_pan)
            ticket_pan.btn:Dock(RIGHT)
            ticket_pan.btn:SetWide(90)
            ticket_pan.btn:SetText('')
            ticket_pan.btn.Paint = function(self, w, h)
                draw.RoundedBoxEx(6, 0, 0, w, h, color_player_btn, false, true, false, true)
                draw.SimpleText('Открыть', 'Fated.18', w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            ticket_pan.btn.DoClick = function(self)
                if IsValid(FatedTicket.admin_menu.player_profile) then
                    FatedTicket.admin_menu.player_profile:Remove()
                end

                FatedTicket.admin_menu.player_profile = vgui.Create('DFrame')
                Mantle.ui.frame(FatedTicket.admin_menu.player_profile, 'Жалоба ' .. ply:Name(), 300, 200, true)
                local menu_x, menu_y = FatedTicket.admin_menu:GetPos()
                FatedTicket.admin_menu.player_profile:SetPos(menu_x + FatedTicket.admin_menu:GetWide() + 6, menu_y)

                local MainPanel = vgui.Create('DPanel', FatedTicket.admin_menu.player_profile)
                MainPanel:Dock(FILL)
                MainPanel.Paint = nil

                local has_target = (ticket_data.target != ply)
                local HalfWide = FatedTicket.admin_menu.player_profile:GetWide() * 0.5

                if has_target then
                    local target_job = team.GetName(ticket_data.target:Team())
                    local target_text = 'Ник: ' .. ticket_data.target:Name() .. '\nПривилегия: ' .. ticket_data.target:GetUserGroup() .. '\nРабота: ' .. target_job
                    target_text = textWrap(target_text, 'Fated.18', HalfWide - 12)

                    MainPanel.left = vgui.Create('DPanel', MainPanel)
                    MainPanel.left:Dock(LEFT)
                    MainPanel.left:SetWide(HalfWide - 8)
                    MainPanel.left.Paint = function(_, w, h)
                        draw.RoundedBox(6, 0, 0, w, 24, color_panel_target)
                        draw.SimpleText('Нарушитель', 'Fated.18', w * 0.5, 3, color_white, TEXT_ALIGN_CENTER)
                        DrawNonParsedText(target_text, 'Fated.18', 4, 26, color_white)
                    end
                end

                local reason_txt = ticket_data.reason:gsub('//', '\n'):gsub('\\n', '\n')
                reason_txt = textWrap(reason_txt, 'Fated.18', (has_target and HalfWide - 12) or FatedTicket.admin_menu.player_profile:GetWide() - 16)

                MainPanel.right = vgui.Create('DPanel', MainPanel)
                MainPanel.right:Dock(RIGHT)
                MainPanel.right:SetWide((has_target and HalfWide - 8) or FatedTicket.admin_menu.player_profile:GetWide() - 12)
                MainPanel.right.Paint = function(self, w, h)
                    draw.RoundedBox(6, 0, 0, w, 24, color_player_btn)
                    draw.SimpleText('Причина', 'Fated.18', w * 0.5, 3, color_white, TEXT_ALIGN_CENTER)
                    DrawNonParsedText(reason_txt, 'Fated.18', 4, 26, color_white)
                end

                local BottomPanel = vgui.Create('DPanel', FatedTicket.admin_menu.player_profile)
                BottomPanel:Dock(BOTTOM)
                BottomPanel:DockMargin(0, 4, 0, 0)
                BottomPanel:SetTall(30)
                BottomPanel.Paint = function(_, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, color_action_btn)
                end

                BottomPanel.left = vgui.Create('DButton', BottomPanel)
                BottomPanel.left:Dock(LEFT)
                BottomPanel.left:SetWide(FatedTicket.admin_menu.player_profile:GetWide() * 0.5 - 6)
                BottomPanel.left:SetText('')
                BottomPanel.left.Paint = function(self, w, h)
                    draw.SimpleText('Закрыть', 'Fated.22', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                BottomPanel.left.DoClick = function()
                    net.Start('FatedTicket-AdminAction')
                        net.WriteBool(true)
                        net.WriteEntity(ply)
                    net.SendToServer()

                    FatedTicket.admin_menu.player_profile:Remove()
                end

                local right_btn_text = ticket_data.admin and 'Действия' or 'Взять'

                BottomPanel.right = vgui.Create('DButton', BottomPanel)
                BottomPanel.right:Dock(RIGHT)
                BottomPanel.right:SetWide(BottomPanel.left:GetWide())
                BottomPanel.right:SetText('')
                BottomPanel.right.Paint = function(self, w, h)
                    draw.SimpleText(right_btn_text, 'Fated.22', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end
                BottomPanel.right.DoClick = function()
                    if !ticket_data.admin then
                        net.Start('FatedTicket-AdminAction')
                            net.WriteBool(false)
                            net.WriteEntity(ply)
                        net.SendToServer()

                        FatedTicket.admin_menu.player_profile:Remove()

                    else
                        local DM = Mantle.ui.derma_menu()

                        if has_target then
                            DM:AddOption('SteamID Нарушителя', function()
                                Mantle.func.sound()

                                SetClipboardText(ticket_data.target:SteamID())
                            end, 'icon16/bullet_red.png')
                        end
                        
                        DM:AddOption('SteamID Игрока', function()
                            Mantle.func.sound()

                            SetClipboardText(ply:SteamID())
                        end, 'icon16/bullet_blue.png')
                    end
                end
            end
        end
    end

    FatedTicket.admin_menu.sp:CreateItems(tickets_count)
end

net.Receive('FatedTicket-UpdateClientData', function()
    if LocalPlayer():IsAdmin() then
        FatedTicket.reports_cl = net.ReadTable()

        local count = table.Count(FatedTicket.reports_cl)

        if IsValid(FatedTicket.admin_menu) then
            FatedTicket.admin_menu.sp:CreateItems(count)
        else
            CreateAdminTicketMenu(count)
        end
    end
end)

net.Receive('FatedTicket-Rating', function()
    if IsValid(FatedTicket.rating_menu) then
        FatedTicket.rating_menu:Remove()
    end

    local admin = net.ReadEntity()

    FatedTicket.rating_menu = vgui.Create('DFrame')
    Mantle.ui.frame(FatedTicket.rating_menu, 'Оцените ' .. admin:Name(), 250, 62, true)
    FatedTicket.rating_menu:SetPos(ScrW() * 0.5 - 125, ScrH() - 77)
    FatedTicket.rating_menu.star = 0

    for rating = 1, 10 do
        local btn_rating = vgui.Create('DButton', FatedTicket.rating_menu)

        local size = (FatedTicket.rating_menu:GetWide() - 12) * 0.1

        btn_rating:SetText('')
        btn_rating:SetSize(24, 24)
        btn_rating:SetPos(6 + 24 * (rating - 1), 30)
        btn_rating.Paint = function(self, w, h)
            if self:IsHovered() then
                FatedTicket.rating_menu.star = rating
            end

            surface.SetDrawColor(rating <= FatedTicket.rating_menu.star and color_white or color_gray)
            surface.SetMaterial(mat_star)
            surface.DrawTexturedRect(0, 0, w, h)
        end
        btn_rating.DoClick = function()
            net.Start('FatedTicket-RatingResult')
                net.WriteEntity(admin)
                net.WriteInt(rating, 5)
            net.SendToServer()

            FatedTicket.rating_menu:Remove()
        end
    end
end)

concommand.Add('fated_ticket_create', function(_, _, _, reason_text)
    if IsValid(FatedTicket.create_menu) then
        FatedTicket.create_menu:Remove()
    end

    FatedTicket.create_menu = vgui.Create('DFrame')
    FatedTicket.create_menu:MakePopup()
    Mantle.ui.frame(FatedTicket.create_menu, 'Создание жалобы', 300, 170, true)
    FatedTicket.create_menu:Center()

    local entry_reason = Mantle.ui.desc_entry(FatedTicket.create_menu, 'Причина:', 'Напишите обстоятельства')

    local TargetLabel = vgui.Create('DLabel', FatedTicket.create_menu)
    TargetLabel:Dock(TOP)
    TargetLabel:DockMargin(0, 4, 0, 0)
    TargetLabel:SetText('Нарушитель:')
    TargetLabel:SetFont('Fated.16')

    local TargetComboBox = vgui.Create('DComboBox', FatedTicket.create_menu)
    TargetComboBox:Dock(TOP)
    TargetComboBox:DockMargin(0, 4, 0, 0)
    TargetComboBox:SetValue('Выберите игрока')
    TargetComboBox:SetFont('Fated.16')

    local players = player.GetAll()

    for plyID = 1, #players do
        local ply = players[plyID]

        if ply == LocalPlayer() then
            continue
        end

        TargetComboBox:AddChoice(ply:Name(), ply, nil, 'icon16/user.png')
    end

    TargetComboBox:AddChoice('Без нарушителя', LocalPlayer(), nil, 'icon16/page_white.png')

    if reason_text != '' then
        entry_reason:SetValue(reason_text)
    end

    local SendButton = vgui.Create('DButton', FatedTicket.create_menu)
    Mantle.ui.btn(SendButton, nil, nil, Color(244, 136, 63), nil, nil, nil, true)
    SendButton:Dock(FILL)
    SendButton:SetText('Отправить')
    SendButton:DockMargin(0, 4, 0, 0)
    SendButton.DoClick = function()
        local _, target = TargetComboBox:GetSelected()

        net.Start('FatedTicket-Send')
            net.WriteString(entry_reason:GetValue())
            net.WriteEntity(target)
        net.SendToServer()

        FatedTicket.create_menu:Remove()
    end
end)

concommand.Add('fated_ticket_statistic', function()
    if !LocalPlayer():IsAdmin() then
        return
    end

    if IsValid(FatedTicket.statistic_menu) then
        FatedTicket.statistic_menu:Remove()
    end

    FatedTicket.statistic_menu = vgui.Create('DFrame')
    FatedTicket.statistic_menu:MakePopup()
    Mantle.ui.frame(FatedTicket.statistic_menu, 'Статистика администрации', 500, 300, true)
    FatedTicket.statistic_menu:Center()

    FatedTicket.statistic_menu.sp = vgui.Create('DScrollPanel', FatedTicket.statistic_menu)
    Mantle.ui.sp(FatedTicket.statistic_menu.sp)
    FatedTicket.statistic_menu.sp:Dock(FILL)

    local players = player.GetAll()

    for plyID = 1, #players do
        local ply = players[plyID]

        if !ply:IsAdmin() then
            continue
        end

        local info_pan = vgui.Create('DPanel', FatedTicket.statistic_menu.sp)
        info_pan:Dock(TOP)
        info_pan:SetTall(34)
        info_pan.Paint = function(_, w, h)
            draw.SimpleText('Ник', 'Fated.22', 8, h * 0.5 - 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText('Рейтинг', 'Fated.22', w * 0.5, h * 0.5 - 3, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText('Кол-во', 'Fated.22', w - 8, h * 0.5 - 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end

        local ply_pan = vgui.Create('DPanel', FatedTicket.statistic_menu.sp)
        ply_pan:Dock(TOP)
        ply_pan:SetTall(30)

        local ply_name = ply:Name()
        local ply_tickets = ply:GetNWInt('fated_ticket', 0)
        local ply_tickets_rating = ply:GetNWInt('fated_ticket_rating', 0)
        local ply_rating_text = string.sub(ply_tickets_rating / ply_tickets == 0 and 1 or (ply_tickets_rating / ply_tickets), 0, 3)

        ply_pan.Paint = function(_, w, h)
            draw.RoundedBox(6, 0, 0, w, h, Mantle.color.panel[2])

            draw.SimpleText(ply_name, 'Fated.18', 8, h * 0.5 - 1, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(ply_rating_text, 'Fated.18', w * 0.5, h * 0.5 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(ply_tickets, 'Fated.18', w - 8, h * 0.5 - 1, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
end)
