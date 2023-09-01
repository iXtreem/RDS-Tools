require 'lib.moonloader'
script_name 'Bot'
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- ���������� ��� ���������������
local version = 0.1
local imgui = require 'imgui' 
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local directIni = 'Bot.ini'
local encoding = require 'encoding' 
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local cfg = inicfg.load({ -- ������� ��������� �������
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
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- ������ �� ������
	local update_path = getWorkingDirectory() .. "/Bot.ini" -- � ��� �� �� ����� ������
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- ������ �� ��� ����
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            Bot = inicfg.load(nil, update_path)
            if tonumber(Bot.script.version) > version then
                update_state = true
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}������� ����������, ��������� ����� �������� {808080}/update', -1)
			end
            os.remove(update_path)
        end
    end)
	if update_state then
		downloadUrlToFile(script_url, script_path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}������ ������� ��������.')
				showCursor(false,false)
				thisScript():reload()
			end
		end)
	else
		sampAddChatMessage('{FF0000}RDS Tools: {FFFFFF}� ��� ����������� ���������� ������.')
	end
end