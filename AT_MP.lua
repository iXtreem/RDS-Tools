require 'lib.moonloader'
script_name 'AT_MP' 
script_author 'Neon4ik'
local version = 2.6
require 'my_lib'
encoding.default = 'CP1251' 
local tag = '{B73CBF}AdminTools - �����������{F0E68C}: '
local cfg2 = inicfg.load({
    settings = {
        versionMP = version,
        style = 0,
    },
}, 'AT//AT_main.ini')
cfg2.settings.versionMP = version
inicfg.save(cfg2, 'AT//AT_main.ini')
local cfg = inicfg.load({
    tick = {
        report = 20,
        ban = 10,
        mute = 20,
        jail = 10,
        kick = 1,
        online = 120,
        mp = 1,
    },
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
        warningmp = false,
        allonline = false,
        data_online = '2024-01-01',
        staticposX = 20,
        staticposY = sh - 200,
        style = 0,
        wallhack = true,
        access_automute = false,
        text = u8'/mess _ ���� ������� ����������� ���������� *@/mess _ ================| ������� ����������� |================@/mess _ ���������: ����� �� �����, ������� ������, ��, /jp, /passive, /fly@/mess _ � ��� ����� ����� ������ ������ �������.@/mess _ ����� ��������� ����� ������ � �����.'
    },
    info = {
        0, -- myreport
        0, -- myban
        0, -- mymute
        0, -- myjail
        0, -- mykick
        0, -- myonline
        0, -- mp
    },
    MyMP = {},
}, 'AT//AT_MP.ini')
inicfg.save(cfg,'AT//AT_MP.ini')
style(cfg2.settings.style)
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
    check_10 = imgui.ImBool(false),
    check_11 = imgui.ImBool(false),
    check_12 = imgui.ImBool(cfg.AT_MP.warningmp),
    check_13 = imgui.ImBool(cfg.AT_MP.allonline)
}
local windows = {
    menu_window_state       = imgui.ImBool(false),
    secondary_window_state  = imgui.ImBool(false),
    stata_window_state      = imgui.ImBool(false),
    static_window_state     = imgui.ImBool(false)
}
local new_flood = imgui.ImBuffer(cfg.AT_MP.text, 8192)
local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
local mynick = sampGetPlayerNickname(myid)

function main()
    while not isSampAvailable() do wait(0) end
    while not sampIsLocalPlayerSpawned() do wait(1000) end
    _, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) 
    func1 = lua_thread.create_suspended(time) -- ����� ��� ����������
    func1:run()
    func2 = lua_thread.create_suspended(radius) -- ����� ������� � ������� ��� ������
    func3 = lua_thread.create_suspended(find_weapon) -- �������� ��
    func4 = lua_thread.create_suspended(check_my_auto)
    func5 = lua_thread.create_suspended(check_player)
    local func6 = lua_thread.create_suspended(update_info)
    func6:run()
    if cfg.info.data ~= os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year then
        for i = 0, 6 do cfg.info[i] = 0 end
        cfg.info.data = os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year
        save()
    end
    if cfg.AT_MP.adminstate then
        windows.stata_window_state.v = true
        imgui.Process = true
    end
    wait(-1) -- ����������� ��������
end
function check_player()
    while true do
        wait(10)
        writeMemory(sampGetBase() + 0x9D9D0, 4, 0x5051FF15, true)
        if wasKeyPressed(VK_1) and not sampIsChatInputActive() and not sampIsDialogActive() then
            result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
            if result and imgui.Process then
                _, id = sampGetPlayerIdByCharHandle(ped)
                windows.menu_window_state.v = true
                showCursor(true,false)
            end
        end
    end
end
local tick = { -- �� ������� ����
    [0] = imgui.ImInt(cfg.tick.report),
    [1] = imgui.ImInt(cfg.tick.ban),
    [2] = imgui.ImInt(cfg.tick.mute),
    [3] = imgui.ImInt(cfg.tick.jail),
    [4] = imgui.ImInt(cfg.tick.kick),
    [5] = imgui.ImInt(cfg.tick.online),
    [6] = imgui.ImInt(cfg.tick.mp),
}
local cursor = true
local start_mp = false -- ������ �� ���������� �������
local menu = 'open mp'
local option_komnata = imgui.ImInt(0)
local option_inter = imgui.ImInt(0)
local option_color = imgui.ImInt(10) -- ���� �� ���������
local text_buffer = imgui.ImBuffer(256)
local text_myprize = imgui.ImBuffer(256)
local MyTextMP = imgui.ImBuffer(8192)
local MyTextMP_start = imgui.ImBuffer(8192)
local MyTextMP_end = imgui.ImBuffer(8192)
local colors = {
    [0] = u8'�����',
    [1] = u8'������',
    [2] = u8'�����-�������',
    [3] = u8'�������',
    [4] = u8'�������',
    [5] = u8'�����-�����',
    [6] = u8'������',
    [7] = u8'�������',
    [8] = u8'����������',
    [9] = u8'���������',
    [10] = u8'�����',
    [11] = u8'����� 2',
    [12] = u8'������ 2',
    [13] = u8'�����',
    [14] = u8'�������',
    [15] = u8'�������',
    [16] = u8'������-������',
    [17] = u8'������-�������',
}
sampRegisterChatCommand('test',function()
    sampAddChatMessage('�����������, �� ������ 150 ����� �������!', -1) 
    cfg.AT_MP.access_automute = false
    save()
end)
function sampev.onServerMessage(color,text)
    if text:match('%[A%] '..mynick..'%[(%d+)%] ������� (.+)%[(%d+)%]: ') then
        cfg.info[0] = cfg.info[0] + 1
    elseif text:match('������������� '..mynick..' �������%(.+%) ������ (.+) �� (.+) ����%. �������:') then
        cfg.info[1] = cfg.info[1] + 1
    elseif text:match('������������� '..mynick..' �������%(.+%) ������ (.+) �� (.+) ������%. �������:') then
        cfg.info[2] = cfg.info[2] + 1
        if access_automute == false and cfg.info[2] >= 100 then sampAddChatMessage('�����������, �� ������ 150 ����� �������!', -1)  cfg.AT_MP.access_automute = true save() end 
    elseif text:match('������������� '..mynick..' �������%(.+%) ������ (.+) � ������ �� (.+) ������%. �������:') then
        cfg.info[3] = cfg.info[3] + 1
    elseif text:find('������������� '..mynick..' ������ ������ (.+) �������:') then
        cfg.info[4] = cfg.info[4] + 1
    elseif text:match('������������� '..mynick..' ������%(.+%) ������ � ������� ������ (.+) �� (.+) ������%. �������:') then
        cfg.info[2] = cfg.info[2] + 1
    elseif text:match('%[A%] (.+) '..mynick..'%((%d+)%) �����%(.+%) ���� ������ (.+)%((%d+)%)') then
        cfg.info[6] = cfg.info[6] + 1
    end
end
function imgui.OnDrawFrame()
    if not windows.static_window_state.v and not windows.secondary_window_state.v and not windows.stata_window_state.v and not windows.menu_window_state.v then
        if cfg.AT_MP.adminstate then windows.stata_window_state.v = true
        else imgui.Process = false end
    end
    if windows.static_window_state.v then
        windows.stata_window_state.v = false
        imgui.ShowCursor = true
        imgui.SetNextWindowPos(imgui.ImVec2(sw*0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"����������", windows.static_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        if imadd.ToggleButton('##activerstate', checkbox.check_1) then
            cfg.AT_MP.adminstate = not cfg.AT_MP.adminstate
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'���/����')
        imgui.Text(u8'�������� ������')
        if imadd.ToggleButton('##mynick', checkbox.check_2) then
            cfg.AT_MP.mynick = not cfg.AT_MP.mynick
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'��� ���')
        imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##date', checkbox.check_3) then
            cfg.AT_MP.data = not cfg.AT_MP.data
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'����')
        if imadd.ToggleButton('##myreport', checkbox.check_4) then
            cfg.AT_MP.myreports = not cfg.AT_MP.myreports
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'������� �� ����')
        imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##myonline', checkbox.check_5) then
            cfg.AT_MP.myonline = not cfg.AT_MP.myonline
			save()
        end
        imgui.SameLine()
        imgui.Text(u8'������ �� ����')
        if imadd.ToggleButton('##ban', checkbox.check_6) then
			cfg.AT_MP.warningban = not cfg.AT_MP.warningban
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'���� �� ����')
        imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##mute', checkbox.check_7) then
            cfg.AT_MP.warningmute = not cfg.AT_MP.warningmute
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'���� �� ����')
		if imadd.ToggleButton('##jail', checkbox.check_8) then
            cfg.AT_MP.warningjail = not cfg.AT_MP.warningjail
            save()
        end
		imgui.SameLine()
        imgui.Text(u8'������ �� ����')
		imgui.SameLine()
        imgui.SetCursorPosX(150)
        if imadd.ToggleButton('##kick', checkbox.check_9) then
            cfg.AT_MP.warningkick = not cfg.AT_MP.warningkick
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'����� �� ����')
        if imadd.ToggleButton('##mp', checkbox.check_12) then
            cfg.AT_MP.warningmp = not cfg.AT_MP.warningmp
            save()
        end
        imgui.SameLine()
        imgui.Text(u8'���������� ����������� �����������')
        if imgui.Button(u8'��������� �������') then
            lua_thread.create(function()
                windows.stata_window_state.v = true
                windows.static_window_state.v = false
                sampAddChatMessage(tag .. '������� �������� ����� ������������ ���� � �������: Enter', -1)
                sampAddChatMessage(tag .. '�������� ������� �������: Esc',-1)
                local old_pos_x, old_pos_y = cfg.AT_MP.staticposX, cfg.AT_MP.staticposY
                while true do
                    showCursor(true,true)
                    cfg.AT_MP.staticposX, cfg.AT_MP.staticposY = getCursorPos()
                    if wasKeyPressed(VK_RETURN) then save() break end
                    if wasKeyPressed(VK_ESCAPE) then cfg.AT_MP.staticposX = old_pos_x cfg.AT_MP.staticposY = old_pos_y break end
                    wait(1)
                end
			    save()
                showCursor(false,false)
                thisScript():reload()
            end)
        end
        if imgui.Button(u8'��������� ���������� �����') then imgui.OpenPopup('norma') end
        if imgui.BeginPopup('norma') then
            imgui.CenterText(u8'���������� ��������')
            if imgui.SliderInt('##report', tick[0], 10,500) then
                cfg.tick.report = tick[0].v
                save()
            end
            imgui.CenterText(u8'���������� �����')
            if imgui.SliderInt('##ban', tick[1], 2,100) then
                cfg.tick.ban = tick[1].v
                save()
            end
            imgui.CenterText(u8'���������� �����')
            if imgui.SliderInt('##mute', tick[2], 10, 200) then
                cfg.tick.mute = tick[2].v
                save()
            end
            imgui.CenterText(u8'���������� �������')
            if imgui.SliderInt('##jail', tick[3], 2,100) then
                cfg.tick.jail = tick[3].v
                save()
            end
            imgui.CenterText(u8'���������� �����')
            if imgui.SliderInt('##kick', tick[4], 1,10) then
                cfg.tick.kick = tick[4].v
                save()
            end
            imgui.CenterText(u8'����� �������')
            if imgui.SliderInt('##online', tick[5], 20, 1440) then
                cfg.tick.online = tick[5].v
                save()
            end
            imgui.CenterText(u8'����������� �����������')
            if imgui.SliderInt('##mp', tick[6], 1, 10) then
                cfg.tick.mp = tick[6].v
                save()
            end
            imgui.EndPopup()
        end
        windows.stata_window_state.v = false -- �������� ���������� ����� �� ���� ���� � �����
        imgui.End()
    end
    if windows.stata_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(cfg.AT_MP.staticposX, cfg.AT_MP.staticposY), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin("##AdminStata", windows.stata_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.ShowCursor = false
        for k,v in pairs(info_array) do
            imgui.Text(v)
        end
        imgui.End()
    end
    if windows.menu_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw/2) - 100, (sh/2) - 100), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8"�������������� � �������", windows.menu_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.PushFont(fontsize)
        imgui.Text(u8'��� ������� � �������\n' .. sampGetPlayerNickname(id) .. '?')
        if imgui.Button(u8'����������', imgui.ImVec2(200, 30)) then
            sampSendChat('/aspawn ' .. id)
        end
        if imgui.Button(u8'��������� ������ �����������', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 300 ��������� ������ ��')
            showCursor(false,false)
            windows.menu_window_state.v = false
        end
        if imgui.Button(u8'���� �����������', imgui.ImVec2(200, 30)) then
            sampSendChat('/jail ' .. id .. ' 3000 ���� �����������')
            showCursor(false,false)
            windows.menu_window_state.v = false
        end
        if imgui.Button(u8'������ ����', imgui.ImVec2(200, 30)) then
            windows.menu_window_state.v = false
            showCursor(false,false)
            lua_thread.create(function()
                sampSendChat('/mess ' .. option_color.v .. ' =============================| ���������� |=============================')
                sampSendChat('/mess ' .. option_color.v .. ' ���������� ����������� - ' .. sampGetPlayerNickname(id) .. '[' .. id .. '] �������� ���� ����, ��������� ���!')
                sampSendChat('/mpwin ' .. id)
                local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
                sampSendChat('/tweap ' .. myid)
                sampSendChat('/delcarall')
                if #(u8:decode(text_myprize.v)) ~= 0 then
                    wait(2000)
                    sampShowDialog(6405, "������ ��������������", "������: /giverub id 300\n/givescore 24 500000", "������", nil, DIALOG_STYLE_INPUT) -- ��� ������
                    while sampIsDialogActive(6405) do wait(400) end -- ��� ���� �� �������� �� ������
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
        if imgui.Button(u8'������ ������', imgui.ImVec2(200, 30)) then
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
        if not player1 and imgui.Button(u8'��������� 1-��� ������', imgui.ImVec2(200, 30)) then
           player1 = id
           showCursor(false,false)
           windows.menu_window_state.v = false
        end
        if not player2 and imgui.Button(u8'��������� 2-��� ������', imgui.ImVec2(200, 30)) then
            player2 = id
            showCursor(false,false)
            windows.menu_window_state.v = false
        end
        imgui.PopFont()
        imgui.End()
    end
    if windows.secondary_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(sw - 375, 50), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        if checkbox.check_11.v then imgui.Begin(u8"������ �����������", windows.secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
        else imgui.Begin(u8"������ �����������.", windows.secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders) end
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.ShowCursor = false
        imgui.PushFont(fontsize)
        imgui.BeginGroup()
            if menu == 'open mp' then
                imgui.CenterText(u8'������ �������� �����������?')
                if imgui.Button(u8'��', imgui.ImVec2(125, 25)) then menu = '�����������' func5:run() end imgui.SameLine()
                if imgui.Button(u8'���', imgui.ImVec2(125, 25)) or wasKeyPressed(VK_ESCAPE) then windows.secondary_window_state.v = false end
            end
            if menu == '�����������' then
                imgui.CenterText(u8'������� �������� ����������� ��� ���.')
                if imgui.Button(u8'������� �������', imgui.ImVec2(150,24)) then menu = '������� �������' end imgui.SameLine()
                if imgui.Button(u8'���������', imgui.ImVec2(150,24)) then menu = '���������' end 
                if imgui.Button(u8'������', imgui.ImVec2(150,24)) then menu = '������' end imgui.SameLine()
                if imgui.Button(u8'������ �����', imgui.ImVec2(150,24)) then menu = '������ �����' end
                if imgui.Button(u8'��� �����������', imgui.ImVec2(310,24)) then menu = 'custom' sampCloseCurrentDialogWithButton(0) showCursor(true,false) end
                imgui.PushItemWidth(310)
                imgui.Combo('##color2', option_color, colors, 6)
                imgui.PopItemWidth()
                imgui.Tooltip(u8'���� /mess')
                if imgui.Button(u8'�������� ����� ��������') then imgui.OpenPopup('custom') sampCloseCurrentDialogWithButton(0) showCursor(true,false) end
                imgui.SameLine()
                imgui.SetCursorPosX(200)
                if imgui.Button(u8'� ���������', imgui.ImVec2(120,24)) then thisScript():reload() showCursor(false,false) end
                imgui.InputTextMultiline("##����� ��������� �����", text_myprize, imgui.ImVec2(310,25))
                imgui.Tooltip(u8('���� ������� ����������� �������� ' .. u8:decode(text_myprize.v)))
                if imgui.BeginPopup('custom') then
                    imgui.Text(u8'������ "_" �������� ����, ��������� � ������ ����.\n�� ������ ��������� ����� ����� ������ ����� �������\n������ "*" �������� ��� ��������� ���� �� ������� ����.')
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
            if menu == '������� �������' then
                imgui.CenterText(u8('� ����������� ' .. menu))
                imgui.TextWrapped(u8'���������� ����������� ���������� �������, ��� ������ � �����, ����� ���� �� ���������� �����������, � ������� � ������� �� ����� �� ������� ������� /try ����, ���� ������ - ��������, ��� - ���������� � �����, ������� ���, ���� � ����� �� ��������� 1 �����, �� � ����� �����������.')
                if imgui.Button(u8'������ ����', imgui.ImVec2(300,24)) then sbor_mp(menu, 8, option_color.v, 1) menu = '������� ��' end
            end
            if menu == '������' then
                imgui.CenterText(u8('� ����������� ' .. menu))
                imgui.TextWrapped(u8'������ ����������� ���-�� ������� ���������� ��������, ����� ��������� ������� � ������������� �� ������, �������� �� ������ � ����������� �������, ���� �� ��������� ���������.')
                if imgui.Button(u8'������ ����', imgui.ImVec2(300,24)) then
                    menu = '������� ��'
                    lua_thread.create(function()
                        sbor_mp('������', 5, option_color.v, 0)
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        if cfg2.settings.wallhack then sampProcessChatInput('/wh') end -- ��������� �� ���� ��� ��������
                        func2:run() 
                        while menu ~= '���������' do wait(500) end
                        sampSendChat('/mess ' .. option_color.v .. ' �������� ������ � 10 ������, ����� ���� ����������� �� ������ :3')
                        sampSendChat('/dmcount 10')
                        for i = 0,1 do
                            setVirtualKeyDown(118, true)
                            wait(200)
                            setVirtualKeyDown(118, false)
                        end
                        sampAddChatMessage(tag .. '�� ������ ������������, � �� ������� ���������', -1)
                    end)
                end
            end
            if menu == '���������' then
                imgui.CenterText(u8('� ����������� ' .. menu))
                imgui.TextWrapped(u8'������ ����������� ���-�� ������� ���������� ��������, ������������� ������� � ����� � ������� ���������/��, ���� ������� � ����� - ����������� /r')
                if imgui.Button(u8'������ ����', imgui.ImVec2(300,24)) then
                    menu = '������� ��'
                    lua_thread.create(function()
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        sampSendChat('/tpcor 1566.73 -1242.10 277.88')
                        wait(2000)
                        sampSendChat('/tpcor 1566.73 -1242.10 277.88')
                        sbor_mp('���������', nil, option_color.v, 0)
                        while menu ~= '���������' do wait(500) end
                        sampSendChat('/dmcount 3')
                        sampAddChatMessage(tag .. '������ ���������...', -1)
                        sampSendChat('/veh 601 1 1')
                        while getClosestCarId() > 1 and sampIsDialogActive() do wait(200)  end
                        func4:run()
                        sampSendChat('/s')
                        sampAddChatMessage(tag .. '������� ���������! ��� ��������� � ��� �� ����� ����������� /r', -1)
                        sampAddChatMessage(tag .. '������� ���������! ��� ��������� � ��� �� ����� ����������� /r', -1)
                        sampAddChatMessage(tag .. '������� ���������! ��� ��������� � ��� �� ����� ����������� /r', -1)
                    end)
                end
            end
            if menu == '������ �����' then
                imgui.CenterText(u8('� ����������� ' .. menu))
                imgui.TextWrapped(u8'���������� ����������� ���������� �������, ��� ������ � �����, ����� ���� �� ���������� �����������, � ������ ������� �� ������� (����� ����� ��� ������� ������� ����� ���������), ����� 2 �������, ��������� ��� + 1 �� ������ - ��������� ������, � ����� �� ������. ����� ������ �� �� ����� ������� � ��������� "������ PVP", ���������� ��������� �� ���������.')
                if imgui.Button(u8'������ ����', imgui.ImVec2(300,24)) then sbor_mp(menu, 4, option_color.v, 0) menu = '������� ��' end
            end
            if menu == 'custom' then
                imgui.TextWrapped(u8'������� �������� ���� �����������')
                imgui.Text(u8'�������� �����������')
                imgui.SameLine()
                imgui.PushItemWidth(127)
                imgui.InputText('##mympname', MyTextMP)
                imgui.PopItemWidth()
                if imgui.Button(u8'������ �����', imgui.ImVec2(150,24)) then imgui.OpenPopup('start_text') end imgui.SameLine()
                if imgui.Button(u8'����� �����', imgui.ImVec2(150,24)) then imgui.OpenPopup('end_text') end
                if imgui.BeginPopup('start_text') then
                    imgui.Text(u8'������ ������������ ������� wait(1) ��� �������� �������� 1 �������')
                    imgui.InputTextMultiline("##start_text", MyTextMP_start, imgui.ImVec2(500, 300))
                    imgui.EndPopup()
                end
                if imgui.BeginPopup('end_text') then
                    imgui.Text(u8'������ ������������ ������� wait(1) ��� �������� �������� 1 �������')
                    imgui.InputTextMultiline("##end_text", MyTextMP_end, imgui.ImVec2(500, 300))
                    imgui.EndPopup()
                end
                imgui.Text(u8'��� ����� �������?') imgui.SameLine()
                imgui.PushItemWidth(150)
                imgui.Combo('##komnata', option_komnata, {u8'��� �������',u8'������� �������', u8'������ �����', u8'�������', u8'��������', u8'Fall Guys'}, 5)
                imgui.PopItemWidth()
                if imgui.Button(u8'������ ����', imgui.ImVec2(300,24)) and #(MyTextMP.v) > 3 then
                    menu = '������� ��'
                    if option_komnata.v == 0 then komnata_mymp = false
                    elseif option_komnata.v == 1 then komnata_mymp = 8  --������� �������
                    elseif option_komnata.v == 2 then komnata_mymp = 4  --������ �����
                    elseif option_komnata.v == 3 then komnata_mymp = 5  --�������
                    elseif option_komnata.v == 4 then komnata_mymp = 7  --��������
                    elseif option_komnata.v == 5 then komnata_mymp = 11 end --���� ����
                    sbor_mp(u8:decode(MyTextMP.v), komnata, option_color.v, 0)
                end
                if imgui.Button(u8'��������� ������ �����������', imgui.ImVec2(300,24)) then
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
                imgui.CenterText(u8'����������� �����������')
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
            if menu == '������� ��' then
                if imgui.Button(u8'��������� � �����������', imgui.ImVec2(300,24)) then
                    if #(u8:decode(text_myprize.v)) ~= 0 then
                        sampSendChat('/mess ' .. option_color.v .. ' ���� ������� ����������� ���������� ' .. u8:decode(text_myprize.v) .. '. ����������, �������� ����� ���������!')
                    else sampSendChat('/mess ' .. option_color.v .. ' �������� �� ����������� �� ��� ������, ������� ��� ��������� - /tpmp') end
                end
                if imgui.Button(u8'������� ��������', imgui.ImVec2(300,24)) then
                    if not sampIsDialogActive() then
                        menu = '���������'
                        lua_thread.create(function()
                            sampSendChat('/mp')
                            sampSendDialogResponse(5343, 1, 0)
                            while not sampIsDialogActive(5343) do wait(200) end
                            while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                            local _, myid = sampGetPlayerIdByCharHandle(playerPed)
                            sampProcessChatInput('/stw ' .. myid ..' 38 5000')
                            cursor = not cursor
                            showCursor(false,false)
                            if #(MyTextMP.v) ~= 0 then                  -- ���� �� �� ������� - ��� ����� ���� ����
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
            if menu == '���������' then
                if imgui.Button(u8'������ ���� ��', imgui.ImVec2(300,24)) then
                    lua_thread.create(function()
                        if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                        sampSendDialogResponse(5343, 1, 2)
                        while not sampIsDialogActive(5343) do wait(200) end
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                    end)
                end
                if imgui.Button(u8'�������� � ���� ������', imgui.ImVec2(300,24)) then
                    lua_thread.create(function()
                        if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                        sampSendDialogResponse(5343, 1, 3)
                        while not sampIsDialogActive(5343) do wait(200) end
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                    end)
                end
                if imgui.Button(u8'������ ���� ������', imgui.ImVec2(300,24)) then imgui.OpenPopup('gun') end
                if player1 and imgui.Button(u8'��������������� ������� ������', imgui.ImVec2(300,24)) then sampSendChat('/gethere '..player1) end
                if player2 and imgui.Button(u8'��������������� ������� ������', imgui.ImVec2(300,24)) then sampSendChat('/gethere '..player2) end
                if (player1 and player2) and imgui.Button(u8'������ PVP', imgui.ImVec2(300,24)) then
                    lua_thread.create(function()
                        if not sampIsDialogActive(5343) then sampSendChat('/mp') end
                        sampSendDialogResponse(5343, 1, 2)
                        while not sampIsDialogActive(5343) do wait(200) end
                        while sampIsDialogActive(5343) do sampCloseCurrentDialogWithButton(0) wait(200) end
                        sampSendChat('/mess '..option_color.v .. ' �� ���� ����� �������: ' .. sampGetPlayerNickname(player1) .. '['..player1..']' .. ' � ' ..sampGetPlayerNickname(player2) ..'['..player2..']')
                        sampSendChat('/mess '..option_color.v .. ' � �������� ������ � 6 ������, ����� ���� �������� �����...')
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
                            sampSendDialogResponse(5346, 1, 1, i..', 500') --������ 500 ������ ���������� ������
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
            if menu ~= '�����������' then
                imgui.PushFont(fontsize)
                if imgui.Button(u8'��������� ����������� ��������', imgui.ImVec2(300,24)) then thisScript():reload() showCursor(false,false) end
                imgui.PopFont()
            end
            imgui.Checkbox(u8'������������ ����', checkbox.check_11)
            imgui.Tooltip(u8'���� ������� ������� - ���� ����� ������� ��������.')
            if imgui.Checkbox(u8'����-���� �����������', checkbox.check_10) then
                if checkbox.check_10.v then func3:terminate()
                else func3:run() end
            end
            imgui.Tooltip(u8'������������� ������ �����, ���� ����� ������ � ����� ������.\n����� �������� ��������������, ������ ��������� ��������� �� �������������.')
            imgui.CenterText(u8'��������� ������� - ������� F')
            imgui.CenterText(u8'���� �������������� � ������� - ��� + 1')
        end
        if wasKeyPressed(VK_F) and not (sampIsDialogActive() or sampIsChatInputActive()) then
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
function sbor_mp(name, komnata, color, inter) -- �������� ��, ��������� �������� (��, ������� � �.�), ���� ����, ��������
    if start_mp then
        return false
    else
        start_mp = true
        lua_thread.create(function()
            if not sampIsDialogActive(5343) then 
                sampCloseCurrentDialogWithButton(0) 
                sampSendChat('/mp')
                while not sampIsDialogActive(5343) do wait(100) end
            end -- ���� ������ ������ ��������� �����
            if komnata then
                sampSendDialogResponse(5343, 1, komnata) -- �� � �������
                wait(2000)  -- ���� 2 ������� ���� ��������� ��������
                sampSendDialogResponse(5343, 1, komnata) -- �� �2 � �������
            end
            sampSendDialogResponse(5343, 1, 14) -- ���������
            sampSendDialogResponse(16066, 1, 1) -- ����������� ���
            sampSendDialogResponse(16067, 1, 0, '990') -- ����������� ���
            sampSendDialogResponse(16066, 1, 2) -- ��������� ���������
            sampSendDialogResponse(16068, 1, 1, inter) -- ���������� ��������
            sampSendDialogResponse(16066, 1, 0) -- ���������� ����������
            sampSendDialogResponse(16066, 0, 0) -- ��������� ����
            while not sampIsDialogActive(5343) do wait(200) end -- ������������ �� ���������� ���������, ���� ����� �������� ������
            while sampIsDialogActive() do sampCloseCurrentDialogWithButton(0) wait(200) end
            sampSendChat('/mess '..color.. ' ���������� ����������� '..name..' ����� ������� �������')
            sampSendChat('/mp')
            sampSendDialogResponse(5343, 1, 0) -- ��������� ���� �������� ��
            sampSendDialogResponse(5344, 1, 1, name) -- �������� ��
            while not sampIsDialogActive(5343) do wait(200) end
            while sampIsDialogActive() do sampCloseCurrentDialogWithButton(0) wait(200) end
            if #MyTextMP.v == 0 then 
                for k,v in pairs(textSplit(string.gsub(cfg.AT_MP.text, '_', color),'@')) do
                    if v:find('*') then 
                        if #(u8:decode(text_myprize.v)) > 0 then sampSendChat(string.gsub(u8:decode(v), '*', u8:decode(text_myprize.v)))
                        else sampAddChatMessage(tag .. '���� �� ������.', -1) end
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
            if sampIsDialogActive() then sampCloseCurrentDialogWithButton(0) end -- ������������ ���� �����-�� ������ ��������� ��������
        end)
    end
end
function find_weapon()
    local _, myid = sampGetPlayerIdByCharHandle(playerPed)
    while (menu ~= '���������' and menu ~= '������� ��') do wait(3000) end
    while true do
        wait(2000)
        for _,v in pairs(playersToStreamZone()) do
            local _, handle = sampGetCharHandleBySampPlayerId(v) 
            if v ~= myid then
                if getCurrentCharWeapon(handle) ~= 0 then
                    while sampIsDialogActive() do wait(50) sampCloseCurrentDialogWithButton(0) end
                    sampAddChatMessage(tag .. '���������� ������� ����� ��. �����: ' .. sampGetPlayerNickname(v) .. '[' .. v .. ']. ������: ' .. (require 'game.weapons').get_name(getCurrentCharWeapon(handle)) , -1)
                    sampSendChat('/jail ' .. v .. ' 300 ������ �� �����������')
                end
            end
        end
    end
end 
function time()
    while true do
        wait(60000)
        cfg.info[5] = cfg.info[5] + 1
    end
end
function update_info()
    info_array = {}
    while true do
        wait(10000)
        for i = 0, #cfg.info do
            if i == 0 then
                if cfg.AT_MP.mynick then info_array[0] = mynick .. ' | ID: '..myid end
                if cfg.AT_MP.data then info_array[1] = os.date('%H:%M | ') .. os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year end
                if cfg.AT_MP.myreports then 
                    info_array[2] = u8'��������: ' .. cfg.info[0]
                    if tick[i].v <= cfg.info[i] then info_array[2] = info_array[2] .. " +" end
                end
            elseif cfg.AT_MP.warningban and i == 1 then 
                info_array[3] = u8'�����: ' .. cfg.info[1]
                if tick[i].v <= cfg.info[i] then info_array[3] = info_array[3].." +" end
            elseif cfg.AT_MP.warningmute and i == 2 then 
                info_array[4] = u8'�����: ' .. cfg.info[2]
                if tick[i].v <= cfg.info[i] then info_array[4] = info_array[4] .." +" end
            elseif cfg.AT_MP.warningjail and i == 3 then 
                info_array[5] =  u8'�������: ' .. cfg.info[3]
                if tick[i].v <= cfg.info[i] then info_array[5] = info_array[5].. " +" end
            elseif cfg.AT_MP.warningkick and i == 4 then 
                info_array[6] = u8'�����: ' .. cfg.info[4]
                if tick[i].v <= cfg.info[i] then info_array[6] = info_array[6].." +" end
            elseif cfg.AT_MP.warningmp and i == 6 then 
                info_array[7]= u8'�����������: '..cfg.info[6]
                if tick[i].v <= cfg.info[i] then info_array[7] = info_array[7].." +" end
            elseif cfg.AT_MP.myonline and i == 5 then 
                info_array[8]=u8'������: ' .. cfg.info[5] .. u8' ���.'
                if tick[i].v <= cfg.info[i] then info_array[8] = info_array[8].." +" end
            end
        end
        save()
    end
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if dialogId == 5343 and menu == 'open mp' then
        windows.secondary_window_state.v = true
        imgui.Process = true
    end
end
function getClosestCarId() -- ������ �� ��������� ����
    local minDist = 200 -- ���������
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

function save()
    inicfg.save(cfg,'AT//AT_MP.ini')
end
function radius()
    local font_watermark = renderCreateFont("Javanese Text", 12, font.BOLD + font.BORDER + font.SHADOW)
    while true do
        wait(3)
        renderFontDrawText(font_watermark, '������� � �������: ' .. #(playersToStreamZone()) -1 , sh*0.5, sw*0.5, 0xCCFFFFFF)
    end
end
sampRegisterChatCommand('state', function()
    windows.static_window_state.v = not windows.static_window_state.v
    imgui.Process = windows.static_window_state.v
end)