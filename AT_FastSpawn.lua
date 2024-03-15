require 'lib.moonloader'
require 'my_lib'
script_name 'AT_FastSpawn'
script_author 'Neon4ik'
local version = 1.8
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
	settings = {
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
}, 'AT//AT_FS.ini')
inicfg.save(cfg,'AT//AT_FS.ini')
local tag = '{2B6CC4}Admin Tools: {F0E68C}'
local buffer = {}
local style_selected = imgui.ImInt(cfg2.settings.style)
local text_buffer = imgui.ImBuffer(4096)
local text_buffer2 = imgui.ImBuffer(4096)
local inputCommand = {[0] = imgui.ImBuffer(u8(cfg.command[0]), 256)}
local inputWait = {[0] = imgui.ImInt(cfg.wait_command[0]),}
local checked_test = imgui.ImBool(cfg.settings.autorizate)
local checked_test2 = imgui.ImBool(cfg.settings.autoalogin)
local checked_test3 = imgui.ImBool(cfg.settings.spawn)
local access = false
local secondary_window_state = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)

function main()
	while not isSampAvailable() do wait(1000) end
	for k,v in pairs(cfg.command) do if (v and #(v)>1) and k~=0 then inputCommand[#inputCommand+1] = imgui.ImBuffer(u8(tostring(v)), 256) else table.remove(cfg.command, k) inicfg.save(cfg, 'AT//AT_FS.ini') end end
	for k,v in pairs(cfg.wait_command) do inputWait[#inputWait+1] = imgui.ImInt(v) end
	if sampIsLocalPlayerSpawned() then return false end
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local nick = sampGetPlayerNickname(id)
	while not sampIsLocalPlayerSpawned() do wait(0) end
	while true do
		if sampTextdrawIsExists(0) then
			if sampIsDialogActive(657) or sampIsDialogActive(658) then
				if sampTextdrawIsExists(494) or sampTextdrawIsExists(500) then
					break
				end
				if cfg.settings.spawn then
					sampSendDialogResponse(657, 1, 1)
					sampSendDialogResponse(658, 1, 1)
					wait(100)
					sampCloseCurrentDialogWithButton(1)
					setVirtualKeyDown(13, true)
					wait(200)						--- а потому что закрывается но не хрена не скрывается
					setVirtualKeyDown(13, false)
				end
				access = true
				break
			elseif sampIsDialogActive() then
				break
			elseif cfg.settings.spawn then
				local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if not sampIsLocalPlayerSpawned(id) then
					setVirtualKeyDown(16, true)
					wait(100)
					setVirtualKeyDown(16, false)
				end
			end
		elseif sampIsDialogActive(1) and not access then
			if cfg.settings.autorizate and cfg.settings.parolaccount then
				_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
				if cfg.settings.nickname == sampGetPlayerNickname(id) and cfg.settings.server == sampGetCurrentServerAddress() then
					printStyledString('~w~Auto authorization ~n~~p~FastSpawn', 4000, 7)
					sampSendDialogResponse(1, 1, 0, cfg.settings.parolaccount)
				end
			end
		end
		wait(500)
	end
	while sampIsDialogActive() do wait(0) end
	if cfg.settings.parolalogin and cfg.settings.autoalogin then
		sampSendChat('/alogin ' .. cfg.settings.parolalogin)
		wait(2000)
		sampSendChat('/alogin ' .. cfg.settings.parolalogin)
	end
	for i = 0, #cfg.command do
		if cfg.command[i] and #(cfg.command[i]) >= 2 then
			local press_wait = 0
			if cfg.wait_command[i] == 0 then press_wait = 500
			elseif cfg.wait_command[i] == 1 then press_wait = 1000
			elseif cfg.wait_command[i] == 2 then press_wait = 1500
			elseif cfg.wait_command[i] == 3 then press_wait = 2000
			elseif cfg.wait_command[i] == 4 then press_wait = 3000 end
			if #(tostring(cfg.command[i])) ~= 0 and #(tostring(press_wait)) ~= 0 then
				wait(press_wait)
				while sampIsDialogActive() or sampIsChatInputActive() do wait(100) end
				sampProcessChatInput(cfg.command[i])
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
            cfg.settings.parolalogin = text_buffer.v .. '%'
			save()
        end
        imgui.Text(u8'Пароль от аккаунта:')
        imgui.InputText('##SearchBar2', text_buffer2)
        imgui.SameLine()
        if imgui.Button(u8'Сoхранить') then
			printStyledString('save', 1000, 7)
            cfg.settings.parolaccount = text_buffer2.v ..'%'
            save()
        end
        imgui.Separator()
        if imgui.Checkbox(u8"Автоввод пароля", checked_test) then
            cfg.settings.autorizate = not cfg.settings.autorizate
			save()
        end
        if imgui.Checkbox(u8'Автоввод А пароля', checked_test2) then
            cfg.settings.autoalogin = not cfg.settings.autoalogin
			save()
        end
        if imgui.Checkbox(u8'АвтоSpawn', checked_test3) then
            cfg.settings.spawn = not cfg.settings.spawn
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
				if imgui.Combo("##selected" .. tostring(i), inputWait[i], {u8'0.5 сек', u8'1 сек', u8'1.5 сек', u8'2 сек', u8'3 сек'}, 5) then
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
	local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	cfg.settings.server = sampGetCurrentServerAddress()
	cfg.settings.nickname = sampGetPlayerNickname(id)
	inicfg.save(cfg, 'AT//AT_FS.ini')
end

sampRegisterChatCommand('fs', function()
    main_window_state.v = not main_window_state.v
    imgui.Process = main_window_state.v
end)

if not file_exists('moonloader\\control_work_AT.lua') then
	local dlstatus = require('moonloader').download_status
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/control_work_AT.lua", 'moonloader\\control_work_AT.lua', function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			reloadScripts()
		end
	end)
end



