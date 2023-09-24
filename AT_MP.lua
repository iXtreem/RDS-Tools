require 'lib.moonloader'
script_name 'AT_MP' 
script_author 'Neon4ik'
local version = 0.2
local function recode(u8) return encoding.UTF8:decode(u8) end -- äåøèôðîâêà ïðè àâòîîîáíîâëåíèè
local imgui = require 'imgui'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local main_window_state = imgui.ImBool(false)
local menu_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local russkaya_window_state = imgui.ImBool(false)
local corol_window_state = imgui.ImBool(false)
local poliv_window_state = imgui.ImBool(false)
local pryatki_window_state = imgui.ImBool(false)
local sportzal_window_state = imgui.ImBool(false)
local sw, sh = getScreenResolution()
local text_buffer = imgui.ImBuffer(256)
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local cfg = inicfg.load({
    settings = {
        style = 0
    },
}, 'AdminTools.ini')
inicfg.save(cfg, 'AdminTools.ini')
local style_selected = imgui.ImInt(cfg.settings.style) -- Áåð¸ì ñòàíäàðòíîå çíà÷åíèå ñòèëÿ èç êîíôèãà

function main()
    repeat wait(0) until isSampAvailable()
    local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.ini" -- Ññûëêà íà êîíôèã
	local update_path = getWorkingDirectory() .. "//resource//AT_MP.ini" -- è òóò òó æå ñàìóþ ññûëêó
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AT_MP.lua" -- Ññûëêà íà ñàì ôàéë
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
		lua_thread.create(function()
			wait(1000)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				AT_MP = inicfg.load(nil, update_path)
				if tonumber(AT_MP.script.version) > version then
					update_state = true
				end
				os.remove(update_path)
			end
		end)
    end)
	sampRegisterChatCommand('updatemp', function()
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage(tag .. 'Ñêðèïò ìåðîïðèÿòèé óñïåøíî îáíîâëåí.')
					showCursor(false,false)
					thisScript():reload()
				end
			end)
		else
			sampAddChatMessage(tag .. 'Ó âàñ óñòàíîâëåíà àêòóàëüíàÿ âåðñèÿ äëÿ ìåðîïðèÿòèé.')
		end
	end)
    writeMemory(sampGetBase() + 0x9D9D0, 4, 0x5051FF15, true)
    while true do
        wait(0)
        if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
            result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
            if result and imgui.Process then
                _, id = sampGetPlayerIdByCharHandle(ped)
                menu_window_state.v = true
                showCursor(true,false)
            end
        end
    end
end
function imgui.OnDrawFrame()
    if not main_window_state.v and not secondary_window_state.v and not russkaya_window_state.v and not menu_window_state.v and not corol_window_state.v and not poliv_window_state.v and not pryatki_window_state.v and not sportzal_window_state.v then
        imgui.Process = false
    end
    if main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Ìåðîïðèÿòèÿ", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.Text(u8'Ïîìî÷ü ïðîâåñòè ìåðîïðèÿòèå?')
        if imgui.Button(u8'Äà', imgui.ImVec2(125, 25)) then
            secondary_window_state.v = true
            main_window_state.v = false
        end
        imgui.SameLine()
        if imgui.Button(u8'Íåò', imgui.ImVec2(125, 25)) then
            main_window_state.v = false
        end
        imgui.End()
    end
    if menu_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2) - 100, (sh/2) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Âçàèìîäåéñòâèå ñ èãðîêîì", menu_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.Text(u8'×òî ñäåëàòü ñ èãðîêîì\n' .. sampGetPlayerNickname(id) .. '?')
        if imgui.Button(u8'Çàñïàâíèòü', imgui.ImVec2(200, 30)) then
            sampSendChat('/aspawn ' .. id)
        end
        if imgui.Button(u8'Íàðóøåíèå ïðàâèë ìåðîïðèÿòèé', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 300 Íàðóøåíèå ïðàâèë ÌÏ')
            showCursor(false,false)
            menu_window_state.v = false
        end
        if imgui.Button(u8'Ñðûâ ìåðîïðèÿòèÿ', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 3000 Ñðûâ ìåðîïðèÿòèÿ')
            showCursor(false,false)
            menu_window_state.v = false
        end
        if imgui.Button(u8'Âûäàòü ïðèç', imgui.ImVec2(200, 30)) then
            sampSendChat('/mess 7 Ïîáåäèòåëü ìåðîïðèÿòèÿ - ' .. sampGetPlayerNickname(id) .. '[' .. id .. ']' .. ' ïîçäðàâèì åãî!')
            sampSendChat('/mpwin ' .. id)
            sampSetChatInputText('/spp')
            sampSetChatInputEnabled(true)
            setVirtualKeyDown(13, true)
            setVirtualKeyDown(13, false)
            _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
            sampSendChat('/tweap ' .. myid)
            sampSendChat('/az')
            sampSendChat('/delcarall')
            showCursor(false,false)
            thisScript():reload()
        end
        if corol_window_state.v or sportzal_window_state.v then
            if not player1 then
                if imgui.Button(u8'Ñîõðàíèòü 1-îãî èãðîêà', imgui.ImVec2(200, 30)) then
                    player1 = id
                    showCursor(false,false)
                    menu_window_state.v = false
                end
            end
            if not player2 then
                if imgui.Button(u8'Ñîõðàíèòü 2-îãî èãðîêà', imgui.ImVec2(200, 30)) then
                    player2 = id
                    showCursor(false,false)
                    menu_window_state.v = false
                end
            end
        end
        imgui.End()
    end
    if secondary_window_state.v then
     --   imgui.SetNextWindowSize(imgui.ImVec2(250, 170), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Âûáåðè ìåðîïðèÿòèå", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        if imgui.Button(u8'Ðóññêàÿ ðóëåòêà', imgui.ImVec2(230, 30)) then
            russkaya_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Êîðîëü äèãëà', imgui.ImVec2(230, 30)) then
            corol_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Ïîëèâàëêà', imgui.ImVec2(230, 30)) then
            poliv_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Ïðÿòêè', imgui.ImVec2(230, 30)) then
            pryatki_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Áîêñ', imgui.ImVec2(230, 30)) then
            sportzal_window_state.v = true
            secondary_window_state.v = false
        end
        imgui.End()
    end
    if russkaya_window_state.v then
   --     imgui.SetNextWindowSize(imgui.ImVec2(250, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Ðóññêàÿ ðóëåòêà", russkaya_window_state, imgui.WindowFlags.NoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Àêòèâàöèÿ êóðñîðà - F')
            imgui.Text(u8'Âçàèìîäåéñòâèå ñ èãðîêàìè:')
            imgui.Text(u8'Ïðàâàÿ êíîïêà ìûøè + 1')
            if imgui.Button(u8'Íà÷àòü ñáîð èãðîêîâ', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Îæèäàéòå...', -1)
                    if not sampIsDialogActive() then
                        sampSendChat('/mp')
                    end
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 8, nil)
                    wait(1000)
                    sampSendDialogResponse(5343, 1, 8, nil)
                    sampSendDialogResponse(5343, 1, 14, nil)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(1)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Ðóññêàÿ Ðóëåòêà')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Íà÷èíàåòñÿ ìåðîïðèÿòèå Ðóññêàÿ Ðóëåòêà, äëÿ òåëåïîðòà ââîäè /tpmp')
                    sampSendChat('/mess 7 Ïîòîðîïèñü, òåëåïîðò ñêîðî çàêðîåòñÿ! Ââîäè /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Íàïîìíèòü ïðî ìåðîïðèÿòèå', imgui.ImVec2(230, 30)) then
                sampSendChat('/mess 7 Òåëåïîðò âñ¸ åù¸ îòêðûò, ó òåáÿ åñòü øàíñ ïîó÷àâñòâîâàòü íà Ðóññêîé Ðóëåòêå, ââîäè /tpmp')
            end
            if imgui.Button(u8'Íà÷àòü ìåðîïðèÿòèå', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Ïðàâèëà ìåðîïðèÿòèÿ Ðóññêàÿ Ðóëåòêà!')
                    sampSendChat('/mess 7 /try óäà÷íî - óáèò, /try íåóäà÷íî - æèâ. Ïîáåæäàåò ñàìûé âåçó÷èé.')
                    sampSendChat('/mess 7 Çàïðåùåíû: /passive, /fly, /gt, DM, /s /r /anim /jp è ëþáàÿ äðóãàÿ ïîìåõà èãðîêàì.')
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSetChatInputText('/stw ' .. myid)
                    sampSetChatInputEnabled(true)
                    setVirtualKeyDown(13, true)
                    setVirtualKeyDown(13, false)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
        end
        if mp then
            lua_thread.create(function()
                if imgui.Button(u8'Âûäàòü âñåì õï', imgui.ImVec2(230, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Îáåççàðóæèòü âñåõ', imgui.ImVec2(230, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Çàâåðøèòü ÌÏ äîñðî÷íî', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    showCursor(false,false)
                    thisScript():reload()
                end
            end)
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,true)
                cursor = true
            end
        end
        imgui.End()
    end
    if corol_window_state.v then
      --  imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Êîðîëü Äèãëà", corol_window_state, imgui.WindowFlags.NoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Óäîñòîâåðüòåñü, ÷òî ó âàñ âêëþ÷åíà àäìèí-çîíà')
            imgui.Text(u8'Âêëþ÷èòü å¸ ìîæíî â /mp - íàñòðîéêè - 1')
            imgui.Text(u8'Àêòèâàöèÿ êóðñîðà - F')
            imgui.Text(u8'Âçàèìîäåéñòâèå ñ èãðîêàìè:')
            imgui.Text(u8'Ïðàâàÿ êíîïêà ìûøè + 1')
            if imgui.Button(u8'Íà÷àòü ñáîð èãðîêîâ', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Îæèäàéòå...', -1)
                    if not sampIsDialogActive() then
                        sampSendChat('/mp')
                    end
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 4, nil)
                    wait(400)
                    sampSendDialogResponse(5343, 1, 4, nil)
                    wait(400)
                    sampSendDialogResponse(5343, 1, 14, nil)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(1)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Êîðîëü äèãëà')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Íà÷èíàåòñÿ ìåðîïðèÿòèå Êîðîëü äèãëà, äëÿ òåëåïîðòà ââîäè /tpmp')
                    sampSendChat('/mess 7 Ïîòîðîïèñü, òåëåïîðò ñêîðî çàêðîåòñÿ! Ââîäè /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Íàïîìíèòü ïðî ìåðîïðèÿòèå', imgui.ImVec2(280, 30)) then
                sampSendChat('/mess 7 Òåëåïîðò âñ¸ åù¸ îòêðûò, ó òåáÿ åñòü øàíñ ïîó÷àâñòâîâàòü â ìåðîïðèÿòèè Êîðîëü Äèãëà, ââîäè /tpmp')
            end
            if imgui.Button(u8'Íà÷àòü ìåðîïðèÿòèå', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Ïðàâèëà ìåðîïðèÿòèÿ Êîðîëü Äèãëà!')
                    sampSendChat('/mess 7 ß âûçûâàþ äâóõ ÷åëîâåê, êîòîðûå íà÷èíàþò ñòðåëÿòüñÿ ïî ìîåé êîìàíäå, ïîáåæäàåò ñèëüíåéøèé')
                    sampSendChat('/mess 7 Çàïðåùåíû: /passive, /fly, /gt, DM, /s /r /anim /jp è ëþáàÿ äðóãàÿ ïîìåõà èãðîêàì.')
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSetChatInputText('/stw ' .. myid)
                    sampSetChatInputEnabled(true)
                    setVirtualKeyDown(13, true)
                    setVirtualKeyDown(13, false)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
        end
        if mp then
            lua_thread.create(function()
                if imgui.Button(u8'Âûäàòü âñåì õï', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Îáåççàðóæèòü âñåõ', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Ïîäåëèòü âñåõ íà êîìàíäû', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 15, nil)
                    wait(400)
                    sampSendDialogResponse(16075 , 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            if player1 then
                if imgui.Button(u8'Òåëåïîðòèðîâàòü 1-îãî èãðîêà', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player1)
                end
            end
            if player2 then
                if imgui.Button(u8'Òåëåïîðòèðîâàòü 2-îãî èãðîêà', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player2)
                end
            end
            lua_thread.create(function()
                if player1 and player2 then
                    if imgui.Button(u8'Íà÷àòü PVP', imgui.ImVec2(280, 30)) then
                        sampSendChat('/mess 3 Íà àðåíó âûõîäÿò èãðîêè ' .. sampGetPlayerNickname(player1) .. ' è ' .. sampGetPlayerNickname(player2))
                        sampSendChat('/mess 3 Íà÷èíàþ îòñ÷åò â 10 ñåêóíä, ïîñëå íåãî ìîæíî íà÷èíàòü îãîíü!')
                        sampSendChat('/dmcount 10')
                        player1 = nil
                        player2 = nil
                    end
                else
                    if imgui.Button(u8'Íà÷àòü PVP', imgui.ImVec2(280, 30)) then
                        sampAddChatMessage('{FF0000}MP{FFFFFF}: Íàæìè ïðàâîé êíîïêîé ìûøè + 1 íà æåëàåìîãî èãðîêà è äîáàâü åãî â ñêðèïò', -1)
                        sampAddChatMessage('{FF0000}MP{FFFFFF}: Ñäåëàé òàêæå ñî âòîðûì èãðîêîì, òîëüêî ïîñëå ýòîãî íàæèìàé êíîïêó.', -1)
                    end
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Çàâåðøèòü ÌÏ äîñðî÷íî', imgui.ImVec2(280, 30)) then
                    showCursor(false,false)
                    thisScript():reload()
                end
            end)
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,true)
                cursor = true
            end
        end
        imgui.End()
    end
    if poliv_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(250, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Ïîëèâàëêà", poliv_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Àêòèâàöèÿ êóðñîðà - F')
            imgui.Text(u8'Íàêàçàòü èãðîêà - êîìàíäà /jm')
            imgui.Text(u8'Ñêðèïò ñäåëàåò âñå ñàì, âàì òîëüêî æàòü êíîïêè.')
            imgui.Text(u8'Çàêðîéòå äèàëîãè ÷òîáû ñêðèïò ñàì ñäåëàë òåëåïîðò.')
            if imgui.Button(u8'Íà÷àòü ñáîð èãðîêîâ', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Îæèäàéòå...', -1)
                    while sampIsDialogActive() do
                        wait(0)
                        sampCloseCurrentDialogWithButton(0)
                    end
                    sampSendChat('/tpcor 1575.5280761719 -1238.5983886719 277.87603759766 0 990')
                    wait(500)
                    sampSendChat('/tpcor 1575.5280761719 -1238.5983886719 277.87603759766 0 990')
                    wait(2000)
                    sampSendChat('/mp')
                    sampSendDialogResponse(5343, 1, 14, nil)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(1)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Ïîëèâàëêà')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Íà÷èíàåòñÿ ìåðîïðèÿòèå Ïîëèâàëêà, äëÿ òåëåïîðòà ââîäè /tpmp')
                    sampSendChat('/mess 7 Ïîòîðîïèñü, òåëåïîðò ñêîðî çàêðîåòñÿ! Ââîäè /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Íàïîìíèòü ïðî ìåðîïðèÿòèå', imgui.ImVec2(230, 30)) then
                sampSendChat('/mess 7 Òåëåïîðò âñ¸ åù¸ îòêðûò, ó òåáÿ åñòü øàíñ ïîó÷àâñòâîâàòü â ìåðîïðèÿòèè Ïîëèâàëêà, ââîäè /tpmp')
            end
            if imgui.Button(u8'Íà÷àòü ìåðîïðèÿòèå', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Ïðàâèëà ìåðîïðèÿòèÿ Ïîëèâàëêà!')
                    sampSendChat('/mess 7 Âû ðàçáåãàåòåñü ïî âñåé êðûøå, ÿ ïûòàþñü âàñ ñáèòü, ïîñëåäíèé âûæèâøèé - ïîáåæäàåò')
                    sampSendChat('/mess 7 Çàïðåùåíû: /passive, /fly, /gt, DM, /s /r /anim /jp è ëþáàÿ äðóãàÿ ïîìåõà èãðîêàì.')
                    sampSendChat('/veh 601 1 1')
                    while getClosestCarId() == '-1' do
                        wait(0)
                    end
                    wait(2000)
                    sampSendChat('/entercar ' .. getClosestCarId())
                    sampSendChat('/mess 7 Ðàçáåãàåìñÿ!')
                    sampSendChat('/dmcount 5')
                    sampSendChat('/s')
                    sampAddChatMessage('{FF0000}MP{FFFFFF}:ÏÎÇÈÖÈß ÁÛËÀ ÑÎÕÐÀÍÅÍÀ, ÅÑËÈ ÓÏÀÄ¨ÒÅ ÈÑÏÎËÜÇÓÉÒÅ /r', -1)
                    sampAddChatMessage('{FF0000}MP{FFFFFF}:ÏÎÇÈÖÈß ÁÛËÀ ÑÎÕÐÀÍÅÍÀ, ÅÑËÈ ÓÏÀÄ¨ÒÅ ÈÑÏÎËÜÇÓÉÒÅ /r', -1)
                    sampAddChatMessage('{FF0000}MP{FFFFFF}:ÏÎÇÈÖÈß ÁÛËÀ ÑÎÕÐÀÍÅÍÀ, ÅÑËÈ ÓÏÀÄ¨ÒÅ ÈÑÏÎËÜÇÓÉÒÅ /r', -1)
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
        end
        if mp then
            lua_thread.create(function()
                if imgui.Button(u8'Âûäàòü âñåì õï', imgui.ImVec2(230, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Îáåççàðóæèòü âñåõ', imgui.ImVec2(230, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Çàâåðøèòü ÌÏ äîñðî÷íî', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    thisScript():reload()
                end
            end)
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,true)
                cursor = true
            end
        end
        imgui.End()
    end
    if pryatki_window_state.v then
        --     imgui.SetNextWindowSize(imgui.ImVec2(250, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Ïðÿòêè", pryatki_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Àêòèâàöèÿ êóðñîðà - F')
            imgui.Text(u8'Âçàèìîäåéñòâèå ñ èãðîêàìè:')
            imgui.Text(u8'Ïðàâàÿ êíîïêà ìûøè + 1')
            if imgui.Button(u8'Íà÷àòü ñáîð èãðîêîâ', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Îæèäàéòå...', -1)
                    if not sampIsDialogActive() then
                        sampSendChat('/mp')
                    end
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 5, nil)
                    wait(400)
                    sampSendDialogResponse(5343, 1, 5, nil)
                    wait(400)
                    sampSendDialogResponse(5343, 1, 14, nil)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(1)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Ïðÿòêè')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Íà÷èíàåòñÿ ìåðîïðèÿòèå Ïðÿòêè, äëÿ òåëåïîðòà ââîäè /tpmp')
                    sampSendChat('/mess 7 Ïîòîðîïèñü, òåëåïîðò ñêîðî çàêðîåòñÿ! Ââîäè /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Íàïîìíèòü ïðî ìåðîïðèÿòèå', imgui.ImVec2(230, 30)) then
                sampSendChat('/mess 7 Òåëåïîðò âñ¸ åù¸ îòêðûò, ó òåáÿ åñòü øàíñ ïîó÷àâñòâîâàòü â Ïðÿòêàõ, ââîäè /tpmp')
            end
            if imgui.Button(u8'Íà÷àòü ìåðîïðèÿòèå', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Ïðàâèëà ìåðîïðèÿòèÿ Ïðÿòêè!')
                    sampSendChat('/mess 7 Âû ðàçáåãàåòåñü ïî âñåìó êîðàáëþ, ÿ îòïðàâëÿþñü íà âàøè ïîèñêè, ïîáåæäàåò ïîñëåäíèé âûæèâøèé.')
                    sampSendChat('/mess 7 Çàïðåùåíû: /passive, /fly, /gt, DM, /s /r /anim /jp è ëþáàÿ äðóãàÿ ïîìåõà èãðîêàì.')
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSetChatInputText('/stw ' .. myid)
                    sampSetChatInputEnabled(true)
                    setVirtualKeyDown(13, true)
                    setVirtualKeyDown(13, false)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
        end
        if mp then
            lua_thread.create(function()
                if imgui.Button(u8'Âûäàòü âñåì õï', imgui.ImVec2(230, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Îáåççàðóæèòü âñåõ', imgui.ImVec2(230, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Çàâåðøèòü ÌÏ äîñðî÷íî', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    thisScript():reload()
                end
            end)
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,true)
                cursor = true
            end
        end
        imgui.End()
    end
    if sportzal_window_state.v then
            --  imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Áîêñ", sportzal_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Óäîñòîâåðüòåñü, ÷òî ó âàñ âêëþ÷åíà àäìèí-çîíà')
            imgui.Text(u8'Âêëþ÷èòü å¸ ìîæíî â /mp - íàñòðîéêè - 1')
            imgui.Text(u8'Àêòèâàöèÿ êóðñîðà - F')
            imgui.Text(u8'Âçàèìîäåéñòâèå ñ èãðîêàìè:')
            imgui.Text(u8'Ïðàâàÿ êíîïêà ìûøè + 1')
            if imgui.Button(u8'Íà÷àòü ñáîð èãðîêîâ', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Îæèäàéòå...', -1)
                    while sampIsDialogActive() do
                        wait(0)
                        sampCloseCurrentDialogWithButton(0)
                    end
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 990')
                    wait(400)
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 990')
                    if not sampIsDialogActive() then
                        sampSendChat('/mp')
                    end
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 14, nil)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(1)
                    wait(400)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Áîêñ')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Íà÷èíàåòñÿ ìåðîïðèÿòèå Áîêñ, äëÿ òåëåïîðòà ââîäè /tpmp')
                    sampSendChat('/mess 7 Ïîòîðîïèñü, òåëåïîðò ñêîðî çàêðîåòñÿ! Ââîäè /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Íàïîìíèòü ïðî ìåðîïðèÿòèå', imgui.ImVec2(280, 30)) then
                sampSendChat('/mess 7 Òåëåïîðò âñ¸ åù¸ îòêðûò, ó òåáÿ åñòü øàíñ ïîó÷àâñòâîâàòü â ìåðîïðèÿòèè Áîêñ, ââîäè /tpmp')
            end
            if imgui.Button(u8'Íà÷àòü ìåðîïðèÿòèå', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Ïðàâèëà ìåðîïðèÿòèÿ Áîêñ!')
                    sampSendChat('/mess 7 ß âûáèðàþ 2 ÷åëîâåê, êîòîðûå ñðàæàþòñÿ íà ðèíãå, ïîáåæäàåò ñèëüíåéøèé.')
                    sampSendChat('/mess 7 Çàïðåùåíû: /passive, /fly, /gt, DM, /s /r /anim /jp è ëþáàÿ äðóãàÿ ïîìåõà èãðîêàì.')
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSetChatInputText('/stw ' .. myid)
                    sampSetChatInputEnabled(true)
                    setVirtualKeyDown(13, true)
                    setVirtualKeyDown(13, false)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
        end
        if mp then
            lua_thread.create(function()
                if imgui.Button(u8'Âûäàòü âñåì õï', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Îáåççàðóæèòü âñåõ', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Ïîäåëèòü âñåõ íà êîìàíäû', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mp')
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 15, nil)
                    wait(400)
                    sampSendDialogResponse(16075 , 1, 0, nil)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                end
            end)
            if player1 then
                if imgui.Button(u8'Òåëåïîðòèðîâàòü 1-îãî èãðîêà', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player1)
                end
            end
            if player2 then
                if imgui.Button(u8'Òåëåïîðòèðîâàòü 2-îãî èãðîêà', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player2)
                end
            end
            lua_thread.create(function()
                if player1 and player2 then
                    if imgui.Button(u8'Íà÷àòü PVP', imgui.ImVec2(280, 30)) then
                        sampSendChat('/mess 3 Íà àðåíó âûõîäÿò èãðîêè ' .. sampGetPlayerNickname(player1) .. ' è ' .. sampGetPlayerNickname(player2))
                        sampSendChat('/mess 3 Íà÷èíàþ îòñ÷åò â 10 ñåêóíä, ïîñëå íåãî ìîæíî íà÷èíàòü.')
                        sampSendChat('/dmcount 10')
                        player1 = nil
                        player2 = nil
                    end
                else
                    if imgui.Button(u8'Íà÷àòü PVP', imgui.ImVec2(280, 30)) then
                        sampAddChatMessage('{FF0000}MP{FFFFFF}: Íàæìè ïðàâîé êíîïêîé ìûøè + 1 íà æåëàåìîãî èãðîêà è äîáàâü åãî â ñêðèïò', -1)
                        sampAddChatMessage('{FF0000}MP{FFFFFF}: Ñäåëàé òàêæå ñî âòîðûì èãðîêîì, òîëüêî ïîñëå ýòîãî íàæèìàé êíîïêó.', -1)
                    end
                end
            end)
            if imgui.Button(u8'Òåëåïîðòèðîâàòüñÿ íà ðèíã', imgui.ImVec2(280, 30)) then
                if not sampIsDialogActive() then
                    sampSendChat('/tpcor 759.23474121094 12.783633232117 1001.1639404297 5 990')
                else
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Çàêðîéòå äèàëîã')
                end
            end
            if imgui.Button(u8'Òåëåïîðòèðîâàòüñÿ âíå ðèíãà', imgui.ImVec2(280, 30)) then
                if not sampIsDialogActive() then
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 990')
                else
                    sampAddChatMessage('{FF0000}MP{FFFFFF}: Çàêðîéòå äèàëîã')
                end
            end
            lua_thread.create(function()
                if imgui.Button(u8'Çàâåðøèòü ÌÏ äîñðî÷íî', imgui.ImVec2(280, 30)) then
                    showCursor(false,false)
                    thisScript():reload()
                end
            end)
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,true)
                cursor = true
            end
        end
        imgui.End()
    end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    lua_thread.create(function()
        if dialogId == 5343 and not imgui.Process then
            main_window_state.v = true
            imgui.Process = true
        end
        if dialogId == 16067 and imgui.Process then
            sampSendDialogResponse(dialogId, 1, _, tonumber('990'))
        end
        if dialogId == 16068 and imgui.Process then
            sampSendDialogResponse(dialogId, 1, _, tonumber('0'))
        end
    end)
end

function getClosestCarId() -- óçíàòü èä áëèæàùåãî àâòî
    local minDist = 200 -- äèñòàíöèÿ
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i = 0, 1800 do
        local streamed, pedID = sampGetCarHandleBySampVehicleId(i)
        if streamed then
            local xi, yi, zi = getCarCoordinates(pedID)
            local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
            if dist < minDist then
                minDist = dist
                closestId = i
            end
        end
    end
    return closestId
end

function style(id) -- ÒÅÌÛ
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowRounding = 2.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 2.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0
    if id == 0 then -- Òåìíî-Ñèíÿÿ
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.00, 0.00, 0.00, 0.94)
		colors[clr.ChildWindowBg]        = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.26, 0.37, 0.98, 0.54)
		colors[clr.FrameBgHovered]       = ImVec4(0.33, 0.33, 0.93, 0.40)
		colors[clr.FrameBgActive]        = ImVec4(0.44, 0.44, 0.99, 0.67)
		colors[clr.TitleBg]              = ImVec4(0.30, 0.33, 0.95, 0.67)
		colors[clr.TitleBgActive]        = ImVec4(0.00, 0.16, 1.00, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.22, 0.19, 1.00, 0.67)
		colors[clr.MenuBarBg]            = ImVec4(0.39, 0.56, 1.00, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.30, 0.41, 0.99, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.52, 0.52, 0.97, 1.00)
		colors[clr.Button]               = ImVec4(0.11, 0.13, 0.93, 0.65)
		colors[clr.ButtonHovered]        = ImVec4(0.41, 0.57, 1.00, 0.65)
		colors[clr.ButtonActive]         = ImVec4(0.20, 0.20, 0.20, 0.50)
		colors[clr.Header]               = ImVec4(0.15, 0.19, 1.00, 0.54)
		colors[clr.HeaderHovered]        = ImVec4(0.03, 0.24, 0.57, 0.65)
		colors[clr.HeaderActive]         = ImVec4(0.36, 0.40, 0.95, 0.00)
		colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.SeparatorHovered]     = ImVec4(0.20, 0.42, 0.98, 0.54)
		colors[clr.SeparatorActive]      = ImVec4(0.20, 0.40, 0.93, 0.54)
		colors[clr.ResizeGrip]           = ImVec4(0.01, 0.17, 1.00, 0.54)
		colors[clr.ResizeGripHovered]    = ImVec4(0.21, 0.51, 0.98, 0.45)
		colors[clr.ResizeGripActive]     = ImVec4(0.04, 0.55, 0.95, 0.66)
		colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.CloseButtonHovered]   = ImVec4(0.10, 0.21, 0.98, 1.00)
		colors[clr.CloseButtonActive]    = ImVec4(0.02, 0.26, 1.00, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(0.18, 0.15, 1.00, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 1 then -- Êðàñíàÿ
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
		colors[clr.TextDisabled]         = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.53, 0.20, 0.16, 0.65)
		colors[clr.TitleBgActive]        = ImVec4(0.56, 0.14, 0.14, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark]            = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.64, 0.14, 0.14, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(1.00, 0.37, 0.37, 1.00)
		colors[clr.Button]               = ImVec4(0.59, 0.13, 0.13, 1.00)
		colors[clr.ButtonHovered]        = ImVec4(0.69, 0.15, 0.15, 1.00)
		colors[clr.ButtonActive]         = ImVec4(0.67, 0.13, 0.07, 1.00)
		colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered]        = ImVec4(0.98, 0.38, 0.26, 0.80)
		colors[clr.HeaderActive]         = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
		colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif id == 2 then -- çåëåíàÿ òåìà
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 0.78)
		colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.25, 0.29, 0.20, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.09, 0.12, 0.14, 0.65)
		colors[clr.TitleBgActive]        = ImVec4(0.35, 0.58, 0.06, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark]            = ImVec4(0.72, 1.00, 0.28, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.43, 0.57, 0.05, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.55, 0.67, 0.15, 1.00)
		colors[clr.Button]               = ImVec4(0.40, 0.57, 0.01, 1.00)
		colors[clr.ButtonHovered]        = ImVec4(0.45, 0.69, 0.07, 1.00)
		colors[clr.ButtonActive]         = ImVec4(0.27, 0.50, 0.00, 1.00)
		colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered]        = ImVec4(0.72, 0.98, 0.26, 0.80)
		colors[clr.HeaderActive]         = ImVec4(0.74, 0.98, 0.26, 1.00)
		colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.68, 0.98, 0.26, 0.25)
		colors[clr.ResizeGripHovered]    = ImVec4(0.72, 0.98, 0.26, 0.67)
		colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif id == 3 then -- áèðþçîâàÿ
        colors[clr.Text]                 = ImVec4(0.86, 0.93, 0.89, 0.78)
		colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg]             = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]                = colors[clr.PopupBg]
		colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
		colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.30)
		colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 0.50)
		colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 0.50)
		colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
		colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.26, 0.59, 0.98, 0.25)
		colors[clr.ResizeGripHovered]    = ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.ResizeGripActive]     = ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton]          = ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered]   = ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive]    = ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]       = ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
	elseif id == 4 then -- 
		imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4

		style.WindowRounding = 2.0
		style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
		style.ChildWindowRounding = 2.0
		style.FrameRounding = 2.0
		style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
		style.ScrollbarSize = 13.0
		style.ScrollbarRounding = 0
		style.GrabMinSize = 8.0
		style.GrabRounding = 1.0 
		
		colors[clr.WindowBg]              = ImVec4(0, 0, 0, 1);
		colors[clr.ChildWindowBg]         = ImVec4(0, 0, 0, 1);
		colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
		colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
		colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
		colors[clr.FrameBg]               = ImVec4(0.12, 0.12, 0.12, 0.94);
		colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
		colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
		colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
		colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
		colors[clr.ScrollbarBg]           = ImVec4(0.04, 0.04, 0.04, 1.00);
		colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
		colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
		colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
		colors[clr.SliderGrab]            = ImVec4(0.28, 0.28, 0.28, 1.00);
		colors[clr.SliderGrabActive]      = ImVec4(0.35, 0.35, 0.35, 1.00);
		colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
		colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
		colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
		colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
		colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
		colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
		colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
		colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
		colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
		colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
		colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
		colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
		colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
		colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
		colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
    elseif id == 5 then -- Ïðîñòî ïðèÿòíàÿ òåìà
        imgui.SwitchContext()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local clr = imgui.Col
		local ImVec4 = imgui.ImVec4
		local ImVec2 = imgui.ImVec2
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.28, 0.30, 0.35, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.16, 0.18, 0.22, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.19, 0.22, 0.26, 1)
		colors[clr.PopupBg]                = ImVec4(0.05, 0.05, 0.10, 0.90)
		colors[clr.Border]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.22, 0.25, 0.30, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.22, 0.25, 0.29, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.19, 0.22, 0.26, 0.59)
		colors[clr.MenuBarBg]              = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.20, 0.25, 0.30, 0.60)
		colors[clr.ScrollbarGrab]          = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.49, 0.63, 0.86, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.49, 0.63, 0.86, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.90, 0.90, 0.90, 0.50)
		colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.30)
		colors[clr.SliderGrabActive]       = ImVec4(0.80, 0.50, 0.50, 1.00)
		colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(0.49, 0.62, 0.85, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.49, 0.62, 0.85, 1.00)
		colors[clr.Header]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.22, 0.24, 0.28, 1.00)
		colors[clr.HeaderActive]           = ImVec4(0.22, 0.24, 0.28, 1.00)
		colors[clr.Separator]              = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.SeparatorHovered]       = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.SeparatorActive]        = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(0.49, 0.61, 0.83, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(0.49, 0.62, 0.83, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.CloseButtonHovered]     = ImVec4(0.50, 0.63, 0.84, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(0.41, 0.55, 0.78, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.16, 0.18, 0.22, 0.76)
    end
end
style(style_selected.v)
