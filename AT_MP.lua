require 'lib.moonloader'
script_name 'AT_MP' 
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local imgui = require 'imgui'
local version = 1.74
local imadd = require 'imgui_addons'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local ffi = require "ffi"
local fa = require 'faicons'
encoding.default = 'CP1251' 
local u8 = encoding.UTF8 
local vkeys = require 'vkeys'
local inicfg = require 'inicfg'
local font = require ("moonloader").font_flag
local sw, sh = getScreenResolution()
local tag = '{FF0000}MP{F0E68C}: '
local cfg2 = inicfg.load({
    settings = {
        versionMP = version,
        style = 0,
    },
}, 'AT//AT_main.ini')
cfg2.settings.versionMP = version
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
        text = u8'/mess _ Приз данного мероприятия составляет *@/mess _ ================| Правила мероприятия |================@/mess _ Запрещено: выход из строя, покупка оружия, дм, /jp, /passive, /fly@/mess _ В том числе любая другая помеха игрокам.@/mess _ После телепорта сразу встаем в строй.'
    },
    info = {
        0, -- myreport
        0, -- myban
        0, -- mymute
        0, -- myjail
        0, -- mykick
        0, -- myonline
    },
    MyMP = {},
}, 'AT//AT_MP.ini')
inicfg.save(cfg,'AT//AT_MP.ini')
local style_selected = imgui.ImInt(cfg2.settings.style) -- Берём стандартное значение стиля из конфига
local anticrashmp = false
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
    check_11 = imgui.ImBool(false),
}
local windows = {
    menu_window_state = imgui.ImBool(false),
    secondary_window_state = imgui.ImBool(false),
    stata_window_state = imgui.ImBool(false),
    static_window_state = imgui.ImBool(false)
}
local new_flood = imgui.ImBuffer(cfg.AT_MP.text, 8192)

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local fa_glyph_ranges = imgui.ImGlyphRanges( {fa.min_range, fa.max_range} )
function imgui.BeforeDrawFrame()
    if not fontsize then  fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end -- 17 razmer
	if not fa_font then local font_config = imgui.ImFontConfig() font_config.MergeMode = true fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges) end 
end
function main()
    while not isSampAvailable() do wait(0) end
    while not sampIsLocalPlayerSpawned() do wait(1000) end
    _, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) 
    func1 = lua_thread.create_suspended(time) -- время для статистики
    func1:run()
    func2 = lua_thread.create_suspended(radius) -- поиск игроков в радиусе для пряток
    func3 = lua_thread.create_suspended(find_weapon) -- антисрыв мп
    func4 = lua_thread.create_suspended(check_my_auto)
    func5 = lua_thread.create_suspended(check_player)
    if cfg.AT_MP.adminstate then
        windows.stata_window_state.v = true
        imgui.Process = true
    end
    if cfg.info.data ~= os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year then
        for i = 0, #(cfg.info) do cfg.info[i] = 0 end
        cfg.info.data = os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year
        save()
    end
end
function check_player()
    while true do
        wait(10)
        writeMemory(sampGetBase() + 0x9D9D0, 4, 0x5051FF15, true)
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
local cursor = true
local menu = 'open mp'
local option_komnata = imgui.ImInt(0)
local option_inter = imgui.ImInt(0)
local option_color = imgui.ImInt(3) -- цвет по умолчанию
local text_buffer = imgui.ImBuffer(256)
local text_myprize = imgui.ImBuffer(256)
local MyTextMP = imgui.ImBuffer(8192)
local MyTextMP_start = imgui.ImBuffer(8192)
local MyTextMP_end = imgui.ImBuffer(8192)
local colors = {
    [0] = u8'Белый',
    [1] = u8'Черный',
    [2] = u8'Темно-зеленый',
    [3] = u8'Зеленый',
    [4] = u8'Красный',
    [5] = u8'Темно-синий',
    [6] = u8'Желтый',
    [7] = u8'Золотой',
    [8] = u8'Фиолетовый',
    [9] = u8'Бирюзовый',
    [10] = u8'Синий',
    [11] = u8'Синий 2',
    [12] = u8'Желтый 2',
    [13] = u8'Серый',
    [14] = u8'Бежевый',
    [15] = u8'Розовый',
    [16] = u8'Бледно-желтый',
    [17] = u8'Розово-красный',
}
function sampev.onServerMessage(color,text)
    if mynick then
        if text:match('%[(%d+)%] ответил (.*)%[(%d+)%]: (.*)') and text:match(mynick) then
            cfg.info[0] = cfg.info[0] + 1
            save() 
        end
        if text:match('Администратор (.+) забанил%(.+%) игрока (.+) на (.+) дней. Причина: .+') and text:match(mynick) then
            cfg.info[1] = cfg.info[1] + 1
            save()
        end
        if text:match("Администратор (.+) заткнул%(.+%) игрока (.+) на (.+) секунд. Причина: .+") and text:match(mynick) then
            cfg.info[2] = cfg.info[2] + 1
            save()
        end
        if text:find("Администратор (.+) посадил%(.+%) игрока (.+) в тюрьму на (.+) секунд. Причина: .+") and text:match(mynick) then
            cfg.info[3] = cfg.info[3] + 1
            save()
        end
        if text:find("Администратор (.+) кикнул игрока (.+) Причина: .+") and text:match(mynick) then
            cfg.info[4] = cfg.info[4] + 1
            save()
        end
    end
end
function sampev.onSendCommand(command) -- подстраховка от отправки сообщений во время диалога
    if sampIsDialogActive() and windows.secondary_window_state.v then
        lua_thread.create(function()
            local command = command
            while sampIsDialogActive() do wait(100) end
            sampSendChat(command)
        end)
        return false
    end
end
function imgui.OnDrawFrame()
    if not windows.static_window_state.v and not windows.secondary_window_state.v and not windows.stata_window_state.v and not windows.menu_window_state.v then
        if cfg.AT_MP.adminstate then
            windows.stata_window_state.v = true
        else imgui.Process = false end
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
            thisScript():reload() showCursor(false,false)
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
                if cfg.AT_MP.mynick then imgui.Text(mynick .. ' | ID: '..myid) end
                if cfg.AT_MP.data then imgui.Text(os.date('%H:%M | ') .. os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year) end
                if cfg.AT_MP.myreports then imgui.Text(u8'Репортов: ' .. cfg.info[0]) end
            elseif cfg.AT_MP.warningban and i == 1 then imgui.Text(u8'Банов: ' .. cfg.info[1])
            elseif cfg.AT_MP.warningmute and i == 2 then imgui.Text(u8'Мутов: ' .. cfg.info[2])
            elseif cfg.AT_MP.warningjail and i == 3 then imgui.Text(u8'Джайлов: ' .. cfg.info[3])
            elseif cfg.AT_MP.warningkick and i == 4 then imgui.Text(u8'Киков: ' .. cfg.info[4])
            elseif cfg.AT_MP.myonline and i == 5 then imgui.Text(u8'Онлайн: ' .. cfg.info[5] .. u8' мин.') end
        end
        imgui.End()
    end
    if windows.menu_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2) - 100, (sh/2) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"Взаимодействие с игроком", windows.menu_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.PushFont(fontsize)
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
            windows.menu_window_state.v = false
            lua_thread.create(function()
                sampSendChat('/mess ' .. option_color.v .. ' =============================| Победитель |=============================')
                sampSendChat('/mess ' .. option_color.v .. ' Победитель мероприятия - ' .. sampGetPlayerNickname(id) .. '[' .. id .. '] получает свой приз, поздравим его!')
                sampSendChat('/mpwin ' .. id)
                local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                sampSendChat('/tweap ' .. myid)
                sampSendChat('/delcarall')
                showCursor(false,false)
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    wait(2000)
                    sampShowDialog(6405, "Выдать вознаграждение", "Пример: /giverub id 300\n/givescore 24 500000", "Выдать", nil, DIALOG_STYLE_INPUT) -- сам диалог
                    while sampIsDialogActive(6405) do wait(400) end -- ждёт пока вы ответите на диалог
                    local result, button, _, input = sampHasDialogRespond(6405)
                    if input and #input > 5 then sampSendChat(input) end
                    wait(700)
                    sampProcessChatInput('/spp')
                    wait(700)
                    sampSendChat('/az')
                    thisScript():reload() showCursor(false,false)
                else
                    wait(700)
                    sampProcessChatInput('/spp')
                    wait(700)
                    sampSendChat('/az')
                    thisScript():reload() showCursor(false,false)
                end
            end)
        end
        if imgui.Button(u8'Выдать оружие', imgui.ImVec2(200, 30)) then
            for i = 1, 45 do
                if (require 'game.weapons').get_name(i) then
                    if imgui.Button((require 'game.weapons').get_name(i)) then
                        if sampIsDialogActive() then sampCloseCurrentDialogWithButton(0) end
                        sampSendChat('/setweap ' .. id .. ' ' .. i .. ' 500')
                        windows.menu_window_state.v = false
                    end
                end
                if i%5~=0 then imgui.SameLine() end
            end
        end
        if not player1 and imgui.Button(u8'Сохранить 1-ого игрока', imgui.ImVec2(200, 30)) then
           player1 = id
           showCursor(false,false)
           windows.menu_window_state.v = false
        end
        if not player2 and imgui.Button(u8'Сохранить 2-ого игрока', imgui.ImVec2(200, 30)) then
            player2 = id
            showCursor(false,false)
            windows.menu_window_state.v = false
        end
        imgui.PopFont()
        imgui.End()
    end
    if windows.secondary_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw - 375, 50), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        if checkbox.check_11.v then imgui.Begin(u8"Выбери мероприятие", windows.secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        else imgui.Begin(u8"Выбери мероприятие", windows.secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders) end
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        imgui.PushFont(fontsize)
        imgui.BeginGroup()
            if menu == 'open mp' then
                imgui.CenterText(u8'Помочь провести мероприятие?')
                if imgui.Button(u8'Да', imgui.ImVec2(125, 25)) then menu = 'Приветствие' func5:run() end imgui.SameLine()
                if imgui.Button(u8'Нет', imgui.ImVec2(125, 25)) or isKeyJustPressed(VK_ESCAPE) then windows.secondary_window_state.v = false end
            end
            if menu == 'Приветствие' then
                imgui.CenterText(u8'Давайте настроим мероприятие под вас.')
                if imgui.Button(u8'Русская рулетка', imgui.ImVec2(150,24)) then menu = 'Русская рулетка' end imgui.SameLine()
                if imgui.Button(u8'Поливалка', imgui.ImVec2(150,24)) then menu = 'Поливалка' end 
                if imgui.Button(u8'Прятки', imgui.ImVec2(150,24)) then menu = 'Прятки' end imgui.SameLine()
                if imgui.Button(u8'Король дигла', imgui.ImVec2(150,24)) then menu = 'Король дигла' end
                if imgui.Button(u8'Мое мероприятие', imgui.ImVec2(310,24)) then menu = 'custom' sampCloseCurrentDialogWithButton(0) showCursor(true,false) end
                imgui.PushItemWidth(310)
                imgui.Combo('##color2', option_color, colors, 6)
                imgui.PopItemWidth()
                imgui.Tooltip(u8'Цвет /mess')
                if imgui.Button(u8'Изменить текст отправки') then imgui.OpenPopup('custom') sampCloseCurrentDialogWithButton(0) showCursor(true,false) end
                imgui.SameLine()
                imgui.SetCursorPosX(200)
                if imgui.Button(u8'Я передумал', imgui.ImVec2(120,24)) then thisScript():reload() showCursor(false,false) end
                imgui.InputTextMultiline("##Текст оглашения приза", text_myprize, imgui.ImVec2(310,25))
                imgui.Tooltip(u8('Приз данного мероприятия составит ' .. u8:decode(text_myprize.v)))
                if imgui.BeginPopup('custom') then
                    imgui.Text(u8'Символ "_" означает цвет, выбранный в первом окне.\nВы можете поставить любые цвета вместо этого символа\nСимвол "*" означает ваш выбранный приз из первого окна.')
                    new_flood.v = string.gsub(new_flood.v, "@", "\n")
                    if imgui.InputTextMultiline("##1", new_flood, imgui.ImVec2(500, 300)) then
                        new_flood.v = string.gsub(new_flood.v, "\n", "@")
                        cfg.AT_MP.text = new_flood.v
                        save()	
                    end
                    imgui.EndPopup()
                end
            end
        imgui.EndGroup()
        imgui.BeginGroup()
            if menu == 'Русская рулетка' then
                imgui.CenterText(u8('О Мероприятии ' .. menu))
                imgui.TextWrapped(u8'Набирается необходимое количество человек, все встают в строй, после чего вы закрываете мероприятие, и подходя к каждому из строя по очереди вводите /try убит, если удачно - убиваете, нет - оставляете в живых, делаете так, пока в строю не останется 1 игрок, он и будет победителем.')
                if imgui.Button(u8'Начать сбор', imgui.ImVec2(300,24)) then sbor_mp(menu, 8, option_color.v, 1) menu = 'закрыть мп' end
            end
            if menu == 'Прятки' then
                imgui.CenterText(u8('О мероприятии ' .. menu))
                imgui.TextWrapped(u8'Собрав необходимое кол-во человек закрываете телепорт, ждете окончания таймера и отправляетесь на поиски, опираясь на рендер с количеством игроков, пока не останется последний.')
                if imgui.Button(u8'Начать сбор', imgui.ImVec2(300,24)) then
                    menu = 'закрыть мп'
                    lua_thread.create(function()
                        sbor_mp('Прятки', 5, option_color.v, 0)
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        if cfg2.settings.wallhack then sampProcessChatInput('/wh') end -- выключаем вх если оно включено
                        func2:run() 
                        while menu ~= 'настройки' do wait(500) end
                        sampSendChat('/mess ' .. option_color.v .. ' Запускаю таймер в 10 секунд, после чего отправляюсь на поиски :3')
                        sampSendChat('/dmcount 10')
                        for i = 0,1 do
                            setVirtualKeyDown(118, true)
                            wait(200)
                            setVirtualKeyDown(118, false)
                        end
                        sampAddChatMessage(tag .. 'Не честно подглядывать, а ну вырубил интерфейс', -1)
                    end)
                end
            end
            if menu == 'Поливалка' then
                imgui.CenterText(u8('О мероприятии ' .. menu))
                imgui.TextWrapped(u8'Собрав необходимое кол-во человек закрываете телепорт, разбрасываете игроков с крыши с помощью поливалки/дб, если упадете с крыши - используйте /r')
                if imgui.Button(u8'Начать сбор', imgui.ImVec2(300,24)) then
                    menu = 'закрыть мп'
                    lua_thread.create(function()
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        sampSendChat('/tpcor 1566.73 -1242.10 277.88')
                        wait(2000)
                        sampSendChat('/tpcor 1566.73 -1242.10 277.88')
                        sbor_mp('Поливалка', nil, option_color.v, 0)
                        while menu ~= 'настройки' do wait(500) end
                        sampSendChat('/dmcount 3')
                        sampAddChatMessage(tag .. 'Создаю транспорт...', -1)
                        sampSendChat('/veh 601 1 1')
                        while getClosestCarId() > 1 and sampIsDialogActive() do wait(200)  end
                        func4:run()
                        sampSendChat('/s')
                        sampAddChatMessage(tag .. 'Позиция сохранена! Для телепорта в это же место используйте /r', -1)
                        sampAddChatMessage(tag .. 'Позиция сохранена! Для телепорта в это же место используйте /r', -1)
                        sampAddChatMessage(tag .. 'Позиция сохранена! Для телепорта в это же место используйте /r', -1)
                    end)
                end
            end
            if menu == 'Король дигла' then
                imgui.CenterText(u8('О Мероприятии ' .. menu))
                imgui.TextWrapped(u8'Набирается необходимое количество человек, все встают в строй, после чего вы закрываете мероприятие, и разбив игроков на команды (проще всего это сделать кнопкой через интерфейс), берёте 2 игроков, нажимаете пкм + 1 по игроку - сохранить игрока, и также со вторым. Потом тпаете их по краям комнаты и нажимаете "начать PVP", победитель сражается со следующим.')
                if imgui.Button(u8'Начать сбор', imgui.ImVec2(300,24)) then sbor_mp(menu, 4, option_color.v, 0) menu = 'закрыть мп' end
            end
            if menu == 'custom' then
                imgui.TextWrapped(u8'Давайте настроим ваше мероприятие')
                imgui.Text(u8'Название мероприятия')
                imgui.SameLine()
                imgui.PushItemWidth(127)
                imgui.InputText('##mympname', MyTextMP)
                imgui.PopItemWidth()
                if imgui.Button(u8'Начало сбора', imgui.ImVec2(150,24)) then imgui.OpenPopup('start_text') end imgui.SameLine()
                if imgui.Button(u8'Конец сбора', imgui.ImVec2(150,24)) then imgui.OpenPopup('end_text') end
                if imgui.BeginPopup('start_text') then
                    imgui.Text(u8'Можете использовать команду wait(1) что означает задержка 1 секунда')
                    imgui.InputTextMultiline("##start_text", MyTextMP_start, imgui.ImVec2(500, 300))
                    imgui.EndPopup()
                end
                if imgui.BeginPopup('end_text') then
                    imgui.Text(u8'Можете использовать команду wait(1) что означает задержка 1 секунда')
                    imgui.InputTextMultiline("##end_text", MyTextMP_end, imgui.ImVec2(500, 300))
                    imgui.EndPopup()
                end
                imgui.Text(u8'Вам нужна комната?') imgui.SameLine()
                imgui.PushItemWidth(150)
                imgui.Combo('##komnata', option_komnata, {u8'Моя позиция',u8'Русская рулетка', u8'Король дигла', u8'Корабль', u8'Спортзал', u8'Fall Guys'}, 5)
                imgui.PopItemWidth()
                if imgui.Button(u8'Начать сбор', imgui.ImVec2(300,24)) and #(MyTextMP.v) > 3 then
                    menu = 'закрыть мп'
                    if option_komnata.v == 0 then komnata_mymp = false
                    elseif option_komnata.v == 1 then komnata_mymp = 8  --Русская рулетка
                    elseif option_komnata.v == 2 then komnata_mymp = 4  --Король дигла
                    elseif option_komnata.v == 3 then komnata_mymp = 5  --Корабль
                    elseif option_komnata.v == 4 then komnata_mymp = 7  --Спортзал
                    elseif option_komnata.v == 5 then komnata_mymp = 11 end --фалл гейс
                    sbor_mp(u8:decode(MyTextMP.v), komnata, option_color.v, 0)
                end
                if imgui.Button(u8'Сохранить данное мероприятие', imgui.ImVec2(300,24)) then
                    if #(MyTextMP.v) > 3 then
                        local text_mp = ''
                        if #(MyTextMP_start.v) > 3 then
                            text_mp = text_mp .. string.gsub(u8:decode(MyTextMP_start.v), '\n', '\\n')
                        else text_mp = text_mp .. '-' end
                        text_mp = text_mp .. '@'..option_komnata.v..'@'
                        if #(MyTextMP_end.v) > 3 then
                            text_mp = text_mp .. string.gsub(u8:decode(MyTextMP_end.v), '\n', '\\n')
                        else text_mp = text_mp .. '-' end
                        cfg.MyMP[u8:decode(MyTextMP.v)] = text_mp
                        save()
                    end
                end
                imgui.CenterText(u8'Сохраненные мероприятия')
                for k,v in pairs(cfg.MyMP) do
                    if imgui.Button(u8(k), imgui.ImVec2(270,24)) then
                        local action_mp = textSplit(v, '@')
                        if action_mp[1] ~= '-' then
                            MyTextMP_start.v = string.gsub(u8(action_mp[1]), '\\n', '\n')
                        end
                        option_komnata.v = u8(action_mp[2])
                        if action_mp[3] ~= '-' then
                            MyTextMP_end.v = string.gsub(u8(action_mp[3]), '\\n', '\n')
                        end
                        MyTextMP.v = u8(k)
                    end
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_BAN..'##'..k, imgui.ImVec2(20,24)) then
                        cfg.MyMP[k] = nil
                        save()
                    end
                end
            end
            if menu == 'закрыть мп' then
                if imgui.Button(u8'Напомнить о мероприятии', imgui.ImVec2(300,24)) then
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess ' .. option_color.v .. ' Приз данного мероприятия составляет ' .. u8:decode(text_myprize.v) .. '. Поторопись, телепорт скоро закроется!')
                    else sampSendChat('/mess ' .. option_color.v .. ' Телепорт на мероприятие всё ещё открыт, команда для телепорта - /tpmp') end
                end
                if imgui.Button(u8'Закрыть телепорт', imgui.ImVec2(300,24)) then
                    if not sampIsDialogActive() then
                        menu = 'настройки'
                        lua_thread.create(function()
                            sampSendChat('/mp')
                            sampSendDialogResponse(5343, 1, 0)
                            while not sampIsDialogActive(5343) do wait(200) end
                            while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                            local _, myid = sampGetPlayerIdByCharHandle(playerPed)
                            sampProcessChatInput('/stw ' .. myid ..' 38 5000')
                            cursor = not cursor
                            showCursor(false,false)
                            if #(MyTextMP.v) ~= 0 then                  -- если моё мп активно - доп текст если есть
                                if #(MyTextMP_end.v) ~= 0 then
                                    MyTextMP_end.v = u8:decode(MyTextMP_end.v)
                                    if MyTextMP_end.v:find('\n') then
                                        for a,b in pairs((textSplit(MyTextMP_end.v, '\n'))) do
                                            if b:match('wait(%(%d+)%)') then
                                                wait(tonumber(b:match('%d+') .. '000'))
                                            else sampSendChat(b) end
                                        end 
                                    else sampSendChat(MyTextMP_end.v) end
                                end
                            end
                        end)
                    end
                end
            end
            if menu == 'настройки' then
                if imgui.Button(u8'Выдать всем хп', imgui.ImVec2(300,24)) then
                    lua_thread.create(function()
                        if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                        sampSendDialogResponse(5343, 1, 2)
                        while not sampIsDialogActive(5343) do wait(200) end
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                    end)
                end
                if imgui.Button(u8'Отобрать у всех оружие', imgui.ImVec2(300,24)) then
                    lua_thread.create(function()
                        if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                        sampSendDialogResponse(5343, 1, 3)
                        while not sampIsDialogActive(5343) do wait(200) end
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                    end)
                end
                if imgui.Button(u8'Выдать всем оружие', imgui.ImVec2(300,24)) then imgui.OpenPopup('gun') end
                if player1 and imgui.Button(u8'Телепортировать первого игрока', imgui.ImVec2(300,24)) then sampSendChat('/gethere '..player1) end
                if player2 and imgui.Button(u8'Телепортировать второго игрока', imgui.ImVec2(300,24)) then sampSendChat('/gethere '..player2) end
                if (player1 and player2) and imgui.Button(u8'Начать PVP', imgui.ImVec2(300,24)) then
                    lua_thread.create(function()
                        if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                        sampSendDialogResponse(5343, 1, 2)
                        while not sampIsDialogActive(5343) do wait(200) end
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        sampSendChat('/mess '..option_color.v .. ' На поле битвы выходят: ' .. sampGetPlayerNickname(player1) .. '['..player1..']' .. ' и ' ..sampGetPlayerNickname(player2) ..'['..player2..']')
                        sampSendChat('/mess '..option_color.v .. ' Я запускаю таймер в 6 секунд, после чего начнется битва...')
                        sampSendChat('/dmcount 6')
                        player1 = false
                        player2 = false
                    end)
                end
            end
        imgui.EndGroup()
        if imgui.BeginPopup('gun') then
            for i = 1, 45 do
                if (require 'game.weapons').get_name(i) then
                    if imgui.Button((require 'game.weapons').get_name(i)) then
                        lua_thread.create(function()
                            if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                            sampSendDialogResponse(5343, 1, 1)
                            sampSendDialogResponse(5346, 1, 1, i..', 500') --выдаем 500 патрон выбранного оружия
                            while not sampIsDialogActive(5343) do wait(200) end
                            while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        end)
                    end
                end
                if i%5~=0 then imgui.SameLine() end
            end
            imgui.EndPopup()
        end
        imgui.PopFont()
        if menu ~= 'open mp' then
            if menu ~= 'Приветствие' then
                imgui.PushFont(fontsize)
                if imgui.Button(u8'Завершить мероприятие досрочно', imgui.ImVec2(300,24)) then thisScript():reload() showCursor(false,false) end
                imgui.PopFont()
            end
            imgui.CenterText(u8'Активация курсора - клавиша F')
            imgui.Checkbox(u8'позиция окна', checkbox.check_11)
            imgui.Tooltip(u8'Если галочка активна - окно можно двигать курсором.')
            if imgui.Checkbox(u8'анти-срыв мероприятия', checkbox.check_10) then
                if anticrashmp then func3:terminate()
                else func3:run() end
                anticrashmp = not anticrashmp
            end
            imgui.Tooltip(u8'Автоматически выдает джайл, если видит оружие в руках игрока.\nМожет посадить администратора, потому проводить совместно не рекомендуется.')
        end
        if isKeyJustPressed(VK_F) and not (sampIsDialogActive() and sampIsChatInputActive()) then
            cursor = not cursor
            if cursor then showCursor(false,false)
            else showCursor(true,true) end
        end
        imgui.End()
    end
end
function check_my_auto()
    while true do 
        if not isCharInAnyCar(PLAYER_PED) then
            sampSendChat('/entercar ' .. getClosestCarId())
        end
        wait(1000)
    end
end
function sbor_mp(name, komnata, color, inter) -- название мп, выбранный телепорт (рр, корабль и т.д), цвет месс, интерьер
    lua_thread.create(function()
        if not sampIsDialogActive(5343) then sampCloseCurrentDialogWithButton(0) sampSendChat('/mp') end -- если диалог закрыт открываем снова
        if komnata then
            sampSendDialogResponse(5343, 1, komnata) -- тп в комнату
            wait(2000)  -- ждем 2 секунды пока прогрузит интерьер
            sampSendDialogResponse(5343, 1, komnata) -- тп х2 в комнату
        end
        sampSendDialogResponse(5343, 1, 14) -- Настройки
        sampSendDialogResponse(16066, 1, 1) -- виртуальный мир
        sampSendDialogResponse(16067, 1, 0, '990') -- виртуальный мир
        sampSendDialogResponse(16066, 1, 2) -- настройки интерьера
        sampSendDialogResponse(16068, 1, 1, inter) -- установить интерьер
        sampSendDialogResponse(16066, 1, 0) -- установить координаты
        sampSendDialogResponse(16066, 0, 0) -- закрываем окно
        while not sampIsDialogActive(5343) do wait(200) end -- подстраховка от медленного интернета, ждем когда появится диалог
        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
        sampSendChat('/mess '..color.. ' Начинается мероприятие '..name..' успей принять участие')
        sampSendChat('/mp')
        sampSendDialogResponse(5343, 1, 0) -- Открываем ввод названия мп
        sampSendDialogResponse(5344, 1, 1, name) -- название мп
        while not sampIsDialogActive(5343) do wait(200) end
        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
        if #MyTextMP.v == 0 then 
            for k,v in pairs(textSplit(string.gsub(cfg.AT_MP.text, '_', color),'@')) do
                if v:find('*') then 
                    if #(u8:decode(text_myprize.v)) > 0 then sampSendChat(string.gsub(u8:decode(v), '*', u8:decode(text_myprize.v)))
                    else sampAddChatMessage(tag .. 'Приз не указан.', -1) end
                else sampSendChat(u8:decode(v)) end
            end
        else
            if #(MyTextMP_start.v) ~= 0 then
                MyTextMP_start.v = u8:decode(MyTextMP_start.v)
                if MyTextMP_start.v:match('\n') then
                    for a,b in pairs(textSplit(MyTextMP_start.v, '\n')) do
                        if b:match('wait(%(%d+)%)') then
                            wait(tonumber(b:match('%d+') .. '000'))
                        else sampSendChat(b) end
                    end 
                else sampSendChat(MyTextMP_start.v) end
                wait(2000)
            end
        end
        wait(1000)
        if sampIsDialogActive() then sampCloseCurrentDialogWithButton(0) end -- подстраховка если какой-то диалог останется открытым
    end)
end
function imgui.CenterText(text) -- центрирование текста
    imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(text).x / 2 ) 			
    imgui.Text(text)
end
function imgui.Tooltip(text)
    if imgui.IsItemHovered() then
       imgui.BeginTooltip() -- подсказка при наведении на кнопку
       imgui.Text(text)
       imgui.EndTooltip()
    end
end
function find_weapon()
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    while menu ~= 'настройки' and menu ~= 'закрыть мп' do wait(3000) end
    while true do
        wait(2000)
        local playerzone = playersToStreamZone()
        for _,v in pairs(playerzone) do
            local _, handle = sampGetCharHandleBySampPlayerId(v) 
            if v ~= myid then
                if getCurrentCharWeapon(handle) ~= 0 then
                    if not (sampTextdrawIsExists(168) or sampTextdrawIsExists(144)) then
                        sampAddChatMessage(tag .. 'Обнаружена попытка слива мп. Игрок: ' .. sampGetPlayerNickname(v) .. '[' .. v .. ']. Оружие: ' .. (require 'game.weapons').get_name(getCurrentCharWeapon(handle)) , -1)
                        sampSendChat('/jail ' .. v .. ' 300 Оружие на мероприятии')
                    end
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
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 5343 and menu == 'open mp' then
        windows.secondary_window_state.v = true
        imgui.Process = true
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
    inicfg.save(cfg,'AT//AT_MP.ini')
end
function radius()
    local font_watermark = renderCreateFont("Javanese Text", 12, font.BOLD + font.BORDER + font.SHADOW)
    while true do
        wait(1)
        renderFontDrawText(font_watermark, 'Игроков в радиусе: ' .. #(playersToStreamZone()) -1 , sh*0.5, sw*0.5, 0xCCFFFFFF)
    end
end
function textSplit(str, delim, plain) -- разбиение текста по определенным триггерам
    local tokens, pos, plain = {}, 1, not (plain == false)
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
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
    style.IndentSpacing = 25.0
    style.GrabMinSize = 15.0
    style.GrabRounding = 7.0
    style.ChildWindowRounding = 8.0
    style.FrameRounding = 6.0
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
		colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
		colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
		colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.TitleBg]                = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.48, 0.16, 0.16, 1.00)
		colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.70)
		colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
		colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
		colors[clr.Separator]              = colors[clr.Border]
		colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
		colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
		colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
		colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = colors[clr.PopupBg]
		colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 2 then -- зеленая тема
		colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(0.10, 0.10, 0.10, 1.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 1.00)
		colors[clr.Border]                 = ImVec4(0.70, 0.70, 0.70, 0.40)
		colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]                = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.19, 0.19, 0.19, 0.71)
		colors[clr.FrameBgActive]          = ImVec4(0.34, 0.34, 0.34, 0.79)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.69, 0.33, 0.60)
		colors[clr.TitleBgActive]          = ImVec4(0.00, 0.74, 0.36, 0.60)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.MenuBarBg]              = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.16, 0.16, 0.16, 1.00)
		colors[clr.ScrollbarGrab]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
		colors[clr.CheckMark]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.00, 0.77, 0.37, 1.00)
		colors[clr.Button]                 = ImVec4(0.00, 0.69, 0.33, 0.50)
		colors[clr.ButtonHovered]          = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.00, 0.87, 0.42, 1.00)
		colors[clr.Header]                 = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.00, 0.76, 0.37, 0.57)
		colors[clr.HeaderActive]           = ImVec4(0.00, 0.88, 0.42, 0.89)
		colors[clr.Separator]              = ImVec4(1.00, 1.00, 1.00, 0.40)
		colors[clr.SeparatorHovered]       = ImVec4(1.00, 1.00, 1.00, 0.60)
		colors[clr.SeparatorActive]        = ImVec4(1.00, 1.00, 1.00, 0.80)
		colors[clr.ResizeGrip]             = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.ResizeGripHovered]      = ImVec4(0.00, 0.76, 0.37, 1.00)
		colors[clr.ResizeGripActive]       = ImVec4(0.00, 0.86, 0.41, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.00, 0.82, 0.39, 1.00)
		colors[clr.CloseButtonHovered]     = ImVec4(0.00, 0.88, 0.42, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.00, 1.00, 0.48, 1.00)
		colors[clr.PlotLines]              = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotLinesHovered]       = ImVec4(0.00, 0.74, 0.36, 1.00)
		colors[clr.PlotHistogram]          = ImVec4(0.00, 0.69, 0.33, 1.00)
		colors[clr.PlotHistogramHovered]   = ImVec4(0.00, 0.80, 0.38, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(0.00, 0.69, 0.33, 0.72)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.17, 0.17, 0.17, 0.48)
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
		colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.35)
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
	elseif id == 4 then -- Розовая тема
		colors[clr.FrameBg]                = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.FrameBgHovered]         = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.FrameBgActive]          = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.61, 0.16, 0.39, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]              = ImVec4(0.94, 0.30, 0.63, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.85, 0.11, 0.49, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.89, 0.24, 0.58, 1.00)
		colors[clr.Button]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.ButtonHovered]          = ImVec4(0.69, 0.17, 0.43, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.59, 0.10, 0.35, 1.00)
		colors[clr.Header]                 = ImVec4(0.46, 0.11, 0.29, 1.00)
		colors[clr.HeaderHovered]          = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.HeaderActive]           = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.Separator]              = ImVec4(0.69, 0.16, 0.43, 1.00)
		colors[clr.SeparatorHovered]       = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.SeparatorActive]        = ImVec4(0.58, 0.10, 0.35, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.46, 0.11, 0.29, 0.70)
		colors[clr.ResizeGripHovered]      = ImVec4(0.69, 0.16, 0.43, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.70, 0.13, 0.42, 1.00)
		colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.78, 0.90, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.60, 0.19, 0.40, 1.00)
		colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]                 = ImVec4(0.49, 0.14, 0.31, 1.00)
		colors[clr.BorderShadow]           = ImVec4(0.49, 0.14, 0.31, 0.00)
		colors[clr.MenuBarBg]              = ImVec4(0.15, 0.15, 0.15, 1.00)
		colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
		colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
		colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
		colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
		colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
		colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
		colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
    elseif id == 5 then -- голубая тема
		colors[clr.Text]                   = ImVec4(2.00, 2.00, 2.00, 1.00)
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
		colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 0.50)
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