require 'lib.moonloader'
script_name 'AT_FastSpawn'
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local version = 1.4
local imgui = require 'imgui' 
local ffi = require "ffi"
local fa = require 'faicons'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding' 
local inicfg = require 'inicfg'
local my_lib = require 'my_lib'
local directIni = 'AT//AT_FS.ini'
encoding.default = 'CP1251'
local u8 = encoding.UTF8 
local key = require 'vkeys'
local cfg2 = inicfg.load({
	settings = {
		versionFS = version,
		style = 0,
	},
}, 'AT//AT_main.ini')
cfg2.settings.versionFS = version
inicfg.save(cfg2,'AT//AT_main.ini')
style(cfg2.settings.style)
local cfg = inicfg.load({
	AT_FastSpawn = {
        spawn = true,
		autorizate = false,
		autoalogin = false,
		parolalogin = nil,
		parolaccount = nil,
		style = 0,
		server = nil,
		nickname = nil,
	},
	command = {[0] = ''},
	wait_command = {[0] = 0},
}, directIni)
inicfg.save(cfg,directIni)
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local buffer = {}
local sw, sh = getScreenResolution()
local style_selected = imgui.ImInt(cfg2.settings.style)
local text_buffer = imgui.ImBuffer(4096)
local text_buffer2 = imgui.ImBuffer(4096)
local inputCommand = {[0] = imgui.ImBuffer(u8(cfg.command[0]), 256)}
local inputWait = {[0] = imgui.ImInt(cfg.wait_command[0]),}
local checked_test = imgui.ImBool(cfg.AT_FastSpawn.autorizate)
local checked_test2 = imgui.ImBool(cfg.AT_FastSpawn.autoalogin)
local checked_test3 = imgui.ImBool(cfg.AT_FastSpawn.spawn)

local secondary_window_state = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)


function sampev.onServerMessage(color,text)
	if text == ('Вы успешно авторизовались!') then
		start_click_shift = true
	elseif text:match("%[A%] Администратор (.+)%[(%d+)%] %((%d+) level%) авторизовался в админ панели") and text:match(nick) then
		access_alogin = true
	end
end
function main()
	while not isSampAvailable() do wait(0) end
	for k,v in pairs(cfg.command) do if (v and #(v)>1) and k~=0 then inputCommand[#inputCommand+1] = imgui.ImBuffer(u8(tostring(v)), 256) else table.remove(cfg.command, k) inicfg.save(cfg, directIni) end end
	for k,v in pairs(cfg.wait_command) do inputWait[#inputWait+1] = imgui.ImInt(v) end
	if cfg.AT_FastSpawn.spawn then
		while not sampIsLocalPlayerSpawned() do
			if not sampIsChatInputActive() and not sampIsDialogActive() and start_click_shift then
				setVirtualKeyDown(16, true)
				wait(100)
				setVirtualKeyDown(16, false) 
			end
			wait(200)
		end
		start_click_shift = nil
	end
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)
	wait(3000)
	if autorizate and cfg.AT_FastSpawn.parolalogin and cfg.AT_FastSpawn.autoalogin and cfg.AT_FastSpawn.server == sampGetCurrentServerAddress() and cfg.AT_FastSpawn.nickname == nick then
		while not access_alogin do
			wait(0)
			while sampIsDialogActive() do wait(100) sampCloseCurrentDialogWithButton(0) end
			sampSendChat('/alogin ' .. cfg.AT_FastSpawn.parolalogin)
			wait(6000)
		end
		access_alogin = nil
	end
	if autorizate and cfg.AT_FastSpawn.server == sampGetCurrentServerAddress() and cfg.AT_FastSpawn.nickname == nick then
		for i = 0, #cfg.command do
			if cfg.command[i] and #(cfg.command[i]) >= 2 then
				if cfg.wait_command[i] == 0 then press_wait = 500
				elseif cfg.wait_command[i] == 1 then press_wait = 1000
				elseif cfg.wait_command[i] == 2 then press_wait = 1500
				elseif cfg.wait_command[i] == 3 then press_wait = 2000
				elseif cfg.wait_command[i] == 4 then press_wait = 3000 end
				if #(tostring(cfg.command[i])) ~= 0 and #(tostring(press_wait)) ~= 0 then
					wait(press_wait)
					while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end
					sampProcessChatInput(cfg.command[i])
				end
			end
		end
	end
end
function imgui.OnDrawFrame()
    if not main_window_state.v and not secondary_window_state.v then
        imgui.Process = false
    end
    if main_window_state.v then 
        imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('-- FastSpawn --', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
        imgui.Text(u8'Пароль от админки:')
        imgui.InputText('##SearchBar', text_buffer)
        imgui.SameLine()
        if imgui.Button(u8'Сохранить') then
			printStyledString('save', 1000, 7)
            cfg.AT_FastSpawn.parolalogin = text_buffer.v .. '%'
			save()
        end
        imgui.Text(u8'Пароль от аккаунта:')
        imgui.InputText('##SearchBar2', text_buffer2)
        imgui.SameLine()
        if imgui.Button(u8'Сoхранить') then
			printStyledString('save', 1000, 7)
            cfg.AT_FastSpawn.parolaccount = text_buffer2.v ..'%'
            save()
        end
        imgui.Separator()
        if imgui.Checkbox(u8"Автоввод пароля", checked_test) then
            cfg.AT_FastSpawn.autorizate = not cfg.AT_FastSpawn.autorizate
			save()
        end
        if imgui.Checkbox(u8'Автоввод А пароля', checked_test2) then
            cfg.AT_FastSpawn.autoalogin = not cfg.AT_FastSpawn.autoalogin
			save()
        end
        if imgui.Checkbox(u8'АвтоSpawn', checked_test3) then
            cfg.AT_FastSpawn.spawn = not cfg.AT_FastSpawn.spawn
			save()
        end
        if imgui.Button(u8"Добавить команды") then
            secondary_window_state.v = not secondary_window_state.v
        end
		imgui.PopFont()
        imgui.End()
    end
	if secondary_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Добавить команды', secondary_window_state, imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.PushFont(fontsize)
		imgui.Text(u8'      Команда')
		imgui.SameLine()
		imgui.Text(u8'    Задержка')
		for i = 0, #inputCommand do
			if inputCommand[i] then
				imgui.PushItemWidth(100)
				if imgui.InputText('##inputcommand' .. tostring(i), inputCommand[i]) then
					cfg.command[i] = u8:decode(inputCommand[i].v)
					save()
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(100)
				inputWait[i].v = cfg.wait_command[i]
				if imgui.Combo("##selected" .. i, inputWait[i], {u8'0.5 сек', u8'1 сек', u8'1.5 сек', u8'2 сек', u8'3 сек'}, 5) then
					cfg.wait_command[i] = inputWait[i].v
					save()
				end
				imgui.PopItemWidth()
			end
		end
		if imgui.Button(u8'Добавить', imgui.ImVec2(210,24)) then
			if #(cfg.command) <= 10 then
				if #(cfg.command[#(cfg.command)]) >= 2 then
					cfg.command[#(cfg.command) + 1] = ''
					cfg.wait_command[#(cfg.wait_command) + 1] = 0
					save() 
					inputCommand[#inputCommand+1] = imgui.ImBuffer(u8(cfg.command[#(cfg.command)]), 256)
					inputWait[#inputWait+1] = imgui.ImInt(cfg.wait_command[#(cfg.wait_command)])
				else sampAddChatMessage(tag .. 'Прошлый пункт не заполнен, а значит будет выводить пустую строку.', -1) end
			else sampAddChatMessage(tag .. 'Вы достигли максимума - 10 команд.', -1) end
		end
		imgui.PopFont()
		imgui.End()
	end
end
function save()
	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	cfg.AT_FastSpawn.server = sampGetCurrentServerAddress()
	cfg.AT_FastSpawn.nickname = sampGetPlayerNickname(id)
	inicfg.save(cfg, directIni)
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
    if (dialogId == 658 or dialogId == 657) and cfg.AT_FastSpawn.spawn then
		sampSendDialogResponse(dialogId, 1, 0, _)
		sampCloseCurrentDialogWithButton(0)
		autorizate = true
		return false
    end
    if dialogId == 1 and cfg.AT_FastSpawn.autorizate and cfg.AT_FastSpawn.parolaccount and not inputpassword then
		local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
		if cfg.AT_FastSpawn.nickname == sampGetPlayerNickname(id) and cfg.AT_FastSpawn.server == sampGetCurrentServerAddress() then
			printStyledString('authorization ...', 1000, 7)
			sampSendDialogResponse(dialogId, 1, _, cfg.AT_FastSpawn.parolaccount)
			inputpassword = true
		end
    end
end



sampRegisterChatCommand('fs', function()
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
end)
sampRegisterChatCommand('fsoff', function()
    thisScript():unload()
end)