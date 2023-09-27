require 'lib.moonloader'
script_name 'AdminTools Plus+' 
script_author 'Neon4ik'
local imgui = require 'imgui' 
local version = 0.2
local key = require 'vkeys'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local sampev = require 'lib.samp.events'
local dektor_window_state = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local text_buffer = imgui.ImBuffer(16384)
local text_buffer2 = imgui.ImBuffer(1024)
local text_buffer3 = imgui.ImBuffer(1024)
local tag = '{2F4F4F}AdminTools Plus+ для руководящего состава: {FF7F50}'
local sw, sh = getScreenResolution()
local selected_item = imgui.ImInt(1)
local selected_item2 = imgui.ImInt(0)
local inicfg = require 'inicfg'
local directIni = 'ATPlus.ini'
local offadmins = {}
local cfg = inicfg.load({
    settings = {
		prefixma = '2E8B57',
		prefixa = '87CEEB',
		prefixsa = 'FF4500',
    },
	listNoResult = {},
}, directIni)
inicfg.save(cfg, directIni)
local buffer = {
	PrefixMa = imgui.ImBuffer(cfg.settings.prefixma, 256),
	PrefixA = imgui.ImBuffer(cfg.settings.prefixa, 256),
	PrefixSa = imgui.ImBuffer(cfg.settings.prefixsa, 256),
}
local makeadmin = {}
local kai = {}
if selected_item.v == 0 then
	newlvl = 0
elseif selected_item.v == 1 then
	newlvl = 'Skip'
elseif selected_item.v == 2 then
	newlvl = 1
elseif selected_item.v == 3 then
	newlvl = 2
elseif selected_item.v == 4 then
	newlvl = 3
end
if selected_item2.v == 0 then
	SendKai = -1
elseif selected_item2.v == 1 then
	SendKai = -2
elseif selected_item2.v == 2 then
	SendKai = 0
elseif selected_item2.v == 3 then
	SendKai = 1
elseif selected_item2.v == 4 then
	SendKai = 2
elseif selected_item2.v == 5 then
	SendKai = '-'
end

function main()
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage(tag .. 'Скрипт инициализирован. Активация: /atp', -1)
	local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminToolsPlus.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "//AdminToolsPlus.ini" -- и тут ту же самую ссылку
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminToolsPlus.lua" -- Ссылка на сам файл
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
		lua_thread.create(function()
			wait(1000)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				AdminToolsPlus = inicfg.load(nil, update_path)
				if tonumber(AdminToolsPlus.script.version) > version then
					sampAddChatMessage(tag .. 'Найдено обновление. Рекомендуется обновится /updateplus', -1)
					update_state = true
				end
				os.remove(update_path)
			end
		end)
    end)
	sampRegisterChatCommand('updateplus', function()
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage(tag .. 'Скрипт успешно обновлен.', -1)
					showCursor(false,false)
                    os.remove(update_path)
					thisScript():reload()
				end
			end)
		else
			sampAddChatMessage(tag .. 'У вас установлена актуальная версия.')
		end
	end)
end
function imgui.OnDrawFrame()
	if not main_window_state.v and not secondary_window_state.v and not dektor_window_state.v then
		imgui.Process = false
		showCursor(false,false)
	end
	if dektor_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.3), sh * 0.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin("AdminTools+", dektor_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.SetCursorPosX(10)
		imgui.Text(u8'Мл.Администратор')
		imgui.SameLine()
		imgui.SetCursorPosX(150)
		imgui.PushItemWidth(100)
		if imgui.InputText('   ', buffer.PrefixMa) then
			cfg.settings.prefixma = buffer.PrefixMa.v
			inicfg.save(cfg,directIni)	
		end
		imgui.PopItemWidth()
		imgui.SetCursorPosX(10)
		imgui.Text(u8'Администратор')
		imgui.SameLine()
		imgui.SetCursorPosX(150)
		imgui.PushItemWidth(100)
		if imgui.InputText(' ', buffer.PrefixA) then
			cfg.settings.prefixa = buffer.PrefixA.v
			inicfg.save(cfg,directIni)	
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Ст.Администратор')
		imgui.SameLine()
		imgui.SetCursorPosX(150)
		imgui.PushItemWidth(100)
		if imgui.InputText('  ', buffer.PrefixSa) then
			cfg.settings.prefixsa = buffer.PrefixSa.v
			inicfg.save(cfg,directIni)	
		end
		imgui.PopItemWidth()
		imgui.Text(u8'/prfma - Выдать префикс МА\n/prfa - Выдать префикс  А\n/prfsa - Выдать префикс СА\n/prfpga - Выдать префикс ПГА\n/prfzga - Выдать префикс ЗГА\n/prfga - Выдать префикс ГА\n/prfcpec - Выдать префикс спеца')
		if imgui.Button(u8'Подвести итоги недели') then
			main_window_state.v = not main_window_state.v
			dektor_window_state.v = not dektor_window_state.v
		end
		imgui.End()
	end
	if main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.3), sh * 0.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Автоматическое подведение итогов.", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.InputTextMultiline("##", text_buffer, imgui.ImVec2(250, 300))
        if imgui.Button(u8'Пробить список администраторов', imgui.ImVec2(250, 25)) then
            if not sampIsDialogActive() then
				sampSendChat('/offadmins')
				sampAddChatMessage(tag .. 'Пройдите весь список, нажав клавишу: Далее.', -1)
			else
				sampAddChatMessage(tag .. 'Диалог закрыть стоило бы.', -1)
			end
        end
		if imgui.Button(u8'Пробить топ администрации', imgui.ImVec2(250, 25)) then
            if not sampIsDialogActive() then
				sampSendChat('/topadm')
			else
				sampAddChatMessage(tag .. 'Диалог закрыть стоило бы.', -1)
			end
        end
		if imgui.Button(u8'Выбрать диапазон баллов', imgui.ImVec2(250, 25)) then
			if offadmins and topadm then
				secondary_window_state.v = not secondary_window_state.v
			else
				sampAddChatMessage(tag .. 'Вы ещё не прошлись по спискам администраторов.', -1)
			end
		end
		imgui.Text(u8'После выставления всех параметров.')
		if imgui.Button(u8'Взаимодействие с Каем.', imgui.ImVec2(250, 25)) then
			text_buffer.v = ''
			for k, v in pairs(kai) do
				text_buffer.v = text_buffer.v .. u8(v) .. '\n'
			end
			kai = {} -- обнуляем настройки
		end
		if imgui.Button(u8'Отобразить новые уровни', imgui.ImVec2(250, 25)) then
			text_buffer.v = ''
			for k, v in pairs(makeadmin) do
				v = string.gsub(v, '  ', ' ') -- удаляем лишние пробелы если они имеются.
				text_buffer.v = text_buffer.v .. v .. '\n'
			end
		end
		if text_buffer.v:find('/makeadmin') then
			if imgui.Button(u8'Выдать уровни.', imgui.ImVec2(250, 25)) then
				text_buffer.v = u8'Ожидайте.\nНа каждого администратора по 2 сек.'
				lua_thread.create(function()
					for k, v in pairs(makeadmin) do
						v = string.gsub(v, '  ', ' ') -- удаляем лишние пробелы если они имеются.
						sampAddChatMessage(v, -1)
						wait(2000)
						while sampIsDialogActive() do
							wait(0)
						end
					end
				end)
				makeadmin = {} -- обнуляем настройки
			end
		end
        imgui.End()
    end
	if secondary_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"Настройки", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'От:')
		imgui.PushItemWidth(50)
		imgui.InputText(u8'  $', text_buffer2)
		imgui.PopItemWidth()
		imgui.SetCursorPosY(40)
		imgui.SetCursorPosX(80)
		imgui.Text(u8'До:')
		imgui.SetCursorPosX(75)
		imgui.PushItemWidth(50)
		imgui.InputText(' ', text_buffer3)
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить', imgui.ImVec2(115, 25)) then
			if (SendKai == 0 and newlvl ~= 0) or (SendKai ~= 0 and newlvl == 0) then
				text_buffer.v = u8'Проверьте точность ввода команд.\nНельзя снять с админки не кикнув с ВК'
			elseif text_buffer2.v and text_buffer3.v then -- проверка введен ли промежуток баллов
				if #text_buffer.v == 0 then -- если в основном меню ничего нет - вывести доп инфу
					text_buffer.v = u8'@all Итоги недели\nПодвёл итоги: AdminTools by N.E.O.N\nВ соответствии с еженедельной нормой\nПроводим реформацию состава.\n\n' 
				end
				if tonumber(text_buffer2.v) <  tonumber(text_buffer3.v)  then
					text_buffer.v = text_buffer.v .. '---------------------------------------------\n'
					if newlvl == 0 then
						text_buffer.v = (text_buffer.v .. '[' .. text_buffer2.v  .. ' - '.. text_buffer3.v .. u8' баллов] = Сняты с поста\n')
					elseif newlvl == 'Skip' then
						text_buffer.v = (text_buffer.v .. '[' .. text_buffer2.v  .. ' - '.. text_buffer3.v .. u8' баллов] = ' .. SendKai .. u8' пред(а)' .. '\n')
					else
						text_buffer.v = (text_buffer.v .. '[' .. text_buffer2.v  .. ' - '.. text_buffer3.v .. u8' баллов] = +' .. newlvl .. u8' LVL и ' .. SendKai .. u8' пред(а)' .. '\n')
					end
					text_buffer.v = text_buffer.v .. '---------------------------------------------\n'
					for _,k in pairs(topadm) do
						countball = string.sub(string.match(string.sub(k, -7), '%S+$'), 1, -4) -- КОЛ-ВО БАЛЛОВ
						nick = string.gsub(string.sub(k, 1, -4), '%s%s', '')-- LONDON = 100
						peremball = tonumber(string.match(string.sub(nick, -5), '%d[%d.,]*'))
						nick = string.gsub(nick, '= (%d+)', '')
						if tonumber(text_buffer2.v) <= tonumber(countball) and  tonumber(text_buffer3.v) >= tonumber(countball) then
							for k,v in pairs(offadmins) do
								peremlvl = tonumber(string.match(string.sub(v,-3), '%d[%d.,]*'))
								v = string.gsub(v, '=(%d+)', '') --v - Tenso_Nightcore
								checkalw = nil
								nick = string.gsub(nick, '=(%d+)', '')
								if string.sub(nick,1,-2) == ' ' then
									nick = string.sub(nick,1,-2)
								end
								v = string.gsub(v, '= (%d+)', '')
								nickv = string.gsub(v,'=(.+)', '')
								for h,m in pairs(cfg.listNoResult) do
									if nickv:match(m) then
										k,v = nil, nil
									end
								end
								if v then
									if v:find(nick) or v:find(string.sub(nick,1,-2)) then -- записываем в конфиг информацию о Кае
										if SendKai == 0 then
											kai[#kai + 1] = 'Кай кик ' .. nick
										elseif SendKai == 1 then
											kai[#kai + 1] = 'Кай пред ' .. nick
										elseif SendKai == 2 then
											kai[#kai + 1] = 'Кай пред 2 ' .. nick
										elseif SendKai == -1 then
											kai[#kai + 1] = 'Кай снять пред ' .. nick
										elseif SendKai == -2 then
											kai[#kai + 1] = 'Кай снять пред 2 ' .. nick
										end
										if tonumber(peremlvl) ~= 18 then -- Записываем информацию о /makeadmin и выводим инфу
											if newlvl ~= 'Skip' then
												if tonumber(newlvl) + tonumber(peremlvl) > 18 then
													newnewlvl = tonumber(newlvl) - 1
													if tonumber(newnewlvl) + tonumber(peremlvl) > 18 then
														newnewlvl = tonumber(newnewlvl) - 1
														makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newnewlvl))
														text_buffer.v = text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' баллов\n'
													end
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newnewlvl))
													text_buffer.v = text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' баллов\n'
												else
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newlvl))
													text_buffer.v = text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' баллов\n'
												end
											else
												text_buffer.v = text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' баллов\n'
											end
										else
											text_buffer.v = text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' баллов\n'
										end
									end
								end
							end
						end
					end
					text_buffer.v = string.gsub(text_buffer.v, '  ', ' ') -- удаляем лишние пробелы между никами если они имеются
				else
					sampAddChatMessage(tag .. 'Вы не указали количество баллов', -1)
				end
			else
				sampAddChatMessage(tag .. 'Данные введены некорректно.', -1)
			end
		end
		imgui.Text(u8'Уровень.')
		imgui.PushItemWidth(115)
		if imgui.Combo(u8'', selected_item, {u8'Снять', '0', '1', '2', '3'}, 5) then
			if selected_item.v == 0 then
				newlvl = 0
			elseif selected_item.v == 1 then
				newlvl = 'Skip'
			elseif selected_item.v == 2 then
				newlvl = 1
			elseif selected_item.v == 3 then
				newlvl = 2
			elseif selected_item.v == 4 then
				newlvl = 3
			end
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Кай.')
		imgui.PushItemWidth(115)
		if imgui.Combo(u8'  ', selected_item2, {u8'Снять 1 пред', u8'Снять 2 преда', u8'Кикнуть', u8'Выдать 1 пред', u8'Выдать 2 преда', u8'Ничего'}, 6) then
			if selected_item2.v == 0 then
				SendKai = -1
			elseif selected_item2.v == 1 then
				SendKai = -2
			elseif selected_item2.v == 2 then
				SendKai = 0
			elseif selected_item2.v == 3 then
				SendKai = 1
			elseif selected_item2.v == 4 then
				SendKai = 2
			elseif selected_item2.v == 5 then
				SendKai = 'Skip'
			end
		end
		imgui.PopItemWidth()
		imgui.Text(u8'Добавить искл: /newadm')
		imgui.Text(u8'Удалить искл: /deladm')
		imgui.End()
	end
end
function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false)
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if dialogId == 4829 then
		text = textSplit(text, '\n')
		for k,v in pairs(text) do
			v = string.sub(v, 9)
			if v:match('Оффлайн') then -- адаптируемся под условия
				v = string.sub(v, 1, -16)
			end
			if v:match('Онлайн') then -- адаптируемся под условия
				v = string.sub(v, 1, -15)
			end
			if #v > 0 and v ~= 'Ник	{ffffff}Уровень администратора	' and v~='<<< Назад' and v ~= 'Далее >>>' then
				v = string.sub(v, 1, -2)
				lvl1 = string.sub(v, -2) -- считываем первое значение уровня
				if string.sub(v, -2) == '1' then -- если администратор выше 10 уровня - изменить настройки
					v = string.sub(v, 1, -2)
					lvl2 = string.sub(v, -2)
				end
				if lvl2 then
					lvl = lvl1 .. lvl2 -- Конкретный, точный лвл
				else
					lvl = lvl1
				end
				v = string.sub(v, 1, -3) 
				for _,s in pairs(offadmins) do -- защита от повторного открытия списка, удаляем повторяшек
					if s == (v .. '=' .. lvl) then
						offadmins[#offadmins] = nil
					end
				end
				offadmins[#offadmins + 1] =  (v .. '=' .. lvl) -- записываем информацию о админе в конфиг
				lvl, lvl1, lvl2 = nil
			end
		end
	end 
	if dialogId == 2232 then
		topadm = {} -- создаем массив
		text = textSplit(text, '\n')
		for k,v in pairs(text) do
			if #v > 0 and v ~= '{ffffff}Ник	{ffffff}Уровень администратора	{ffffff}Баллов' then
				v = string.sub(v, 10)
				if string.sub(v, -1) == '0' or string.sub(v, -1) == '1' or string.sub(v, -1) == '2' or string.sub(v, -1) == '3' or string.sub(v, -1) == '4' or string.sub(v, -1) == '5' or string.sub(v, -1) == '6' or string.sub(v, -1) == '7' or string.sub(v, -1) == '8' or string.sub(v, -1) == '9' then
					v = string.sub(v,2) -- удаляем информацию о LVLах, для этого у нас есть /offadmins
				end
				v = string.sub(v, 2)
				if string.sub(v, 1, 1) == ' ' then -- удаляем лишний пробел
					v = string.sub(v, 2)
				end
				ballov = string.match(v, '%S+$') -- узнаем кол-во баллов
				if ballov then
					v = string.sub(v, 1, -#ballov) -- удаляем из никнейма кол-во баллов
				end
				v = string.sub(v, 1, -5)
				topadm[#topadm + 1] = (v .. ' = ' .. ballov) -- записываем файл в конфигурацию
			end
		end
	end
end
sampRegisterChatCommand('deladm', function(param)
	if #param >= 3 then
		for k, v in pairs(cfg.listNoResult) do
			if cfg.listNoResult[k] == param then
				cfg.listNoResult[k] = nil
				inicfg.save(cfg,directIni)
				sampAddChatMessage(tag .. 'Выбранный вами администратор ' .. param .. ' был успешно удалено из списка', -1)
				a = true
				break
			else    
				a = false
			end
		end
		if not a then
			sampAddChatMessage(tag .. 'Такого администратора в списке нет.', -1)
			a = nil
		end
	end
end)
sampRegisterChatCommand('newadm', function(param)
	if #param >= 3 then
		for k, v in pairs(cfg.listNoResult) do
			if cfg.listNoResult[k] == param then
				sampAddChatMessage(tag .. 'Выбранный вами администратор - ' .. param .. ' уже имеется в списке.' , -1)
				a = true
				break
			else    
				a = false
			end
		end
		if not a then
			cfg.listNoResult[#cfg.listNoResult + 1] = param
			inicfg.save(cfg,directIni)
			sampAddChatMessage(tag .. 'Выбранный вами администратор - ' .. param .. ' был успешно добавлен в исключения', -1)
			a = nil
		end
	end
end)
sampRegisterChatCommand('prfma', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Мл.Администратор " .. cfg.settings.prefixma)
	end
end)
sampRegisterChatCommand('prfa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Администратор " .. cfg.settings.prefixa)
	end
end)
sampRegisterChatCommand('prfsa', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Ст.Администратор " .. cfg.settings.prefixsa)
	end
end)
sampRegisterChatCommand('prfpga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Помощник.Глав.Администратора " .. color())
	end
end)
sampRegisterChatCommand('prfzga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Зам.Глав.Администратора " .. color())
	end
end)
sampRegisterChatCommand('prfga', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Главный-Администратор " .. color())
	end
end)
sampRegisterChatCommand('prfcpec', function(param) 
	if(param:match("(%d+)")) then
		sampSendChat("/prefix " .. param .. " Спец.Администратор " .. color())
	end
end)
sampRegisterChatCommand('atp', function()
	dektor_window_state.v = not dektor_window_state.v
	imgui.Process = dektor_window_state.v
end)
function apply_custom_style()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
 
	 style.WindowPadding = ImVec2(15, 15)
	 style.WindowRounding = 15.0
	 style.FramePadding = ImVec2(5, 5)
	 style.ItemSpacing = ImVec2(12, 8)
	 style.ItemInnerSpacing = ImVec2(8, 6)
	 style.IndentSpacing = 25.0
	 style.ScrollbarSize = 15.0
	 style.ScrollbarRounding = 15.0
	 style.GrabMinSize = 15.0
	 style.GrabRounding = 7.0
	 style.ChildWindowRounding = 8.0
	 style.FrameRounding = 6.0
   
 
	   colors[clr.Text] = ImVec4(0.95, 0.96, 0.98, 1.00)
	   colors[clr.TextDisabled] = ImVec4(0.36, 0.42, 0.47, 1.00)
	   colors[clr.WindowBg] = ImVec4(0.11, 0.15, 0.17, 1.00)
	   colors[clr.ChildWindowBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	   colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94)
	   colors[clr.Border] = ImVec4(0.43, 0.43, 0.50, 0.50)
	   colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	   colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	   colors[clr.FrameBgHovered] = ImVec4(0.12, 0.20, 0.28, 1.00)
	   colors[clr.FrameBgActive] = ImVec4(0.09, 0.12, 0.14, 1.00)
	   colors[clr.TitleBg] = ImVec4(0.09, 0.12, 0.14, 0.65)
	   colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51)
	   colors[clr.TitleBgActive] = ImVec4(0.08, 0.10, 0.12, 1.00)
	   colors[clr.MenuBarBg] = ImVec4(0.15, 0.18, 0.22, 1.00)
	   colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.39)
	   colors[clr.ScrollbarGrab] = ImVec4(0.20, 0.25, 0.29, 1.00)
	   colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
	   colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
	   colors[clr.ComboBg] = ImVec4(0.20, 0.25, 0.29, 1.00)
	   colors[clr.CheckMark] = ImVec4(0.28, 0.56, 1.00, 1.00)
	   colors[clr.SliderGrab] = ImVec4(0.28, 0.56, 1.00, 1.00)
	   colors[clr.SliderGrabActive] = ImVec4(0.37, 0.61, 1.00, 1.00)
	   colors[clr.Button] = ImVec4(0.20, 0.25, 0.29, 1.00)
	   colors[clr.ButtonHovered] = ImVec4(0.28, 0.56, 1.00, 1.00)
	   colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	   colors[clr.Header] = ImVec4(0.20, 0.25, 0.29, 0.55)
	   colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	   colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	   colors[clr.ResizeGrip] = ImVec4(0.26, 0.59, 0.98, 0.25)
	   colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	   colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	   colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	   colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	   colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	   colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00)
	   colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	   colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	   colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	   colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	   colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
 end
 apply_custom_style()
