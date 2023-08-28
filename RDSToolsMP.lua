require 'lib.moonloader'
script_name 'RDS Tools MP' 
script_author 'Neon4ik'
local version = 0.1 
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local imgui = require 'imgui'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
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

function main()
    repeat wait(0) until isSampAvailable()
    update_state = false
    local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "/RDSTools.ini" -- и тут ту же самую ссылку
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- Ссылка на сам файл
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            RDSTools = inicfg.load(nil, update_path)
            if tonumber(RDSTools.script.versionMP) > version then
                update_state = true
				sampAddChatMessage('{FF0000}RDS Tools MP: {FFFFFF}Найдено обновление, загрузить можно командой {808080}/update', -1)
			end
            os.remove(update_path)
        end
    end)
	sampRegisterChatCommand('update', function(param)
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					wait(10000)
					sampShowDialog(1000, "xX RDS Tools Xx", '{FFFFFF}Была найдена новая версия - ' .. RDSTools.script.versionMP .. '\n{FFFFFF}В ней добавлено ' .. RDSTools.script.info, "Спасибо", "", 0)
					showCursor(false,false)
					thisScript():reload()
				end
			end)
		else
			sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}У вас установлена актуальная версия.')
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
                showCursor(true,true)
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
        imgui.Begin(u8"Мероприятия", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.Text(u8'Помочь провести мероприятие?')
        if imgui.Button(u8'Да', imgui.ImVec2(125, 25)) then
            secondary_window_state.v = true
            main_window_state.v = false
        end
        imgui.SameLine()
        if imgui.Button(u8'Нет', imgui.ImVec2(125, 25)) then
            main_window_state.v = false
        end
        imgui.End()
    end
    if menu_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2) - 100, (sh/2) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Взаимодействие с игроком", menu_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.Text(u8'Что сделать с игроком ' .. sampGetPlayerNickname(id) .. '?')
        if imgui.Button(u8'Заспавнить', imgui.ImVec2(200, 30)) then
            sampSendChat('/aspawn ' .. id)
        end
        if imgui.Button(u8'Нарушение правил мероприятий', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 300 Нарушение правил МП')
            showCursor(false,false)
            menu_window_state.v = false
        end
        if imgui.Button(u8'Срыв мероприятия', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 3000 Срыв мероприятия')
            showCursor(false,false)
            menu_window_state.v = false
        end
        if imgui.Button(u8'Выдать приз', imgui.ImVec2(200, 30)) then
            sampSendChat('/mess 7 Победитель мероприятия - ' .. sampGetPlayerNickname(id) .. '[' .. id .. ']' .. ' поздравим его!')
            sampSendChat('/mpwin ' .. id)
            sampSetChatInputText('/spp')
            sampSetChatInputEnabled(true)
            setVirtualKeyDown(13, true)
            setVirtualKeyDown(13, false)
            sampSendChat('/az')
            sampSendChat('/delcarall')
            showCursor(false,false)
            thisScript:reload()
        end
        if corol_window_state.v or sportzal_window_state.v then
            if not player1 then
                if imgui.Button(u8'Сохранить 1-ого игрока', imgui.ImVec2(200, 30)) then
                    player1 = id
                    showCursor(false,false)
                    menu_window_state.v = false
                end
            end
            if not player2 then
                if imgui.Button(u8'Сохранить 2-ого игрока', imgui.ImVec2(200, 30)) then
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
        imgui.Begin(u8"Выбери мероприятие", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        if imgui.Button(u8'Русская рулетка', imgui.ImVec2(230, 30)) then
            russkaya_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Король дигла', imgui.ImVec2(230, 30)) then
            corol_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Поливалка', imgui.ImVec2(230, 30)) then
            poliv_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Прятки', imgui.ImVec2(230, 30)) then
            pryatki_window_state.v = true
            secondary_window_state.v = false
        end
        if imgui.Button(u8'Бокс', imgui.ImVec2(230, 30)) then
            sportzal_window_state.v = true
            secondary_window_state.v = false
        end
        imgui.End()
    end
    if russkaya_window_state.v then
   --     imgui.SetNextWindowSize(imgui.ImVec2(250, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Русская рулетка", russkaya_window_state, imgui.WindowFlags.NoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Активация курсора - колесико мыши')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Ожидайте...', -1)
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
                    sampSendDialogResponse(5344, 1, _, 'Русская Рулетка')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Русская Рулетка, для телепорта вводи /tpmp')
                    sampSendChat('/mess 7 Поторопись, телепорт скоро закроется! Вводи /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(230, 30)) then
                sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать на Русской Рулетке, вводи /tpmp')
            end
            if imgui.Button(u8'Объявить правила', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
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
                if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(230, 30)) then
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
                if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(230, 30)) then
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
                if imgui.Button(u8'Закончить МП досрочно', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    sbor = false
                    main_window_state.v = false
                    secondary_window_state.v = false
                    menu_window_state.v = false
                    russkaya_window_state.v = false
                    sportzal_window_state.v = false
                    poliv_window_state.v = false
                    pryatki_window_state.v = false
                    corol_window_state.v = false
                    mp = false
                    imgui.Process = false
                end
            end)
        end
        if isKeyJustPressed(VK_MBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
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
        imgui.Begin(u8"Король Дигла", corol_window_state, imgui.WindowFlags.NoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Удостоверьтесь, что у вас включена админ-зона')
            imgui.Text(u8'Включить её можно в /mp - настройки - 1')
            imgui.Text(u8'Активация курсора - колесико мыши')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Ожидайте...', -1)
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
                    sampSendDialogResponse(5344, 1, _, 'Король дигла')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Король дигла, для телепорта вводи /tpmp')
                    sampSendChat('/mess 7 Поторопись, телепорт скоро закроется! Вводи /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(280, 30)) then
                sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в мероприятии Король Дигла, вводи /tpmp')
            end
            if imgui.Button(u8'Объявить правила', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
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
                if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(280, 30)) then
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
                if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(280, 30)) then
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
                if imgui.Button(u8'Поделить всех на команды', imgui.ImVec2(280, 30)) then
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
                if imgui.Button(u8'Телепортировать 1-ого игрока', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player1)
                end
            end
            if player2 then
                if imgui.Button(u8'Телепортировать 2-ого игрока', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player2)
                end
            end
            lua_thread.create(function()
                if player1 and player2 then
                    if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                        sampSendChat('/mess 3 На арену выходят игроки ' .. sampGetPlayerNickname(player1) .. ' и ' .. sampGetPlayerNickname(player2))
                        sampSendChat('/mess 3 Начинаю отсчет в 10 секунд, после него можно начинать огонь!')
                        sampSendChat('/dmcount 10')
                        player1 = nil
                        player2 = nil
                    end
                else
                    if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                        sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:Нажми правой кнопкой мыши на желаемого игрока и добавь его в скрипт', -1)
                        sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:Сделай также со вторым игроком, только после этого нажимай кнопку.', -1)
                    end
                end
            end)
            lua_thread.create(function()
                if imgui.Button(u8'Закончить МП досрочно', imgui.ImVec2(280, 30)) then
                    showCursor(false,false)
                    sbor = false
                    main_window_state.v = false
                    secondary_window_state.v = false
                    menu_window_state.v = false
                    russkaya_window_state.v = false
                    sportzal_window_state.v = false
                    poliv_window_state.v = false
                    pryatki_window_state.v = false
                    corol_window_state.v = false
                    mp = false
                    imgui.Process = false
                end
            end)
        end
        if isKeyJustPressed(VK_MBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
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
        imgui.Begin(u8"Поливалка", poliv_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Активация курсора - колесико мыши')
            imgui.Text(u8'Наказать игрока - команда /jm')
            imgui.Text(u8'Скрипт сделает все сам, вам только жать кнопки.')
            imgui.Text(u8'Закройте диалоги чтобы скрипт сам сделал телепорт.')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Ожидайте...', -1)
                    while sampIsDialogActive() do
                        wait(0)
                        sampCloseCurrentDialogWithButton(0)
                    end
                    sampSendChat('/tpcor 1575.5280761719 -1238.5983886719 277.87603759766 0 999')
                    wait(500)
                    sampSendChat('/tpcor 1575.5280761719 -1238.5983886719 277.87603759766 0 999')
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
                    sampSendDialogResponse(5344, 1, _, 'Поливалка')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Поливалка, для телепорта вводи /tpmp')
                    sampSendChat('/mess 7 Поторопись, телепорт скоро закроется! Вводи /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(230, 30)) then
                sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в мероприятии Поливалка, вводи /tpmp')
            end
            if imgui.Button(u8'Объявить правила', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/veh 601 1 1')
                    while getClosestCarId() == '-1' do
                        wait(0)
                    end
                    wait(2000)
                    sampSendChat('/entercar ' .. getClosestCarId())
                    sampSendChat('/mess 7 Разбегаемся!')
                    sampSendChat('/dmcount 5')
                    sampSendChat('/s')
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:ПОЗИЦИЯ БЫЛА СОХРАНЕНА, ЕСЛИ УПАДЁТЕ ИСПОЛЬЗУЙТЕ /r', -1)
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:ПОЗИЦИЯ БЫЛА СОХРАНЕНА, ЕСЛИ УПАДЁТЕ ИСПОЛЬЗУЙТЕ /r', -1)
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:ПОЗИЦИЯ БЫЛА СОХРАНЕНА, ЕСЛИ УПАДЁТЕ ИСПОЛЬЗУЙТЕ /r', -1)
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
                if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(230, 30)) then
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
                if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(230, 30)) then
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
                if imgui.Button(u8'Закончить МП досрочно', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    sbor = false
                    main_window_state.v = false
                    secondary_window_state.v = false
                    menu_window_state.v = false
                    russkaya_window_state.v = false
                    sportzal_window_state.v = false
                    poliv_window_state.v = false
                    pryatki_window_state.v = false
                    corol_window_state.v = false
                    mp = false
                    imgui.Process = false
                end
            end)
        end
        if isKeyJustPressed(VK_MBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
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
        imgui.Begin(u8"Прятки", pryatki_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Активация курсора - колесико мыши')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Ожидайте...', -1)
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
                    sampSendDialogResponse(5344, 1, _, 'Прятки')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Прятки, для телепорта вводи /tpmp')
                    sampSendChat('/mess 7 Поторопись, телепорт скоро закроется! Вводи /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(230, 30)) then
                sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в Прятках, вводи /tpmp')
            end
            if imgui.Button(u8'Объявить правила', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
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
                if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(230, 30)) then
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
                if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(230, 30)) then
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
                if imgui.Button(u8'Закончить МП досрочно', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    sbor = false
                    main_window_state.v = false
                    secondary_window_state.v = false
                    menu_window_state.v = false
                    russkaya_window_state.v = false
                    sportzal_window_state.v = false
                    poliv_window_state.v = false
                    pryatki_window_state.v = false
                    corol_window_state.v = false
                    mp = false
                    imgui.Process = false
                end
            end)
        end
        if isKeyJustPressed(VK_MBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
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
        imgui.Begin(u8"Король Дигла", sportzal_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Удостоверьтесь, что у вас включена админ-зона')
            imgui.Text(u8'Включить её можно в /mp - настройки - 1')
            imgui.Text(u8'Активация курсора - колесико мыши')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Ожидайте...', -1)
                    while sampIsDialogActive() do
                        wait(0)
                        sampCloseCurrentDialogWithButton(0)
                    end
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 999')
                    wait(400)
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 999')
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
                    sampSendDialogResponse(5344, 1, _, 'Король дигла')
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    sampCloseCurrentDialogWithButton(0)
                    wait(400)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Бокс, для телепорта вводи /tpmp')
                    sampSendChat('/mess 7 Поторопись, телепорт скоро закроется! Вводи /tpmp')
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(280, 30)) then
                sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в мероприятии Бокс, вводи /tpmp')
            end
            if imgui.Button(u8'Объявить правила', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
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
                if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(280, 30)) then
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
                if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(280, 30)) then
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
                if imgui.Button(u8'Поделить всех на команды', imgui.ImVec2(280, 30)) then
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
                if imgui.Button(u8'Телепортировать 1-ого игрока', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player1)
                end
            end
            if player2 then
                if imgui.Button(u8'Телепортировать 2-ого игрока', imgui.ImVec2(280, 30)) then
                    sampSendChat('/gethere ' .. player2)
                end
            end
            lua_thread.create(function()
                if player1 and player2 then
                    if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                        sampSendChat('/mess 3 На арену выходят игроки ' .. sampGetPlayerNickname(player1) .. ' и ' .. sampGetPlayerNickname(player2))
                        sampSendChat('/mess 3 Начинаю отсчет в 10 секунд, после него можно начинать.')
                        sampSendChat('/dmcount 10')
                        player1 = nil
                        player2 = nil
                    end
                else
                    if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                        sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:Нажми правой кнопкой мыши на желаемого игрока и добавь его в скрипт', -1)
                        sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}:Сделай также со вторым игроком, только после этого нажимай кнопку.', -1)
                    end
                end
            end)
            if imgui.Button(u8'Телепортироваться на ринг', imgui.ImVec2(280, 30)) then
                if not sampIsDialogActive() then
                    sampSendChat('/tpcor 759.23474121094 12.783633232117 1001.1639404297 5 999')
                else
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Закройте диалог')
                end
            end
            if imgui.Button(u8'Телепортироваться вне ринга', imgui.ImVec2(280, 30)) then
                if not sampIsDialogActive() then
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 999')
                else
                    sampAddChatMessage('{FF0000}RDS Tools{FFFFFF}: Закройте диалог')
                end
            end
            lua_thread.create(function()
                if imgui.Button(u8'Закончить МП досрочно', imgui.ImVec2(230, 30)) then
                    showCursor(false,false)
                    sbor = false
                    main_window_state.v = false
                    secondary_window_state.v = false
                    menu_window_state.v = false
                    russkaya_window_state.v = false
                    sportzal_window_state.v = false
                    poliv_window_state.v = false
                    pryatki_window_state.v = false
                    corol_window_state.v = false
                    mp = false
                    imgui.Process = false
                end
            end)
        end
        if isKeyJustPressed(VK_MBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() then
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
            sampSendDialogResponse(dialogId, 1, _, tonumber('999'))
        end
        if dialogId == 16068 and imgui.Process then
            sampSendDialogResponse(dialogId, 1, _, tonumber('0'))
        end
    end)
end

function getClosestCarId() -- узнать ид ближащего авто
    local minDist = 200 -- дистанция
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

function style() -- СТИЛЬ ИМГУИ
    imgui.SwitchContext()
    local style  = imgui.GetStyle()
    local colors = style.Colors
    local clr    = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding       = ImVec2(10, 10)
    style.WindowRounding      = 10
    style.ChildWindowRounding = 2
    style.FramePadding        = ImVec2(5, 4)
    style.FrameRounding       = 11
    style.ItemSpacing         = ImVec2(4, 4)
    style.TouchExtraPadding   = ImVec2(0, 0)
    style.IndentSpacing       = 21
    style.ScrollbarSize       = 16
    style.ScrollbarRounding   = 16
    style.GrabMinSize         = 11
    style.GrabRounding        = 16
    style.WindowTitleAlign    = ImVec2(0.5, 0.5)
    style.ButtonTextAlign     = ImVec2(0.5, 0.5)

    colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
    colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
    colors[clr.ChildWindowBg]        = ImVec4(10.00, 10.00, 10.00, 0.01)
    colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
    colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.FrameBg]              = ImVec4(0.00, 0.39, 1.00, 0.65)
    colors[clr.FrameBgHovered]       = ImVec4(0.11, 0.40, 0.69, 1.00)
    colors[clr.FrameBgActive]        = ImVec4(0.11, 0.40, 0.69, 1.00)
    colors[clr.TitleBg]              = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]        = ImVec4(0.00, 0.24, 0.54, 1.00)
    colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.22, 1.00, 0.67)
    colors[clr.MenuBarBg]            = ImVec4(0.08, 0.44, 1.00, 1.00)
    colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
    colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.SliderGrab]           = ImVec4(0.34, 0.67, 1.00, 1.00)
    colors[clr.SliderGrabActive]     = ImVec4(0.84, 0.66, 0.66, 1.00)
    colors[clr.Button]               = ImVec4(0.00, 0.39, 1.00, 0.65)
    colors[clr.ButtonHovered]        = ImVec4(0.00, 0.64, 1.00, 0.65)
    colors[clr.ButtonActive]         = ImVec4(0.00, 0.53, 1.00, 0.50)
    colors[clr.Header]               = ImVec4(0.00, 0.62, 1.00, 0.54)
    colors[clr.HeaderHovered]        = ImVec4(0.00, 0.36, 1.00, 0.65)
    colors[clr.HeaderActive]         = ImVec4(0.00, 0.53, 1.00, 0.00)
    colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.SeparatorHovered]     = ImVec4(0.71, 0.39, 0.39, 0.54)
    colors[clr.SeparatorActive]      = ImVec4(0.71, 0.39, 0.39, 0.54)
    colors[clr.ResizeGrip]           = ImVec4(0.71, 0.39, 0.39, 0.54)
    colors[clr.ResizeGripHovered]    = ImVec4(0.84, 0.66, 0.66, 0.66)
    colors[clr.ResizeGripActive]     = ImVec4(0.84, 0.66, 0.66, 0.66)
    colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
end
style()