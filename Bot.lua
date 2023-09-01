require 'lib.moonloader'
script_name 'Bot'
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local version = 0.1
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local directIni = 'Bot.ini'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local cfg = inicfg.load({ -- базовые настройки скрипта
	settings = {
		kjb=iuih
	},
	script = {
		version = 1.3
	},
}, directIni)
inicfg.save(cfg,directIni)
function main()
	while not isSampAvailable() do wait(0) end
	update_state = false
	local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "/Bot.ini" -- и тут ту же самую ссылку
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- Ссылка на сам файл
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            Bot = inicfg.load(nil, update_path)
            if tonumber(Bot.script.version) > version then
                update_state = true
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Найдено обновление, загрузить можно командой {808080}/update', -1)
			end
            os.remove(update_path)
        end
    end)
	if update_state then
		downloadUrlToFile(script_url, script_path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}Скрипт успешно обновлен.')
				showCursor(false,false)
				thisScript():reload()
			end
		end)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}У вас установлена актуальная версия.')
	end
end