if file_exists('moonloader\\lib\\VK_API.lua') then vk = require 'VK_API'
else
	local dlstatus = require('moonloader').download_status
	downloadUrlToFile("https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/VK_API.lua", 'moonloader\\lib\\VK_API.lua', function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			reloadScripts()
		end
	end)
end


local token = --[[Токен группы VK]]"vk1.a.CeLIzK9OTcpIzmnlvUPNaBk-f8PVBBjBIKYMgOvci7RAq-hi9up1REVQC_T77bW71PpOdeijhTk3k4F1_-9XckYBiAMGiJzlLV3xCR0JI5_sWGi96om1qPLPFRyGFeWVILb1d7Jw8GLIHk_WhfwAydb9070C_vx2fNt0RygHMob7AGRhfHgQanNho6ox7tN-LZuSU7E93WH9scneUzbM1w"
local ID = "508415544"	-- ID VK кому отправлять
local message = "" -- сообщение отправленное VK
local ID_Group = '222702914' -- id группы
local scripts = { -- скрипты которые проверяем
	'AdminTools',
	'AT_MP',
    'AT_FastSpawn',
	'AdminToolsPlus',
}
function onSystemMessage(msg, type, script)
	for i = 1, #scripts do
        if msg:find(scripts[i]..'%.lua?:%d+:') then
            lua_thread.create(function()
                while sampIsDialogActive() do wait(200) end
                sampShowDialog(252, '{FFFFFF}Кажется, что-то пошло не так ...', 'В скрипте {7B68EE}' .. scripts[i] .. ' {ffffff}произошла ошибка, вследствии чего все скрипты будут перезагружены.\nКод ошибки:\n\n'..msg, 'reload', 'send report', 0)
                while sampIsDialogActive(252) do wait(500) end
                local _, button, _, _ = sampHasDialogRespond(252)
                if button == 1 then
                    sampShowDialog(252, "Желаете отправить отчет об ошибке?", ('Нет\nДа\nДа, со своими комментариями'), "Выбрать", nil, DIALOG_STYLE_LIST)
                    while sampIsDialogActive(252) do wait(500) end
                    local _, _, button, _ = sampHasDialogRespond(252)
                    if button~=0 then 
                        local add_text = 'Отсутствуют.'
                        if button == 2 then
                            sampShowDialog(252, 'Отчет','Расскажите, вследствии чего произошла данная ошибка', 'Отправить', nil, 1)
                            while sampIsDialogActive(252) do wait(500) end
                            local _, _, _, input = sampHasDialogRespond(252)
                            add_text = tostring(input)
                        end
                        local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
                        local nick = sampGetPlayerNickname(id)
                        local data = (os.date("*t").day..'.'.. os.date("*t").month..'.'..os.date("*t").year .. ' '..os.date("*t").hour..':'..os.date("*t").min ..':'..os.date("*t").sec)

                        if nick ~= 'N.E.O.N' and nick ~= 'chieftain' then -- разработчику незачем мучать себя уведомлениями
                            vk.botAuthorization(ID_Group, token, '5.199' --[[Версия API]])
                            vk.sendMessage('Произошла ошибка скрипта. Пожалуйста, ознакомьтесь с предоставленной информацией\n\nАдминистратор: ' .. sampGetPlayerNickname(id) .. '\n\nСкрипт, который дал сбой: ' ..scripts[i]..'.lua'.. '\n\nДата: ' ..data.. '\n\nЛог SAMPFUNCS:\n' .. textFormatter(msg)..'\n\nПримечание к ошибке: '..add_text, ID)
                        end
                        sampAddChatMessage('Отчет отправлен. Скрипты перезагружены.', -1)
                    end
                end
                wait(2000)
                reloadScripts()
            end)
        end
	end
end
function textFormatter(msg) -- форматируем текст чтобы нормально отправлялся вк
	local msg = tostring(msg)
	local msg = string.gsub(string.gsub(msg, '%[', '{'), '%]', '}') -- убираем спец.символы из-за которых не можем отправить сообщение вк
	local msg = string.gsub(msg, '#', '№')
	local msg = string.gsub(msg, '	', '')
	return msg
end