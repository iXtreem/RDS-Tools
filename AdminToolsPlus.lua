require 'lib.moonloader'
script_name 'AT Plus+' 
script_author 'Neon4ik'
script_properties("work-in-pause") 
local imgui = require 'imgui' 
local version = 1.1
local key = require 'vkeys'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local imadd = require 'imgui_addons'
local sampev = require 'lib.samp.events'
local dektor_window_state = imgui.ImBool(false)
local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)
local tag = '{2F4F4F}AdminTools Plus+: {FF7F50}'
local sw, sh = getScreenResolution()
local inicfg = require 'inicfg'
local offadmins = {}
local cfg = inicfg.load({
    settings = {
		delete_point = true,
		auto_al = false,
		auto_hello = false,
		hello_text = '������������, _, ����� ��� ��������� ����������������� :3',
		warning_report = false,
		count_warning = 3,
		mytext_warning_report = '��������� ��������������, ������ �������� ������!!!',
		number_report = 3
    },
	listNoResult = {
		'N.E.O.N',
		'LONDON',
		'Coder',
		'Kintzel.'
	},
}, 'AT//ATPlus.ini')
inicfg.save(cfg, 'AT//ATPlus.ini')

local buffer = {
	PrefixMa = imgui.ImBuffer(cfg.settings.prefixma, 256),
	PrefixA = imgui.ImBuffer(cfg.settings.prefixa, 256),
	PrefixSa = imgui.ImBuffer(cfg.settings.prefixsa, 256),
	text_buffer = imgui.ImBuffer(16384),
	text_buffer2 = imgui.ImBuffer(1024),
	text_buffer3 = imgui.ImBuffer(1024),
	delete_admin = imgui.ImBuffer(1024),
	hello_admin = imgui.ImBuffer(u8(cfg.settings.hello_text),1024),
	mytext = imgui.ImBuffer(u8(cfg.settings.mytext_warning_report),1024)
}
local checkbox = {
	delete_point = imgui.ImBool(cfg.settings.delete_point),
	auto_hello = imgui.ImBool(cfg.settings.auto_hello),
	auto_al = imgui.ImBool(cfg.settings.auto_al),
	warning_report = imgui.ImBool(cfg.settings.warning_report),
}
local style_selected2 = imgui.ImInt(cfg.settings.count_warning-1)
local style_selected = imgui.ImInt(cfg.settings.number_report-2)
local selected_item = imgui.ImInt(2)
local selected_item2 = imgui.ImInt(0)
local check_admin = imgui.ImInt(6) -- 7 ����
local makeadmin = {}
local kai = {}
local kick_admin = {} -- ��� �������� /offadmins
local kick_admin2 = {} -- ��������� � ���������
local newlvl = 1
local SendKai = -1
local offadmins = {}
local topadm = {}


function main()
	while not isSampAvailable() do wait(0) end
	local dlstatus = require('moonloader').download_status
    downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminToolsPlus.ini", getWorkingDirectory() .. "//AdminToolsPlus.ini", function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			AdminToolsPlus = inicfg.load(nil, getWorkingDirectory() .. "//AdminToolsPlus.ini")
			if tonumber(AdminToolsPlus.script.version) > version then
				update_state = true
			end
			os.remove(getWorkingDirectory() .. "//AdminToolsPlus.ini")
		end
    end)
	if update_state then
		downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/AdminToolsPlus.lua", thisScript().path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage(tag .. '�������� ������ ������� ��������.', -1)
				imgui.Process = false
				showCursor(false,false)
				sampAddChatMessage(tag .. '������ ��������.', -1)
				thisScript():reload()
			end
		end)
	end
	sampAddChatMessage(tag .. '������ ���������������. ���������: /atp', -1)
	while true do
		wait(100)
		if isPauseMenuActive() or isGamePaused() then AFK = true
		elseif AFK and not (isPauseMenuActive() or isGamePaused()) then AFK = false end
	end
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
		if imgui.Checkbox(u8'����-����������� /al', checkbox.auto_al) then
			cfg.settings.auto_al = not cfg.settings.auto_al
			save()
		end
		if imgui.Checkbox(u8'����������� ���������������', checkbox.auto_hello) then
			cfg.settings.auto_hello = not cfg.settings.auto_hello
			save()
		end
		if cfg.settings.auto_hello then
			if imgui.InputText('##autohello', buffer.hello_admin) then
				cfg.settings.hello_text = u8:decode(buffer.hello_admin.v)
				save()
			end
			imgui.TextWrapped(u8'��� �������������� ������������ �������� _')
		end
		if imgui.Checkbox(u8'����������� � ������� � /a', checkbox.warning_report) then
			cfg.settings.warning_report = not cfg.settings.warning_report
			save()
		end
		if cfg.settings.warning_report then
			imgui.Text(u8'���-�� �������� ���������: ')
			imgui.SameLine()
			imgui.PushItemWidth(50)
			if imgui.Combo("##selected2", style_selected2, {'1', '2', '3', '4', '5'}, style_selected2) then
				cfg.settings.count_warning = style_selected2.v + 1
				save()
			end
			imgui.PopItemWidth()
			imgui.Text(u8'������� (���-�� ��������): ')
			imgui.SameLine()
			imgui.PushItemWidth(50)
			if imgui.Combo("##selected", style_selected, {'2' ,'3', '4', '5', '6'}, style_selected) then
				cfg.settings.number_report = style_selected.v + 2
				save()
			end
			imgui.PopItemWidth()
			if imgui.InputText('##mytext', buffer.mytext) then
				cfg.settings.mytext_warning_report = u8:decode(buffer.mytext.v)
				save()
			end
		end
		if imgui.Button(u8'�������� ����� ������', imgui.ImVec2(230,24)) then
			main_window_state.v = not main_window_state.v
			dektor_window_state.v = not dektor_window_state.v
		end
		imgui.End()
	end
	if main_window_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2((sw * 0.3), sh * 0.3), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"�������������� ���������� ������.", main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		if imadd.ToggleButton('##antipoint', checkbox.delete_point) then
			cfg.settings.delete_point = not cfg.settings.delete_point
			save()
		end
		imgui.SameLine()
		imgui.Text(u8'������� ����� � ������ �����')
		imgui.InputTextMultiline("##", buffer.text_buffer, imgui.ImVec2(250, 300))
		if #topadm == 0 and #offadmins == 0 then
			if imgui.Button(u8'������� ���������� � ���������������', imgui.ImVec2(250,24)) then
				lua_thread.create(function()
					buffer.text_buffer.v = u8'�� ��������� ������� ������� ��������\n��� �������� ����� �� �������� ���������� ����������'
					sampSendChat('/topadm')
					while not sampIsDialogActive(2232) do wait(100) end
					while sampIsDialogActive(2232) do sampCloseCurrentDialogWithButton(0) wait(100) end
					sampSendChat('/offadmins')
					secondary_window_state.v = true
					buffer.text_buffer.v = ''
				end)
			end
		end
		if imgui.Button(u8'������� �������� ������', imgui.ImVec2(250, 25)) then
			if #offadmins ~= 0 and #topadm ~= 0 then
				secondary_window_state.v = not secondary_window_state.v
			else sampAddChatMessage(tag .. '�� ��� �� �������� �� ������� ���������������.', -1)
			end
		end
		imgui.Text(u8'����� ����������� ���� ����������.')
		if imgui.Button(u8'�������������� � ����.', imgui.ImVec2(250, 25)) then
			buffer.text_buffer.v = ''
			for k, v in pairs(kai) do
				buffer.text_buffer.v = buffer.text_buffer.v .. u8(v) .. '\n'
			end
			kai = {} -- �������� ���������
		end
		if imgui.Button(u8'���������� ����� ������', imgui.ImVec2(250, 25)) then
			buffer.text_buffer.v = ''
			for k, v in pairs(makeadmin) do
				v = string.gsub(v, '  ', ' ') -- ������� ������ ������� ���� ��� �������.
				buffer.text_buffer.v = buffer.text_buffer.v .. v .. '\n'
			end
		end
		if buffer.text_buffer.v:find('/makeadmin') then
			if imgui.Button(u8'������ ������.', imgui.ImVec2(250, 25)) then
				printStyledString('process ...', #(textSplit(buffer.text_buffer.v, '\n')) * 3000, 7)
				lua_thread.create(function()
					for k, v in pairs(textSplit(buffer.text_buffer.v, '\n')) do
						v = string.gsub(v, '  ', ' ') -- ������� ������ ������� ���� ��� �������.
						sampSendChat(v)
						wait(3000)
						while sampIsDialogActive() do
							wait(0)
						end
					end
				end)
				makeadmin = {} -- �������� ���������
			end
		end
        imgui.End()
    end
	if secondary_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw * 0.5, sh * 0.5), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8"���������", secondary_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.ShowBorders)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
		imgui.Text(u8'��:              ��:')
		imgui.PushItemWidth(50)
		imgui.InputText('##1', buffer.text_buffer2)
		imgui.PopItemWidth()
		imgui.SameLine()
		imgui.SetCursorPosX(75)
		imgui.PushItemWidth(50)
		imgui.InputText('##2', buffer.text_buffer3)
		imgui.PopItemWidth()
		if imgui.Button(u8'���������', imgui.ImVec2(115, 25)) then
			if (newlvl == 0 and SendKai ~= 0) or (SendKai == 0 and newlvl ~= 0) then
				sampAddChatMessage(tag .. '�� �� ������ ��������� ������ �� �����������, �� ���� ��� � �����, � ����������.', -1)
			elseif buffer.text_buffer2.v and buffer.text_buffer3.v then -- �������� ������ �� ���������� ������
				if #buffer.text_buffer.v == 0 then -- ���� � �������� ���� ������ ��� - ������� ��� ����
					buffer.text_buffer.v = u8'@all ����� ������\n����� �����: AdminTools by N.E.O.N\n� ������������ � ������������ ������\n�������� ���������� �������.\n\n' 
				end
				if tonumber(buffer.text_buffer2.v) <  tonumber(buffer.text_buffer3.v)  then
					buffer.text_buffer.v = buffer.text_buffer.v .. '---------------------------------------------\n'
					if newlvl == 0 then
						buffer.text_buffer.v = (buffer.text_buffer.v .. '[' .. buffer.text_buffer2.v  .. ' - '.. buffer.text_buffer3.v .. u8' ������] = ����� � �����\n')
					elseif newlvl == 'Skip' then
						buffer.text_buffer.v = (buffer.text_buffer.v .. '[' .. buffer.text_buffer2.v  .. ' - '.. buffer.text_buffer3.v .. u8' ������] = ' .. SendKai .. u8' ����(�)' .. '\n')
					else
						buffer.text_buffer.v = (buffer.text_buffer.v .. '[' .. buffer.text_buffer2.v  .. ' - '.. buffer.text_buffer3.v .. u8' ������] = +' .. newlvl .. u8' LVL � ' .. SendKai .. u8' ����(�)' .. '\n')
					end
					buffer.text_buffer.v = buffer.text_buffer.v .. '---------------------------------------------\n'
					for _,k in pairs(topadm) do
						nick = string.gsub(string.sub(k, 1, -4), '%s%s', '')-- LONDON = 100
						peremball = tonumber(string.match(string.sub(nick, -5), '%d[%d.,]*'))
						nick = string.gsub(nick, '= (%d+)', '')
						if (tonumber(buffer.text_buffer2.v) <= peremball) and (peremball <= tonumber(buffer.text_buffer3.v)) then
							for k,v in pairs(offadmins) do
								
								peremlvl = tonumber(string.match(string.sub(v,-3), '%d[%d.,]*'))
								v = string.gsub(v, '=(%d+)', '')
								nick = string.gsub(nick, '=(%d+)', '')
								if string.sub(nick,1,-2) == ' ' then
									nick = string.sub(nick,1,-2)
								end
								v = string.gsub(v, '= (%d+)', '')
								nickv = string.gsub(v,'=(.+)', '')
								for h,m in pairs(cfg.listNoResult) do -- ���� ������������� ���� � ������ ���������� - ������� ���
									if nickv:match(m) then
										k,v = nil, nil
									end
								end
								
								if v then
									if v:find(nick) or v:find(string.sub(nick,1,-2)) then -- ���������� � ������ ���������� � ���
										for d,s in pairs(kai) do -- ������ �� ���������� �������� ������, ������� ����������
											if s:find(nick) then
												kai[d], kai[s] = nil, nil
											end
										end
										for d,s in pairs(makeadmin) do -- ������ �� ���������� �������� ������, ������� ����������
											if s:find(nick) then
												makeadmin[d], makeadmin[s] = nil, nil
											end
										end
										nick = string.gsub(nick, ' ', '') -- ������� ������ �����
										local nick_kai = nick -- ���� �������� ���� ��� ���
										if cfg.settings.delete_point then
											nick_1 = string.sub(nick, 1,1) -- ������ ������ ������ ����
											nick_2 = string.sub(nick,-1) -- ������ ��������� ������ ����
											nick_kai = string.gsub(string.sub(string.sub(nick, 2), 1, -2), '%.', '') -- ������� ����� � ������ ����.
											nick_kai = (nick_1 .. nick_kai .. nick_2) -- ����������� ����� ��������
										end
										if SendKai == 0 then
											kai[#kai + 1] = '��� ��� ' .. nick_kai
											kick_admin2[#kick_admin2 + 1] = nick
										elseif SendKai == 1 then
											kai[#kai + 1] = '��� ���� ' .. nick_kai
										elseif SendKai == 2 then
											kai[#kai + 1] = '��� ���� 2 ' .. nick_kai
										elseif SendKai == -1 then
											kai[#kai + 1] = '��� ����� ���� ' .. nick_kai
										elseif SendKai == -2 then
											kai[#kai + 1] = '��� ����� ���� 2 ' .. nick_kai
										end
										if tonumber(peremlvl) ~= 18 then -- ���������� ���������� � /makeadmin � ������� ����
											
											if newlvl ~= 'Skip' then
												if tonumber(newlvl) + tonumber(peremlvl) > 18 then
													newnewlvl = tonumber(newlvl) - 1
													if tonumber(newnewlvl) + tonumber(peremlvl) > 18 then
														newnewlvl = tonumber(newnewlvl) - 1
														makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newnewlvl))
														buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' ������\n'
													end
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newnewlvl))
													buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' ������\n'
												else
													makeadmin[#makeadmin + 1] = '/makeadmin ' .. nick .. ' ' .. (tonumber(peremlvl) + tonumber(newlvl))
													buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' ������\n'
												end
											else
												buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' ������\n'
											end
										else
											buffer.text_buffer.v = buffer.text_buffer.v .. nick .. ' [' .. peremlvl .. '] ' .. peremball .. u8' ������\n'
										end
									end
								end
							end
						end
					end
					if tonumber(buffer.text_buffer2.v) == 0 then -- ���� 0 ������ (�.� �������������� ������ ��� � /topadm) �� ������ �� �� ��������
						for k,v in pairs(offadmins) do
							v = string.gsub(string.gsub(v,'=(.+)', ''), '%s', '')
							for d,s in pairs(topadm) do 
								s = string.gsub(string.gsub(s, '= (.+)', ''), '%s', '')
								if v:match(s) then 
									a = true 
								end 
							end 
							for s,m in pairs(cfg.listNoResult) do 
								if v == m then 
									a = true  
								end
							end
							if a then 
								a = nil 
							else
								local nick_kai = v
								if cfg.settings.delete_point then 
									nick_1 = string.sub(v, 1, 1) 
									nick_2 = string.sub(v,-1) 
									nick_kai = string.gsub(string.sub(string.sub(v, 2), 1, -2), '%.', '') 
									nick_kai = (nick_1 .. nick_kai .. nick_2) 
								end 
								if SendKai == 0 then 
									kai[#kai + 1] = '��� ��� ' .. nick_kai 
									makeadmin[#makeadmin + 1] = ('/makeadmin ' .. v .. ' 0') 
									kick_admin2[#kick_admin2 + 1] = v
								end
								buffer.text_buffer.v = buffer.text_buffer.v .. v .. u8' 0 ������' .. '\n'
							end  
						end 
					end
					buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, '  ', ' ') -- ������� ������ ������� ����� ������ ���� ��� �������
				else
					sampAddChatMessage(tag .. '�� �� ������� ���������� ������', -1)
				end
			else
				sampAddChatMessage(tag .. '������ ������� �����������.', -1)
			end
		end
		imgui.Text(u8'�������.')
		imgui.PushItemWidth(115)
		if imgui.Combo('##newlvl', selected_item, {u8'�����', u8'��������', u8'+1 �������', u8'+2 ������', u8'+3 ������'}, 5) then
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
		imgui.Text(u8'���.')
		imgui.PushItemWidth(115)
		if imgui.Combo('##newpred', selected_item2, {u8'����� 1 ����', u8'����� 2 �����', u8'�������', u8'������ 1 ����', u8'������ 2 �����', u8'������'}, 6) then
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
		imgui.PushItemWidth(50)
		imgui.Text(u8'���.')
		imgui.Combo('##option_days', check_admin, {'1', '2', '3', '4', '5', '6', '7'}, 7)
		if imgui.IsItemHovered() then
			imgui.BeginTooltip() -- ��������� ��� ��������� �� ������
			imgui.Text(u8'���� �������� ������ ������� ���-�� ���� (������������) - ������ �� ������.\n�������� ��, ��� ������ �������, � ������ �� �������.')
			imgui.EndTooltip()
		end
		imgui.PopItemWidth()
		imgui.Text(u8'�������� ����: /newadm')
		imgui.Text(u8'������� ����: /deladm')
		if imgui.Button(u8'������� ����������') then
			for i = 2, #cfg.listNoResult do
				sampAddChatMessage(cfg.listNoResult[i],-1)
			end
		end
		if imgui.Button(u8'������� ����� �������') then
			if #kick_admin2 ~= 0 then
				lua_thread.create(function()
					sampAddChatMessage(tag .. '�������� �������� �� ��������� ���������������', -1)
					sampAddChatMessage(tag .. '�� ���������� �������!', -1)
					kick_admin = {}
					for _,text in pairs(textSplit(u8:decode(buffer.text_buffer.v), '\n')) do
						if text:find('(.+) %[(%d+)%] (%d+) ������') then
							local nick, _, _ = text:match('(.+) %[(.+)%] (.+) ������')
							while sampIsDialogActive() do sampCloseCurrentDialogWithButton(0) end
							sampSendChat('/ap')
							sampSendDialogResponse(1034, 1, 1)
							sampSendDialogResponse(6020, 1, 1, nick)
							while not sampIsDialogActive(0) do wait(0) end
							while sampIsDialogActive(0) do wait(0) end
						end
					end
					for i = 1, #kick_admin do
						for b = 1, #kick_admin2 do
							if kick_admin[i] == kick_admin2[b] then
								buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' %[(%d+)%] (%d+) ������'), u8'')
								buffer.text_buffer.v = string.gsub(buffer.text_buffer.v, u8('\n'..kick_admin[i] .. ' 0 ������'), u8'')
								for k,v in pairs(makeadmin) do
									if v:find(kick_admin[i]) then
										table.remove(makeadmin, k)
										sampAddChatMessage('������������� ' .. v .. ', �������� �� ���� ������, ��� ' .. check_admin.v+1 .. ' ���� �����, ��� ������ �� �������', -1)
									end
								end
								for k,v in pairs(kai) do
									if v:find(kick_admin[i]) then
										table.remove(kai, k)
									end
								end
							end
						end
					end
					secondary_window_state.v = false
					main_window_state.v = true
				end)
			else sampAddChatMessage('�� ������ �� ������� � �����', -1) end
		end
		imgui.End()
	end
end
function sampev.onServerMessage(color,text)
	if cfg.settings.auto_hello and text:match("%[A%] ������������� (.+)%[(%d+)%] %(%d+ level%) ������������� � ����� ������") and not AFK then
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local autorizate_admin = text:match('%[(%d+)%]')
		sampAddChatMessage(text, -1) 
		if autorizate_admin ~= myid then
			lua_thread.create(function()
				while sampIsDialogActive() or sampIsChatInputActive() do wait(0) end
				sampSendChat('/a ' .. string.gsub(cfg.settings.hello_text, '_', sampGetPlayerNickname(autorizate_admin)))
			end)
		end
		return true
	end --[A] Andy.(85) �� ������������� ��� ������������� ��� 1 �����(�)
	if cfg.settings.auto_al and not AFK and text:match('%[A%] (.+)%((%d+)%) �� ������������� ��� ������������� ���') then --[A] Dirty_DeSanta(76) �� ������������� ��� ������������� ��� 1 �����(�)
		local _, autorizate_admin = text:match('(.+)%((%d+)%)')
		sampAddChatMessage(text,-1)
		lua_thread.create(function()
			while sampIsDialogActive() do wait(0) end
			sampSendChat('/ans ' .. autorizate_admin .. ' ������������! �� ������ ������ /alogin!')
			wait(500)
			sampSendChat('/ans ' .. autorizate_admin .. ' ������� ������� /alogin � ���� ������, ����������.')
		end)
	end
	if cfg.settings.warning_report and not AFK and text:match('������ #(%d) | ') then
		local number_report = tonumber(text:match('������ #(%d) | '))
		if number_report >= cfg.settings.number_report then
			sampAddChatMessage('{FF0000}[AT]{FFFFFF} ' .. text, -1)
			lua_thread.create(function()
				for i = 0, cfg.settings.count_warning do
					if not sampIsChatInputActive() then
						sampSendChat('/a ' .. cfg.settings.mytext_warning_report)
						wait(2000)
					end
				end
			end)
		end
	end
end
function daysPassed(year1, month1, day1) -- ������ ������� � ����
    local currentDate = os.date("*t")
    currentDate.year = year1
    currentDate.month = month1
    currentDate.day = day1
    local currentTimestamp = os.time(currentDate)
    local secondsPassed = os.difftime(os.time(), currentTimestamp)
    local daysPassed = math.floor(secondsPassed / (24 * 60 * 60))
    return daysPassed
end
function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if button1 == '{f76663}X' and imgui.Process then	-- ���� /offadmins - �������������
		lua_thread.create(function()
			local text = textSplit(text, '\n')
			if text[27] then -- ������ �� ������
				--{FFFFFF}���� ������:				{63BD4E}[2023-10-02 23:09:30]. {FFFFFF}
				local year, month, day = text[27]:match('{63BD4E}%[(%d+)%-(%d+)%-(%d+) (%d%d):(%d%d):(%d%d)%]')
				local days = daysPassed(year, month, day)
				if days < check_admin.v + 1 then
					kick_admin[#kick_admin+1] = title
				end
				wait(100)
				sampCloseCurrentDialogWithButton(0)
			end
		end)
	end
	if dialogId == 4829 and imgui.Process then
		local text = textSplit(text, '\n')
		for k,v in pairs(text) do
			local v = string.sub(v, 9)
			if v:match('�������') then v = string.sub(v, 1, -16) end -- ������������ ��� �������
			if v:match('������') then v = string.sub(v, 1, -15) end -- ������������ ��� �������
			if #v > 0 and v ~= '���	{ffffff}������� ��������������	' and v~='<<< �����' and v ~= '����� >>>' then
				local v = string.sub(v, 1, -2)
				local lvl1 = string.sub(v, -2) -- ��������� ������ �������� ������
				if string.sub(v, -2) == '1' then -- ���� ������������� ���� 10 ������ - �������� ���������
					v = string.sub(v, 1, -2)
					lvl2 = string.sub(v, -2)
				end
				if lvl2 then lvl = lvl1 .. lvl2 -- ����������, ������ ���
				else lvl = lvl1 end
				local v = string.sub(v, 1, -3) 
				for d,s in pairs(offadmins) do -- ������ �� ���������� �������� ������, ������� ����������
					if s == (v .. '=' .. lvl) then
						offadmins[d], offadmins[s] = nil, nil
					end
				end
				offadmins[#offadmins + 1] =  (v .. '=' .. lvl) -- ���������� ���������� � ������ � ������
				local lvl, lvl1, lvl2 = nil, nil, nil
			end
			if text[#text-1]:match('����� >>>') then sampSendDialogResponse(4829, 1, #text-3)
			else sampCloseCurrentDialogWithButton(0) end
		end
	end 
	if dialogId == 2232 and imgui.Process then
		topadm = {} -- ������� ������
		local text = textSplit(text, '\n')
		for k,v in pairs(text) do
			if #v > 0 and v ~= '{ffffff}���	{ffffff}������� ��������������	{ffffff}������' then
				local v = string.sub(v, 10)
				if string.sub(v, -1) == '0' or string.sub(v, -1) == '1' or string.sub(v, -1) == '2' or string.sub(v, -1) == '3' or string.sub(v, -1) == '4' or string.sub(v, -1) == '5' or string.sub(v, -1) == '6' or string.sub(v, -1) == '7' or string.sub(v, -1) == '8' or string.sub(v, -1) == '9' then
					v = string.sub(v,2) -- ������� ���������� � LVL��, ��� ����� � ��� ���� /offadmins
				end
				local v = string.sub(v, 2)
				if string.sub(v, 1, 1) == ' ' then -- ������� ������ ������
					v = string.sub(v, 2)
				end
				local ballov = string.match(v, '%S+$') -- ������ ���-�� ������
				if ballov then
					v = string.sub(v, 1, -#ballov) -- ������� �� �������� ���-�� ������
				end
				v = string.sub(v, 1, -5)
				topadm[#topadm + 1] = (v .. ' = ' .. ballov) -- ���������� ���� � ������������
			end
		end
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
function save()
	inicfg.save(cfg, 'AT//ATPlus.ini')	
end
sampRegisterChatCommand('deladm', function(param)
	if #param >= 3 then
		for k, v in pairs(cfg.listNoResult) do
			if cfg.listNoResult[k] == param then
				cfg.listNoResult[k] = nil
				save()
				sampAddChatMessage(tag .. '��������� ���� ������������� ' .. param .. ' ��� ������� ������� �� ������', -1)
				a = true
				break
			else    
				a = false
			end
		end
		if not a then
			sampAddChatMessage(tag .. '������ �������������� � ������ ���.', -1)
			a = nil
		end
	end
end)
sampRegisterChatCommand('newadm', function(param)
	if #param >= 3 then
		for k, v in pairs(cfg.listNoResult) do
			if cfg.listNoResult[k] == param then
				sampAddChatMessage(tag .. '��������� ���� ������������� - ' .. param .. ' ��� ������� � ������.' , -1)
				a = true
				break
			else    
				a = false
			end
		end
		if not a then
			cfg.listNoResult[#cfg.listNoResult + 1] = param
			save()
			sampAddChatMessage(tag .. '��������� ���� ������������� - ' .. param .. ' ��� ������� �������� � ����������', -1)
			a = nil
		end
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
