require 'lib.moonloader'
script_name 'Bot'
script_author 'Neon4ik'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
local version = 0.2
local font = require ("moonloader").font_flag
local imgui = require 'imgui' 
local sp = require("lib.samp.events")
local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local directIni = 'Bot.ini' -- 1207 камень 422 бобкат 19133 пикап загрузки выгрузки
local encoding = require 'encoding' 
local min = math.huge
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local cfg = inicfg.load({ -- базовые настройки скрипта
	settings = {
	}
}, directIni)
inicfg.save(cfg,directIni)
local sw, sh = getScreenResolution()
local tag = ('{FF0000}Bot: {FFFFFF}')
function runToPoint(tox, toy) -- для беспалевного метода
    local x, y, z = getCharCoordinates(PLAYER_PED)
    local angle = getHeadingFromVector2d(tox - x, toy - y)
    local xAngle = math.random(-50, 50)/100
    setCameraPositionUnfixed(xAngle, math.rad(angle - 90))
    stopRun = false
    while getDistanceBetweenCoords2d(x, y, tox, toy) > 0.8 do
        setGameKeyState(1, -255)
        --setGameKeyState(16, 1)
        wait(1)
        x, y, z = getCharCoordinates(PLAYER_PED)
        angle = getHeadingFromVector2d(tox - x, toy - y)
        setCameraPositionUnfixed(xAngle, math.rad(angle - 90))
        if stopRun then
            stopRun = false
            break
        end
    end
end
local contin = false
local access = false
local bat = false
local liftup = false
local kamen = {}
local i = 0
local summa = 0
function main()
	while not isSampAvailable() do wait(0) end
	font_watermark = renderCreateFont("Javanese Text", 12, font.BOLD + font.SHADOW)
	lua_thread.create(function()
		while true do
			wait(0) 
			if start then
				renderFontDrawText(font_watermark, "Заработано: " .. summa, (sw/2)-100, sh-20, 0xCCFFFFFF)
			end
		end	
	end)
	update_state = false
	local dlstatus = require('moonloader').download_status
	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/Bot.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "/Bot.ini" -- и тут ту же самую ссылку
	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/Bot.lua" -- Ссылка на сам файл
	local script_path = thisScript().path
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            Bot = inicfg.load(nil, update_path)
            if tonumber(Bot.script.version) > version then
                update_state = true
				sampAddChatMessage(tag .. 'Найдено обновление, загружаю {808080}автоматически', -1)
			end
            os.remove(update_path)
        end
    end)
	if update_state then
		downloadUrlToFile(script_url, script_path, function(id, status)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				sampAddChatMessage('{FF0000}Bot: {FFFFFF}Скрипт успешно обновлен.')
				showCursor(false,false)
				thisScript():reload()
			end
		end)
	else
		sampAddChatMessage('{FF0000}Bot: {FFFFFF}Скрипт успешно загружен. Активация: {808080}/start', -1)
	end
	sampRegisterChatCommand('start', function() 
		if posx then
			if true then
				start = true
				sampAddChatMessage(tag .. 'Запускаю фарм, чтобы остановить скрипт введи /off')
				lua_thread.create(function()
					while start do
						wait(0)
						local count = 0
						for k, v in pairs(getAllObjects()) do
							local model = getObjectModel(v)
							if model==1207 then
								local _, x, y, z = getObjectCoordinates(v)
								if model == 1207 then
									kamen[#kamen+1] = (x .. ' ' .. y .. ' ' .. z)
								end
							end
						end
						if #kamen < 14 then
							for k,v in pairs(kamen) do kamen[k]=nil end
							setCharCoordinates(PLAYER_PED, 738.69006347656, 802.7900390625, -18.747402191162)
							wait(3000)
							setCharCoordinates(PLAYER_PED, 746.00622558594, 830.30078125, -18.750720977783)
							wait(3000)
							setCharCoordinates(PLAYER_PED, 723.34716796875, 779.34173583984, -18.741315841675)
							wait(3000)
							setCharCoordinates(PLAYER_PED, posx, posy, posz)
							sampAddChatMessage(tag .. 'Ожидаю взрыва бомб.', -1)
							wait(28000)
							sampAddChatMessage(tag .. 'Продолжаю работу...', -1)
							for k, v in pairs(getAllObjects()) do
								local model = getObjectModel(v)
								if model==1207 then
									local _, x, y, z = getObjectCoordinates(v)
									if model == 1207 then
										kamen[#kamen+1] = (x .. ' ' .. y .. ' ' .. z)
									end
								end
							end
						end
						table.sort(kamen, _)
						for k, v in pairs(kamen) do
							x, y, z = v:match('(.+) (.+) (.+)')
							setCharCoordinates(PLAYER_PED, x, y, z)
							wait(400)
							while not liftup do
								wait(0)
							end
							liftup = false
							setCharCoordinates(PLAYER_PED, posx, posy, posz)
							wait(400)
							while not contin do
								wait(0)
							end
							contin = false
							if count ~= 14 then
								wait(0)
								count = count + 1
								summa = summa + 200
							else
								wait(500)
								while not isCharInAnyCar(PLAYER_PED) do
									setVirtualKeyDown(13, true)
									wait(100)
									setVirtualKeyDown(13, false)
									wait(300)
								end
								wait(2000)
								while isCharInAnyCar(PLAYER_PED) do
									wait(300)
									setVirtualKeyDown(13, true)
									wait(100)
									setVirtualKeyDown(13, false)
								end
								wait(1000)
								while count ~= 29 do
									wait(500)
									setCharCoordinates(PLAYER_PED, posx, posy, posz)
									wait(400)
									while not access do
										wait(0)
									end
									access = false
									setCharCoordinates(PLAYER_PED, 681.78479003906, 823.99017333984, -26.83091545105)
									wait(400)
									while not contin do
										wait(0)
									end
									contin = false
									count = count + 1
									summa = summa + 200
								end
								wait(1000)
								setCharCoordinates(PLAYER_PED, posx, posy, posz)
								wait(1000)
								while not isCharInAnyCar(PLAYER_PED) do
									wait(300)
									setVirtualKeyDown(13, true)
									wait(100)
									setVirtualKeyDown(13, false)
								end
								wait(3000)
								while isCharInAnyCar(PLAYER_PED) do
									setVirtualKeyDown(13, true)
									wait(100)
									setVirtualKeyDown(13, false)
									wait(300)
								end
								wait(1000)
								setCharCoordinates(PLAYER_PED, posx, posy, posz)
								wait(2000)
								count = 0
								for k,v in pairs(kamen) do kamen[k]=nil end
								break
							end
						end
					end
				end)
			end
		else
			sampAddChatMessage(tag .. 'Вы не сохранили позицию пикапа /savepos', -1)
		end
	end)
	sampRegisterChatCommand('savepos', function() 
		if start then
			start = false
			posx, posy, posz = false
			sampAddChatMessage(tag .. 'Скрипт выключен. Заработано за сеанс: ' .. summa, -1)
		else
			start = true
			sampAddChatMessage(tag .. 'Позиция загрузки сохранена.', -1)
			posx, posy, posz = getCharCoordinates(PLAYER_PED)
		end
	end)
	sampRegisterChatCommand('off', function()
		thisScript():reload()
	end)
	sampRegisterChatCommand('save', function()
		posx, posy, posz = getCharCoordinates(PLAYER_PED)
		sampAddChatMessage(posx .. ' ' .. posy .. ' ' .. posz, -1)
	end)
	sampRegisterChatCommand('tpb', function()
		setCharCoordinates(PLAYER_PED, 1494.5980224609, 1308.1614990234, 1093.2878417969)
	end)
end
function sampev.onDisplayGameText(style, time, text)
	if text:find(' ') and posx then
		klicker()
	end
end
function klicker()
	lua_thread.create(function()
		while i ~= 10 do
			wait(0)
			while not bat do
				wait(0)
				setVirtualKeyDown(VK_MENU, true)
				wait(50)
				setVirtualKeyDown(VK_MENU, false)
				wait(2000)
			end
			i = i + 1
			bat = false
		end
		posx2, posy2, posz2 = getCharCoordinates(PLAYER_PED)
		setCharCoordinates(PLAYER_PED, 681.78479003906, 823.99017333984, -26.83091545105)
		wait(1500)
		setCharCoordinates(PLAYER_PED, posx2, posy2, posz2)
	end)
end
function sp.onApplyPlayerAnimation(playerId, animLib, animName, frameDelta, loop, lockX, lockY, freeze, time)
    local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if playerId == myId then -- Если анимация наша
		sampAddChatMessage(animName, -1)
        if animName == 'putdwn105' then -- Если анимация - Анимация стадии смерти
            contin = true
        end
		if animName == 'liftup105' then
			access = true
		end
		if animName == 'liftup' then
			liftup = true
		end
		if animName == 'bat_4' then
			bat = true
		end
    end
end