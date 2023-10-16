require 'lib.moonloader'
script_name 'AT_MP' 
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local imgui = require 'imgui'
local version = 1.2
local imadd = require 'imgui_addons'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local font = require ("moonloader").font_flag
local sw, sh = getScreenResolution()
local text_buffer = imgui.ImBuffer(256)
local text_myprize = imgui.ImBuffer(256)
local tag = '{FF0000}MP{F0E68C}: '
local directIni = 'AT//AT_MP.ini'
local anticrashmp = false
local cfg2 = inicfg.load({
    settings = {
        versionMP = version,
        wallhack = true,
        style = 0,
    },
}, 'AT//AT_main.ini')
inicfg.save(cfg2, 'AT//AT_main.ini')
local cfg = inicfg.load({
    AT_MP = {
        adminstate = false,
        mynick = false,
        data = false,
        myreports = false,
        myonline = false,
        warningban = false,
        warningjail = false,
        warningmute = false,
        warningkick = false,
        staticposX = 20,
        staticposY = sh - 200,
        style = 0,
        wallhack = true,
    },
    info = {
        0, -- myreport
        0, -- myban
        0, -- mymute
        0, -- myjail
        0, -- mykick
        0, -- myonline
    },
}, 'AT//AT_MP.ini')
inicfg.save(cfg,'AT//AT_MP.ini')
local style_selected = imgui.ImInt(cfg2.settings.style) -- Берём стандартное значение стиля из конфига

local checkbox = {
    check_1 = imgui.ImBool(cfg.AT_MP.adminstate),
    check_2 = imgui.ImBool(cfg.AT_MP.mynick),
    check_3 = imgui.ImBool(cfg.AT_MP.data),
    check_4 = imgui.ImBool(cfg.AT_MP.myreports),
    check_5 = imgui.ImBool(cfg.AT_MP.myonline),
    check_6 = imgui.ImBool(cfg.AT_MP.warningban),
    check_7 = imgui.ImBool(cfg.AT_MP.warningmute),
    check_8 = imgui.ImBool(cfg.AT_MP.warningjail),
    check_9 = imgui.ImBool(cfg.AT_MP.warningkick),
    check_10 = imgui.ImBool(anticrashmp),
}
local windows = {
    main_window_state = imgui.ImBool(false),
    menu_window_state = imgui.ImBool(false),
    secondary_window_state = imgui.ImBool(false),
    russkaya_window_state = imgui.ImBool(false),
    corol_window_state = imgui.ImBool(false),
    poliv_window_state = imgui.ImBool(false),
    pryatki_window_state = imgui.ImBool(false),
    sportzal_window_state = imgui.ImBool(false),
    stata_window_state = imgui.ImBool(false),
    static_window_state = imgui.ImBool(false)
}
function main()
    while not isSampAvailable() do wait(0) end
    cfg2.settings.versionMP = version
    inicfg.save(cfg2, 'AT//AT_main.ini')
    while not sampIsLocalPlayerSpawned() do wait(1000) end
    _, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) 
    func1 = lua_thread.create_suspended(time)
    func2 = lua_thread.create_suspended(radius)
    func3 = lua_thread.create_suspended(find_weapon)
    func1:run()
    if cfg.AT_MP.adminstate then
        windows.stata_window_state.v = true
        imgui.Process = true
    end
    if cfg.info.data ~= os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year then
        cfg.info.data = os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year
        for i = 0, #cfg.info do
            cfg.info[i] = 0
        end
    end
    writeMemory(sampGetBase() + 0x9D9D0, 4, 0x5051FF15, true)
    while true do
        wait(0)
        if isKeyJustPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
            result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
            if result and imgui.Process then
                _, id = sampGetPlayerIdByCharHandle(ped)
                windows.menu_window_state.v = true
                showCursor(true,false)
            end
        end
    end
end

function sampev.onServerMessage(color,text)
    if mynick then
        if text:match('%[(%d+)%] ответил (.*)%[(%d+)%]: (.*)') and text:match(mynick) then
            cfg.info[0] = cfg.info[0] + 1
            save() 
        end
        if text:match('Администратор .+ забанил%(.+%) игрока .+ на .+ дней. Причина: .+') and text:match(mynick) then
            cfg.info[1] = cfg.info[1] + 1
            save()
        end
        if text:match("Администратор .+ заткнул%(.+%) игрока .+ на .+ секунд. Причина: .+") and text:match(mynick) then
            cfg.info[2] = cfg.info[2] + 1
            save()
        end
        if text:find("Администратор .+ посадил%(.+%) игрока .+ в тюрьму на .+ секунд. Причина: .+") and text:match(mynick) then
            cfg.info[3] = cfg.info[3] + 1
            save()
        end
        if text:find("Администратор .+ кикнул игрока .+. Причина: .+") and text:match(mynick) then
            cfg.info[4] = cfg.info[4] + 1
            save()
        end
    end
end
function imgui.OnDrawFrame()
    if not windows.main_window_state.v and not windows.static_window_state.v and not windows.secondary_window_state.v and not windows.russkaya_window_state.v and not windows.stata_window_state.v and not windows.menu_window_state.v and not windows.corol_window_state.v and not windows.poliv_window_state.v and not windows.pryatki_window_state.v and not windows.sportzal_window_state.v then
        if cfg.AT_MP.adminstate then
            windows.stata_window_state.v = true
        else
            imgui.Process = false
        end
    end
    if windows.static_window_state.v then
        windows.stata_window_state.v = false
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(sw*0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Статистика", windows.static_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        if imadd.ToggleButton('##activerstate', checkbox.check_1) then
            cfg.AT_MP.adminstate = not cfg.AT_MP.adminstate
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'Вкл/Выкл')
        imgui.Text(u8'Выберите пункты')
        if imadd.ToggleButton('##mynick', checkbox.check_2) then
            cfg.AT_MP.mynick = not cfg.AT_MP.mynick
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'Мой ник')
        imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##date', checkbox.check_3) then
            cfg.AT_MP.data = not cfg.AT_MP.data
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'Дата')
        if imadd.ToggleButton('##myreport', checkbox.check_4) then
            cfg.AT_MP.myreports = not cfg.AT_MP.myreports
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'Репорты за день')
        imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##myonline', checkbox.check_5) then
            cfg.AT_MP.myonline = not cfg.AT_MP.myonline
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'Онлайн за день')
        if imadd.ToggleButton('##ban', checkbox.check_6) then
			cfg.AT_MP.warningban = not cfg.AT_MP.warningban
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'Баны за день')
        imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##mute', checkbox.check_7) then
            cfg.AT_MP.warningmute = not cfg.AT_MP.warningmute
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'Муты за день')
		if imadd.ToggleButton('##jail', checkbox.check_8) then
            cfg.AT_MP.warningjail = not cfg.AT_MP.warningjail
            save()
        end
		imgui.SameLine()
        imgui.Text(u8'Джайлы за день')
		imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##kick', checkbox.check_9) then
            cfg.AT_MP.warningkick = not cfg.AT_MP.warningkick
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'Киков за день')
        if imgui.Button(u8'Сохранить позицию') then
			cfg.AT_MP.staticposX = imgui.GetWindowPos().x
			cfg.AT_MP.staticposY = imgui.GetWindowPos().y
			save()
            showCursor(false,false)
            thisScript():reload()
        end
        windows.stata_window_state.v = false -- вырубаем статистику чтобы не было бага с мышью
        imgui.End()
    end
    if windows.stata_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.AT_MP.staticposX, cfg.AT_MP.staticposY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("##AdminStata", windows.stata_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.ShowCursor = false
        for i = 0, #cfg.info do
            if i == 0 then
                if cfg.AT_MP.mynick then
                    imgui.Text(mynick .. ' ('..myid ..')')
                end
                if cfg.AT_MP.data then
                    imgui.Text(os.date('%H:%M | ') .. os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year)
                end
                if cfg.AT_MP.myreports then
                    imgui.Text(u8'Репортов: ' .. cfg.info[0])
                end
            elseif cfg.AT_MP.warningban and i == 1 then
                imgui.Text(u8'Банов: ' .. cfg.info[1])
            elseif cfg.AT_MP.warningmute and i == 2 then
                imgui.Text(u8'Мутов: ' .. cfg.info[2])
            elseif cfg.AT_MP.warningjail and i == 3 then
                imgui.Text(u8'Джайлов: ' .. cfg.info[3])
            elseif cfg.AT_MP.warningkick and i == 4 then
                imgui.Text(u8'Киков: ' .. cfg.info[4])
            elseif cfg.AT_MP.myonline and i == 5 then
                imgui.Text(u8'Онлайн: ' .. cfg.info[5] .. u8' мин.')
            end
        end
        imgui.End()
    end
    if windows.main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Мероприятия", windows.main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.Text(u8'Помочь провести мероприятие?')
        if imgui.Button(u8'Да', imgui.ImVec2(125, 25)) then
            windows.secondary_window_state.v = true
            windows.main_window_state.v = false
        end
        imgui.SameLine()
        if imgui.Button(u8'Нет', imgui.ImVec2(125, 25)) then
            windows.main_window_state.v = false
        end
        imgui.End()
    end
    if windows.menu_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2) - 100, (sh/2) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Взаимодействие с игроком", windows.menu_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.Text(u8'Что сделать с игроком\n' .. sampGetPlayerNickname(id) .. '?')
        if imgui.Button(u8'Заспавнить', imgui.ImVec2(200, 30)) then
            sampSendChat('/aspawn ' .. id)
        end
        if imgui.Button(u8'Нарушение правил мероприятий', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 300 Нарушение правил МП')
            showCursor(false,false)
            windows.menu_window_state.v = false
        end
        if imgui.Button(u8'Срыв мероприятия', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 3000 Срыв мероприятия')
            showCursor(false,false)
            windows.menu_window_state.v = false
        end
        if imgui.Button(u8'Выдать приз', imgui.ImVec2(200, 30)) then
            lua_thread.create(function()
                windows.menu_window_state.v = false
                sampSendChat('/mess 7 Победитель мероприятия - ' .. sampGetPlayerNickname(id) .. '[' .. id .. ']' .. ' поздравим его!')
                wait(700)
                sampSendChat('/mpwin ' .. id)
                wait(700)
                _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                sampSendChat('/tweap ' .. myid)
                sampSendChat('/az')
                wait(700)
                sampSendChat('/delcarall')
                showCursor(false,false)
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    lua_thread.create(function()
                        wait(2000)
                        sampShowDialog(6405, "Выдать вознаграждение", "Пример: /giverub id 300\n/givescore 24 500000", "Выдать", nil, DIALOG_STYLE_INPUT) -- сам диалог
                        while sampIsDialogActive(6405) do wait(300) end -- ждёт пока вы ответите на диалог
                        local result, button, _, input = sampHasDialogRespond(6405)
                        if input then
                            sampSendChat(input)
                        end
                        wait(700)
                        sampSendInputChat('/spp')
                        thisScript():reload()
                    end)
                else
                    wait(700)
                    sampSendInputChat('/spp')
                    thisScript():reload()
                end
            end)
        end
        if windows.corol_window_state.v or windows.sportzal_window_state.v then
            if not player1 then
                if imgui.Button(u8'Сохранить 1-ого игрока', imgui.ImVec2(200, 30)) then
                    player1 = id
                    showCursor(false,false)
                    windows.menu_window_state.v = false
                end
            end
            if not player2 then
                if imgui.Button(u8'Сохранить 2-ого игрока', imgui.ImVec2(200, 30)) then
                    player2 = id
                    showCursor(false,false)
                    windows.menu_window_state.v = false
                end
            end
        end
        imgui.End()
    end
    if windows.secondary_window_state.v then
     --   imgui.SetNextWindowSize(imgui.ImVec2(250, 170), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Выбери мероприятие", windows.secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        if imgui.Button(u8'Русская рулетка', imgui.ImVec2(230, 30)) then
            windows.russkaya_window_state.v = true
            windows.secondary_window_state.v = false
        end
        if imgui.Button(u8'Король дигла', imgui.ImVec2(230, 30)) then
            windows.corol_window_state.v = true
            windows.secondary_window_state.v = false
        end
        if imgui.Button(u8'Поливалка', imgui.ImVec2(230, 30)) then
            windows.poliv_window_state.v = true
            windows.secondary_window_state.v = false
        end
        if imgui.Button(u8'Прятки', imgui.ImVec2(230, 30)) then
            windows.pryatki_window_state.v = true
            windows.secondary_window_state.v = false
        end
        if imgui.Button(u8'Бокс', imgui.ImVec2(230, 30)) then
            windows.sportzal_window_state.v = true
            windows.secondary_window_state.v = false
        end
        imgui.InputTextMultiline("##Текст оглашения приза", text_myprize, imgui.ImVec2(230,25))
        imgui.Tooltip(u8('Приз данного мероприятия составит ' .. u8:decode(text_myprize.v) .. '. Телепорт ещё открыт! /tpmp'))
        if imadd.ToggleButton('##find_weapon', checkbox.check_10) then
            if anticrashmp then
                anticrashmp = false
                func3:terminate()
            else
                anticrashmp = true
                func3:run()
            end
        end
        imgui.SameLine()
        imgui.Text(u8'Анти-срыв мероприятия')
        imgui.SameLine()
        imgui.Text('(?)')
        imgui.Tooltip(u8'Скрипт ищет у игроков в радиусе оружие\nЕсли кто-то берет в руки оружие - автоматически наказан.\nНе рекомендуется если проводить мп с кем-то\nИли хотите проводите король дигла.')
        imgui.End()
    end
    if windows.russkaya_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("russkaya roulette", windows.russkaya_window_state, imgui.WindowFlags.NoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'ВАЖНО! Активация/деактивация курсора - F')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage(tag .. 'Ожидайте...', -1)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 8, nil)
                    wait(1000)
                    sampSendDialogResponse(5343, 1, 8, nil)
                    sampSendDialogResponse(5343, 1, 14, nil)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(1)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Русская Рулетка')
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Русская Рулетка, для телепорта вводи /tpmp')
                    wait(700)
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess 12 Приз данного мероприятия составит ' .. u8:decode(text_myprize.v) .. '. Телепорт ещё открыт! /tpmp')
                    end
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(230, 30)) then
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    sampSendChat('/mess 7 Телепорт на мероприятие всё ещё открыт! Приз: ' .. u8:decode(text_myprize.v) .. '. вводи /tpmp!')
                else
                    sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать на Русской Рулетке, вводи /tpmp')
                end
            end
            if imgui.Button(u8'Начать мероприятие', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Правила мероприятия Русская Рулетка!')
                    wait(700)
                    sampSendChat('/mess 7 /try удачно - убит, /try неудачно - жив. Побеждает самый везучий.')
                    wait(700)
                    sampSendChat('/mess 7 Запрещено: /passive, /fly, /gt, DM, /s /r /anim /jp, выходить из строя и любая другая помеха игрокам.')
                    wait(1000)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSendInputChat('/stw ' .. myid)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
            if imgui.Button(u8'Прекратить набор', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    thisScript():reload()
                end)
            end
        end
        if mp then
            if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Завершить МП досрочно', imgui.ImVec2(230, 30)) then
                showCursor(false,false)
                showCursor(false,false)
                thisScript():reload()
            end
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,false)
                cursor = true
            end
        end
        imgui.End()
    end
    if windows.corol_window_state.v then
      --  imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('korol deagle', windows.corol_window_state, imgui.WindowFlags.NoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Удостоверьтесь, что у вас включена админ-зона')
            imgui.Text(u8'Включить её можно в /mp - настройки - 1')
            imgui.Text(u8'ВАЖНО! Активация/деактивация курсора - F')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage(tag .. 'Ожидайте...', -1)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 4, nil)
                    wait(700)
                    sampSendDialogResponse(5343, 1, 4, nil)
                    wait(700)
                    sampSendDialogResponse(5343, 1, 14, nil)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(1)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Король дигла')
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Король дигла, для телепорта вводи /tpmp')
                    wait(700)
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess 12 Приз данного мероприятия составит ' .. u8:decode(text_myprize.v) .. '. Телепорт ещё открыт! /tpmp')
                    end
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(280, 30)) then
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    sampSendChat('/mess 7 Телепорт на мероприятие всё ещё открыт! Приз: ' .. u8:decode(text_myprize.v) .. '. вводи /tpmp!')
                else
                    sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в мероприятии Король Дигла, вводи /tpmp')
                end
            end
            if imgui.Button(u8'Начать мероприятие', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Правила мероприятия Король Дигла!')
                    wait(700)
                    sampSendChat('/mess 7 Я вызываю двух человек, которые начинают стреляться по моей команде, побеждает сильнейший')
                    wait(700)
                    sampSendChat('/mess 7 Запрещены: /passive, /fly, /gt, DM, /s /r /anim /jp и любая другая помеха игрокам.')
                    wait(1000)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSendInputChat('/stw')
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
            if imgui.Button(u8'Прекратить набор', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    thisScript():reload()
                end)
            end
        end
        if mp then
            if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Поделить всех на команды', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 15, nil)
                    wait(700)
                    sampSendDialogResponse(16075 , 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
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
            if player1 and player2 then
                if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                    sampSendChat('/mess 3 На арену выходят игроки ' .. sampGetPlayerNickname(player1) .. ' и ' .. sampGetPlayerNickname(player2))
                    wait(700)
                    sampSendChat('/mess 3 Начинаю отсчет в 10 секунд, после него можно начинать огонь!')
                    wait(700)
                    sampSendChat('/dmcount 10')
                    player1 = nil
                    player2 = nil
                end
            else
                if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                    sampAddChatMessage(tag .. ' Нажми правой кнопкой мыши + 1 на желаемого игрока и добавь его в скрипт', -1)
                    sampAddChatMessage(tag .. ' Сделай также со вторым игроком, только после этого нажимай кнопку.', -1)
                end
            end
            if imgui.Button(u8'Завершить МП досрочно', imgui.ImVec2(280, 30)) then
                showCursor(false,false)
                thisScript():reload()
            end
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,false)
                cursor = true
            end
        end
        imgui.End()
    end
    if windows.poliv_window_state.v then
        imgui.SetNextWindowSize(imgui.ImVec2(250, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin('polivalka', windows.poliv_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'ВАЖНО! Активация/деактивация курсора - F')
            imgui.Text(u8'Наказать игрока - команда /jm')
            imgui.Text(u8'Скрипт сделает все сам, вам только жать кнопки.')
            imgui.Text(u8'Закройте диалоги чтобы скрипт сам сделал телепорт.')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage(tag .. ' Ожидайте...', -1)
                    while sampIsDialogActive() do
                        wait(0)
                        sampCloseCurrentDialogWithButton(0)
                    end
                    sampSendChat('/tpcor 1575.5280761719 -1238.5983886719 277.87603759766 0 990')
                    wait(700)
                    sampSendChat('/tpcor 1575.5280761719 -1238.5983886719 277.87603759766 0 990')
                    wait(2000)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 14, nil)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(1)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Поливалка')
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Поливалка, для телепорта вводи /tpmp')
                    wait(700)
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess 12 Приз данного мероприятия составит ' .. u8:decode(text_myprize.v) .. '. Телепорт ещё открыт! /tpmp')
                    end
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(230, 30)) then
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    sampSendChat('/mess 7 Телепорт на мероприятие всё ещё открыт! Приз: ' .. u8:decode(text_myprize.v) .. '. вводи /tpmp!')
                else
                    sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в мероприятии Поливалка, вводи /tpmp')
                end
            end
            if imgui.Button(u8'Начать мероприятие', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Правила мероприятия Поливалка!')
                    wait(700)
                    sampSendChat('/mess 7 Вы разбегаетесь по всей крыше, я пытаюсь вас сбить, последний выживший - побеждает')
                    wait(700)
                    sampSendChat('/mess 7 Запрещены: /passive, /fly, /gt, DM, /s /r /anim /jp и любая другая помеха игрокам.')
                    wait(700)
                    sampSendChat('/veh 601 1 1')
                    while getClosestCarId() == '-1' do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Разбегаемся!')
                    wait(700)
                    sampSendChat('/s')
                    wait(700)
                    sampSendChat('/dmcount 8')
                    wait(2000)
                    sampSendChat('/entercar ' .. getClosestCarId())
                    wait(700)
                    sampAddChatMessage(tag .. 'ПОЗИЦИЯ БЫЛА СОХРАНЕНА, ЕСЛИ УПАДЁТЕ ИСПОЛЬЗУЙТЕ /r', -1)
                    sampAddChatMessage(tag .. 'ПОЗИЦИЯ БЫЛА СОХРАНЕНА, ЕСЛИ УПАДЁТЕ ИСПОЛЬЗУЙТЕ /r', -1)
                    sampAddChatMessage(tag .. 'ПОЗИЦИЯ БЫЛА СОХРАНЕНА, ЕСЛИ УПАДЁТЕ ИСПОЛЬЗУЙТЕ /r', -1)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    wait(700)
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
            if imgui.Button(u8'Прекратить набор', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    thisScript():reload()
                end)
            end
        end
        if mp then
            if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Завершить МП досрочно', imgui.ImVec2(230, 30)) then
                showCursor(false,false)
                thisScript():reload()
            end
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,false)
                cursor = true
            end
        end
        imgui.End()
    end
    if windows.pryatki_window_state.v then
        --     imgui.SetNextWindowSize(imgui.ImVec2(250, 120), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("pryatki", windows.pryatki_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize+ imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'ВАЖНО! Активация/деактивация курсора - F')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage(tag .. ' Ожидайте...', -1)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 5, nil)
                    wait(700)
                    sampSendDialogResponse(5343, 1, 5, nil)
                    wait(700)
                    sampSendDialogResponse(5343, 1, 14, nil)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(1)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Прятки')
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Прятки, для телепорта вводи /tpmp')
                    wait(700)
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess 12 Приз данного мероприятия составит ' .. u8:decode(text_myprize.v) .. '. Телепорт ещё открыт! /tpmp')
                     end
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(230, 30)) then
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    sampSendChat('/mess 7 Телепорт на мероприятие всё ещё открыт! Приз: ' .. u8:decode(text_myprize.v) .. '. вводи /tpmp!')
                else
                    sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в Прятках, вводи /tpmp')
                end
            end
            if imgui.Button(u8'Начать мероприятие', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Правила мероприятия Прятки!')
                    wait(700)
                    sampSendChat('/mess 7 Вы разбегаетесь по всему кораблю, я отправляюсь на ваши поиски, побеждает последний выживший.')
                    wait(700)
                    sampSendChat('/mess 7 Запрещены: /passive, /fly, /gt, DM, /s /r /anim /jp и любая другая помеха игрокам.')
                    wait(1000)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSendInputChat('/stw ' .. myid)
                    wait(700)
                    mp = true
                    sampSendChat('/dmcount 3')
                    wait(700)
                    sampAddChatMessage(tag .. 'ВЫКЛЮЧИТЕ ХУД, НАЖАВ F7',-1)
                    if cfg2.settings.wallhack then
                        sampSendChat('/wh')
                    end
                    func2:run()
                    showCursor(false,false)
                    sbor = false
                end)
            end
            if imgui.Button(u8'Прекратить набор', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do wait(0) end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    thisScript():reload()
                end)
            end
        end
        if mp then
            if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Завершить МП досрочно', imgui.ImVec2(230, 30)) then
                showCursor(false,false)
                thisScript():reload()
            end
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,false)
                cursor = true
            end
        end
        imgui.End()
    end
    if windows.sportzal_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2)+(sw/3) - 50, (sh/2) - (sh/3) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("box", windows.sportzal_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        if not sbor and not mp then
            imgui.Text(u8'Удостоверьтесь, что у вас включена админ-зона')
            imgui.Text(u8'Включить её можно в /mp - настройки - 1')
            imgui.Text(u8'ВАЖНО! Активация/деактивация курсора - F')
            imgui.Text(u8'Взаимодействие с игроками:')
            imgui.Text(u8'Правая кнопка мыши + 1')
            if imgui.Button(u8'Начать сбор игроков', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampAddChatMessage(tag .. ' Ожидайте...', -1)
                    while sampIsDialogActive() do
                        wait(0)
                        sampCloseCurrentDialogWithButton(0)
                    end
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 990')
                    wait(700)
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 990')
                    wait(700)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 14, nil)
                    sampSendDialogResponse(16066, 1, 1, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(1)
                    wait(700)
                    sampSendDialogResponse(16066, 1, 2, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    while not sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendDialogResponse(5344, 1, _, 'Бокс')
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    while sampIsDialogActive() do
                        wait(0)
                    end
                    sampSendChat('/mess 7 Начинается мероприятие Бокс, для телепорта вводи /tpmp')
                    wait(700)
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess 12 Приз данного мероприятия составит ' .. u8:decode(text_myprize.v) .. '. Телепорт ещё открыт! /tpmp')
                    end
                    showCursor(false,false)
                    sbor = true
                end)
            end
        end
        if sbor then
            if imgui.Button(u8'Напомнить про мероприятие', imgui.ImVec2(280, 30)) then
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    sampSendChat('/mess 7 Телепорт на мероприятие всё ещё открыт! Приз: ' .. u8:decode(text_myprize.v) .. '. вводи /tpmp!')
                else
                    sampSendChat('/mess 7 Телепорт всё ещё открыт, у тебя есть шанс поучавствовать в мероприятии Бокс, вводи /tpmp')
                end
            end
            if imgui.Button(u8'Начать мероприятие', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mess 7 Правила мероприятия Бокс!')
                    wait(700)
                    sampSendChat('/mess 7 Я выбираю 2 человек, которые сражаются на ринге, побеждает сильнейший.')
                    wait(700)
                    sampSendChat('/mess 7 Запрещены: /passive, /fly, /gt, DM, /s /r /anim /jp и любая другая помеха игрокам.')
                    wait(1000)
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                    sampSendInputChat('/stw ' .. myid)
                    mp = true
                    showCursor(false,false)
                    sbor = false
                end)
            end
            if imgui.Button(u8'Прекратить набор', imgui.ImVec2(230, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    thisScript():reload()
                end)
            end
        end
        if mp then
            if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 2, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Обеззаружить всех', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 3, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
            if imgui.Button(u8'Поделить всех на команды', imgui.ImVec2(280, 30)) then
                lua_thread.create(function()
                    sampSendChat('/mp')
                    wait(700)
                    while not sampIsDialogActive(5343) do
                        wait(0)
                    end
                    sampSendDialogResponse(5343, 1, 15, nil)
                    wait(700)
                    sampSendDialogResponse(16075 , 1, 0, nil)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                    wait(700)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
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
            if player1 and player2 then
                if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                    lua_thread.create(function()
                        sampAddChatMessage(tag .. 'Выдаю участникам мероприятия здоровье', -1)
                        sampSendChat('/mp')
                        wait(700)
                        while not sampIsDialogActive(5343) do
                            wait(0)
                        end
                        sampSendDialogResponse(5343, 1, 2, nil)
                        wait(700)
                        sampCloseCurrentDialogWithButton(0)
                        sampSendChat('/mess 3 На арену выходят игроки ' .. sampGetPlayerNickname(player1) .. ' и ' .. sampGetPlayerNickname(player2))
                        wait(700)
                        sampSendChat('/mess 3 Начинаю отсчет в 10 секунд, после него можно начинать.')
                        wait(700)
                        sampSendChat('/dmcount 10')
                        player1 = nil
                        player2 = nil
                    end)
                end
            else
                if imgui.Button(u8'Начать PVP', imgui.ImVec2(280, 30)) then
                    sampAddChatMessage(tag .. ' Нажми правой кнопкой мыши + 1 на желаемого игрока и добавь его в скрипт', -1)
                    sampAddChatMessage(tag .. ' Сделай также со вторым игроком, только после этого нажимай кнопку.', -1)
                end
            end
            if imgui.Button(u8'Телепортироваться на ринг', imgui.ImVec2(280, 30)) then
                if not sampIsDialogActive() then
                    sampSendChat('/tpcor 759.23474121094 12.783633232117 1001.1639404297 5 990')
                else
                    sampAddChatMessage(tag .. ' Закройте диалог')
                end
            end
            if imgui.Button(u8'Телепортироваться вне ринга', imgui.ImVec2(280, 30)) then
                if not sampIsDialogActive() then
                    sampSendChat('/tpcor 772.14721679688 5.5412063598633 1000.7802124023 5 990')
                else
                    sampAddChatMessage(tag .. ' Закройте диалог')
                end
            end
            if imgui.Button(u8'Завершить МП досрочно', imgui.ImVec2(280, 30)) then
                showCursor(false,false)
                thisScript():reload()
            end
        end
        if isKeyJustPressed(VK_F) and not sampIsChatInputActive() and not sampIsDialogActive() then
            if cursor then
                cursor = false
                showCursor(false,false)
            else
                showCursor(true,false)
                cursor = true
            end
        end
        imgui.End()
    end
end

function imgui.Tooltip(text)
    if imgui.IsItemHovered() then
       imgui.BeginTooltip() -- подсказка при наведении на кнопку
       imgui.Text(text)
       imgui.EndTooltip()
    end
end
function find_weapon()
    _, myid = sampGetPlayerIdByCharHandle(playerPed)
    while windows.secondary_window_state.v do wait(300) end
    wait(15000)
    while true do
        wait(2000)
        local playerzone = playersToStreamZone()
        for _,v in pairs(playerzone) do
            _, handle = sampGetCharHandleBySampPlayerId(v) 
            if v ~= myid then
                if getCurrentCharWeapon(handle) ~= 0 then
                    sampAddChatMessage(tag .. 'Обнаружена попытка слива мп. Игрок: ' .. sampGetPlayerNickname(v) .. '[' .. v .. ']. Оружие: ' .. (require 'game.weapons').get_name(getCurrentCharWeapon(handle)) , -1)
                    sampSendChat('/jail ' .. v .. ' 300 Оружие на мероприятии')
                end
            end
        end
    end
end

function time()
    while true do
        wait(60000)
        cfg.info[5] = cfg.info[5] + 1
        save()
    end
end
function sampSendInputChat(text) -- отправка в чат через ф6
	sampSetChatInputText(text)
	sampSetChatInputEnabled(true)
	setVirtualKeyDown(13, true)
	setVirtualKeyDown(13, false)
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 5343 and (not windows.main_window_state.v and not windows.secondary_window_state.v and not windows.russkaya_window_state.v and not windows.menu_window_state.v and not windows.corol_window_state.v and not windows.poliv_window_state.v and not windows.pryatki_window_state.v and not windows.sportzal_window_state.v) then
        windows.main_window_state.v = true
        imgui.Process = true
    end
    if dialogId == 16067 and imgui.Process then
        sampSendDialogResponse(dialogId, 1, _, tonumber('990'))
    end
    if dialogId == 16068 and imgui.Process then
        sampSendDialogResponse(dialogId, 1, _, tonumber('0'))
    end
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

function imgui.NewInputText(lable, val, width, hint, hintpos) -- Поле ввода с подсказкой
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function playersToStreamZone() -- игроки в радиусе
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end
function save()
    inicfg.save(cfg,directIni)
end
function radius()
    local font_watermark = renderCreateFont("Javanese Text", 12, font.BOLD + font.BORDER + font.SHADOW)
    while true do
        wait(1)
        renderFontDrawText(font_watermark, 'Игроков в радиусе: ' .. #(playersToStreamZone()) -1 , sh*0.5, sw*0.5, 0xCCFFFFFF)
    end
end

sampRegisterChatCommand('state', function()
    windows.static_window_state.v = not windows.static_window_state.v
    imgui.Process = windows.static_window_state.v
end)
sampRegisterChatCommand('mpoff', function()
    thisScript():unload()
end)

function style(id) -- ТЕМЫ
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
    if id == 0 then -- Темно-Синяя
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
    elseif id == 1 then -- Красная
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
    elseif id == 2 then -- зеленая тема
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
    elseif id == 3 then -- бирюзовая
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
    elseif id == 5 then -- Просто приятная тема
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