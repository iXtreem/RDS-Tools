require 'lib.moonloader'
local function recode(u8) return encoding.UTF8:decode(u8) end -- дешифровка при автоообновлении
------=================== Подгрузка библиотек ===================----------------------
local imgui 			= require 'imgui' 					-- Визуализация скрипта, окно программы
local sampev		 	= require 'lib.samp.events'			-- Считывание текста из чата
local imadd 			= require 'imgui_addons' 			-- Замена имгуи CheckBox'a
local mimgui 			= require 'mimgui'					-- Мимгуи для работы keysyns
local inicfg 			= require 'inicfg'					-- Сохранение/загрузка конфигов
local encoding 			= require 'encoding'				-- Дешифровка на русский язык
encoding.default 		= 'CP1251' 
local u8 				= encoding.UTF8
local vkeys 			= require 'vkeys' 					-- Работа с нажатием клавиш
local ffi 				= require "ffi"						-- Работа с открытым чатом
local fa 				= require 'faicons'					-- Иконки в imgui
local mem 				= require 'memory'					-- Работа с памятью игры
local font 				= require ('moonloader').font_flag	-- Шрифты визуальных текстов на экране


local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
local fa_glyph_ranges = imgui.ImGlyphRanges( {fa.min_range, fa.max_range} )
function imgui.BeforeDrawFrame()
    if not fontsize then  fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 17.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end -- 17 razmer
	if not fa_font then local font_config = imgui.ImFontConfig() font_config.MergeMode = true fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges) end 
end


function SendChat(text)
    local bs = raknetNewBitStream()
    local rn = require 'samp.raknet'
    raknetBitStreamWriteInt32(bs, #text)
    raknetBitStreamWriteString(bs, text)
    raknetSendRpc(rn.RPC.SERVERCOMMAND, bs)
    raknetDeleteBitStream(bs)
end


function imgui.Tooltip(text) -- подсказка при наведении на кнопку
    if imgui.IsItemHovered() then
       imgui.BeginTooltip() 
       imgui.Text(text)
       imgui.EndTooltip()
    end
end

function daysPassed(year1, month1, day1) -- узнаем разницу в днях
    local currentDate = os.date("*t")
    currentDate.year = year1
    currentDate.month = month1
    currentDate.day = day1
    local currentTimestamp = os.time(currentDate)
    local secondsPassed = os.difftime(os.time(), currentTimestamp)
    local daysPassed = math.floor(secondsPassed / (24 * 60 * 60))
    return daysPassed
end


function scanDirectory(path) -- Проверяем все файлы в папке
    files_chatlogs = {}
	local lfs = require("lfs")
    for file in lfs.dir(path) do
        if file ~= "." and file ~= ".." then
            local fullPath = path .. "/" .. file
            local attributes = lfs.attributes(fullPath)
            if attributes.mode == "directory" then
                local nestedFiles = scanDirectory(fullPath)
                for _, nestedFile in ipairs(nestedFiles) do table.insert(files_chatlogs, nestedFile) end
            else table.insert(files_chatlogs, file) end
        end
    end
    return files_chatlogs
end

function directory_exists(directory) return os.rename(directory,directory) end -- Проверка наличия папки

function string.rlower(s) -- перевод русских букв в прописные
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
		local russian_characters = {[168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я'}
        if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
        elseif ch == 168 then output = output .. russian_characters[184] -- буква ё
		else output = output .. string.char(ch) end
    end
    return output
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


function getBodyPartCoordinates(id, handle)
	local pedptr = getCharPointer(handle)
	local vec = ffi.new("float[3]")
	getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
	return vec[0], vec[1], vec[2]
end
function join_argb(a, r, g, b)
	local argb = b  -- b
	argb = bit.bor(argb, bit.lshift(g, 8))  -- g
	argb = bit.bor(argb, bit.lshift(r, 16)) -- r
	argb = bit.bor(argb, bit.lshift(a, 24)) -- a
	return argb
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
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
function sampGetPlayerIdByNickname(nick) -- узнать ID по нику
	nick = tostring(nick)
	local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if nick == sampGetPlayerNickname(myid) then return myid end
	for i = 0, 301 do if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then return i end end
end

function imgui.CenterText(text) -- центрирование текста
    imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(text).x / 2 ) 			
    imgui.Text(text)
end
function imgui.Link(label, description) -- гиперссылка
    local size = imgui.CalcTextSize(label)
	local p = imgui.GetCursorScreenPos()
	local p2 = imgui.GetCursorPos()
	local result = imgui.InvisibleButton(label, size)
    imgui.SetCursorPos(p2)
    if imgui.IsItemHovered() then
        if description then imgui.BeginTooltip() imgui.PushTextWrapPos(600) imgui.TextUnformatted(description) imgui.PopTextWrapPos() imgui.EndTooltip() end
        imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label)
        imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + size.y), imgui.ImVec2(p.x + size.x, p.y + size.y), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.CheckMark]))
	else imgui.TextColored(imgui.GetStyle().Colors[imgui.Col.CheckMark], label) end
    return result
end
-------================= Определяем нажатую клавишу, инициализируем её свойства ============------------------------
function getDownKeys()
    local curkeys, bool = "", false
    for k, v in pairs(vkeys) do if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then curkeys = v end end end
    for k, v in pairs(vkeys) do if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then if tostring(curkeys):len() == 0 then curkeys = v else curkeys = curkeys .. " " .. v end bool = true end end return curkeys, bool
end

function getDownKeysText()
	tKeys = textSplit(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then str = vkeys.id_to_name(tonumber(tKeys[i]))
			else str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i])) end
		end
		return str
	else return "None" end
end

function strToIdKeys(str)
	tKeys = textSplit(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then str = vkeys.name_to_id(tKeys[i], false)
			else str = str .. " " .. vkeys.name_to_id(tKeys[i], false) end
		end
		return tostring(str)
	else return "((" end
end

function isKeysDown(keylist, pressed)
    local tKeys = textSplit(keylist, " ")
    if pressed == nil then pressed = false end
    if tKeys[1] == nil then return false end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then bool = true
            elseif isKeyDown(key) and pressed then bool = true end
        end
    else if isKeyDown(modified) and not wasKeyReleased(modified) then if wasKeyPressed(key) and not pressed then bool = true elseif isKeyDown(key) and pressed then bool = true end end end
    if nextLockKey == keylist then if pressed and not wasKeyReleased(key) then bool = false else bool = false nextLockKey = "" end end
    return bool
end

function imgui.TextColoredRGB(text) -- цветной рендер админс
    local style = imgui.GetStyle()
    local colors = style.Colors
    local ImVec4 = imgui.ImVec4

    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end
    render_text(text)
end
function file_exists(name) -- проверяем существование файла
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
 end




function playersToStreamZone() -- игроки в радиусе
	local peds, streaming_player = getAllChars(), {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then streaming_player[key] = id end
	end
	return streaming_player
end

local transliterationTable = {
    ['й'] = 'q', ['ц'] = 'w', ['у'] = 'e', ['к'] = 'r', ['е'] = 't', ['н'] = 'y', ['г'] = 'u', ['ш'] = 'i', ['щ'] = 'o',
    ['з'] = 'p', ['х'] = '[', ['ъ'] = ']', ['ф'] = 'a', ['ы'] = 's', ['в'] = 'd', ['а'] = 'f', ['п'] = 'g', ['р'] = 'h',
    ['о'] = 'j', ['л'] = 'k', ['д'] = 'l', ['ж'] = ';', ['э'] = "'", ['я'] = 'z', ['ч'] = 'x', ['с'] = 'c', ['м'] = 'v',
    ['и'] = 'b', ['т'] = 'n', ['ь'] = 'm', ['б'] = ',', ['ю'] = '.', ['ё'] = '`',
    
    ['q'] = 'й', ['w'] = 'ц', ['e'] = 'у', ['r'] = 'к', ['t'] = 'е', ['y'] = 'н', ['u'] = 'г', ['i'] = 'ш', ['o'] = 'щ',
    ['p'] = 'з', ['['] = 'х', [']'] = 'ъ', ['a'] = 'ф', ['s'] = 'ы', ['d'] = 'в', ['f'] = 'а', ['g'] = 'п', ['h'] = 'р',
    ['j'] = 'о', ['k'] = 'л', ['l'] = 'д', [';'] = 'ж', ["'"] = 'э', ['z'] = 'я', ['x'] = 'ч', ['c'] = 'с', ['v'] = 'м',
    ['b'] = 'и', ['n'] = 'т', ['m'] = 'ь', [','] = 'б', ['.'] = '/', ['`'] = 'ё', ['/'] = '.',
}

function translateText(input)
    local output = ''
    for i = 1, string.len(input) do
		local translatedChar = nil
        local char = string.sub(input, i, i)
		for k,v in pairs(transliterationTable) do
        	if k == char then
				translatedChar = v
				break
			elseif v == chat then
				translatedChar = k
				break
			end
		end
        if translatedChar then output = output .. translatedChar
		else output = output .. char end
    end
    return output
end
function encrypt(text, shift)
	local encrypted = ""
	for i = 1, #text do
	  local char = text:sub(i, i)
	  if char >= "a" and char <= "z" then
		local ascii = string.byte(char)
		ascii = (ascii - 97 + shift) % 26 + 97
		char = string.char(ascii)
	  elseif char >= "A" and char <= "Z" then
		local ascii = string.byte(char)
		ascii = (ascii - 65 + shift) % 26 + 65
		char = string.char(ascii)
	  elseif char >= "а" and char <= "я" then
		local ascii = string.byte(char)
		ascii = (ascii - 224 + shift) % 32 + 224
		char = string.char(ascii)
	  elseif char >= "А" and char <= "Я" then
		local ascii = string.byte(char)
		ascii = (ascii - 192 + shift) % 32 + 192
		char = string.char(ascii)
	  end
	  encrypted = encrypted .. char
	end
	return encrypted
end
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
    if id == 0 then -- классическая
		colors[clr.Text]            	= ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled] 		= ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg] 			= ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg] 		= ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg] 			= ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border] 				= ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow] 		= ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg] 			= ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered] 		= ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive] 		= ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg] 			= ImVec4(0.09, 0.12, 0.14, 0.65)
		colors[clr.TitleBgCollapsed]	= ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.TitleBgActive] 		= ImVec4(0.08, 0.10, 0.12, 1.00)
		colors[clr.MenuBarBg] 			= ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg] 		= ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab] 		= ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered]= ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive] = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]				= ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark] 			= ImVec4(0.28, 0.56, 1.00, 1.00)
		colors[clr.SliderGrab] 			= ImVec4(0.28, 0.56, 1.00, 1.00)
		colors[clr.SliderGrabActive]	= ImVec4(0.37, 0.61, 1.00, 1.00)
		colors[clr.Button]		 		= ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ButtonHovered] 		= ImVec4(0.28, 0.56, 1.00, 1.00)
		colors[clr.ButtonActive] 		= ImVec4(0.06, 0.53, 0.98, 1.00)
		colors[clr.Header] 				= ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered] 		= ImVec4(0.26, 0.59, 0.98, 0.80)
		colors[clr.HeaderActive] 		= ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.ResizeGrip] 			= ImVec4(0.26, 0.59, 0.98, 0.25)
		colors[clr.ResizeGripHovered]	= ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.ResizeGripActive]	= ImVec4(0.06, 0.05, 0.07, 1.00)
		colors[clr.CloseButton] 		= ImVec4(0.40, 0.39, 0.38, 0.16)
		colors[clr.CloseButtonHovered] 	= ImVec4(0.40, 0.39, 0.38, 0.39)
		colors[clr.CloseButtonActive] 	= ImVec4(0.40, 0.39, 0.38, 1.00)
		colors[clr.PlotLines] 			= ImVec4(0.61, 0.61, 0.61, 1.00)
		colors[clr.PlotLinesHovered]	= ImVec4(1.00, 0.43, 0.35, 1.00)
		colors[clr.PlotHistogram] 		= ImVec4(0.90, 0.70, 0.00, 1.00)
		colors[clr.PlotHistogramHovered]= ImVec4(1.00, 0.60, 0.00, 1.00)
		colors[clr.TextSelectedBg] 		= ImVec4(0.25, 1.00, 0.00, 0.43)
		colors[clr.ModalWindowDarkening]= ImVec4(1.00, 0.98, 0.95, 0.73)
    elseif id == 1 then -- Красная
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]         = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.WindowBg] 			 = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.12, 0.20, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.53, 0.20, 0.16, 0.65)
		colors[clr.TitleBgActive]        = ImVec4(0.56, 0.14, 0.14, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.09, 0.21, 0.31, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark]            = ImVec4(1.00, 0.28, 0.28, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.64, 0.14, 0.14, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(1.00, 0.37, 0.37, 1.00)
		colors[clr.Button]               = ImVec4(0.59, 0.13, 0.13, 1.00)
		colors[clr.ButtonHovered]        = ImVec4(0.69, 0.15, 0.15, 1.00)
		colors[clr.ButtonActive]         = ImVec4(0.67, 0.13, 0.07, 1.00)
		colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered]        = ImVec4(0.98, 0.38, 0.26, 0.80)
		colors[clr.HeaderActive]         = ImVec4(0.98, 0.26, 0.26, 1.00)
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
	elseif id == 2 then -- синяя
		colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
		colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
		colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
		colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
		colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
		colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
		colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
		colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
		colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
		colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.Separator]              = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
		colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
		colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
		colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
		colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
		colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.WindowBg] 			   = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
		colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.ComboBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
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
    elseif id == 3 then -- фиолетовая
        colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]         = ImVec4(0.60, 0.60, 0.60, 1.00)
		colors[clr.WindowBg] 			 = ImVec4(0.11, 0.15, 0.17, 1.00)
        colors[clr.ChildWindowBg]        = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[clr.PopupBg]              = ImVec4(0.09, 0.09, 0.09, 1.00)
        colors[clr.Border]               = ImVec4(0.71, 0.71, 0.71, 0.40)
        colors[clr.BorderShadow]         = ImVec4(9.90, 9.99, 9.99, 0.00)
        colors[clr.FrameBg]              = ImVec4(0.34, 0.30, 0.34, 0.30)
        colors[clr.FrameBgHovered]       = ImVec4(0.22, 0.21, 0.21, 0.40)
        colors[clr.FrameBgActive]        = ImVec4(0.20, 0.20, 0.20, 0.44)
        colors[clr.TitleBg]              = ImVec4(0.52, 0.27, 0.77, 0.82)
        colors[clr.TitleBgActive]        = ImVec4(0.55, 0.28, 0.75, 0.87)
        colors[clr.TitleBgCollapsed]     = ImVec4(9.99, 9.99, 9.90, 0.20)
        colors[clr.MenuBarBg]            = ImVec4(0.27, 0.27, 0.29, 0.80)
        colors[clr.ScrollbarBg]          = ImVec4(0.08, 0.08, 0.08, 0.60)
        colors[clr.ScrollbarGrab]        = ImVec4(0.54, 0.20, 0.66, 0.30)
        colors[clr.ScrollbarGrabHovered] = ImVec4(0.21, 0.21, 0.21, 0.40)
        colors[clr.ScrollbarGrabActive]  = ImVec4(0.80, 0.50, 0.50, 0.40)
        colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]            = ImVec4(0.89, 0.89, 0.89, 0.50)
        colors[clr.SliderGrab]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.SliderGrabActive]     = ImVec4(0.80, 0.50, 0.50, 1.00)
        colors[clr.Button]               = ImVec4(0.48, 0.25, 0.60, 0.60)
        colors[clr.ButtonHovered]        = ImVec4(0.67, 0.40, 0.40, 1.00)
        colors[clr.ButtonActive]         = ImVec4(0.55, 0.28, 0.75, 1.00)
        colors[clr.Header]               = ImVec4(0.56, 0.27, 0.73, 0.44)
        colors[clr.HeaderHovered]        = ImVec4(0.78, 0.44, 0.89, 0.80)
        colors[clr.HeaderActive]         = ImVec4(0.81, 0.52, 0.87, 0.80)
        colors[clr.Separator]            = ImVec4(0.42, 0.42, 0.42, 1.00)
        colors[clr.SeparatorHovered]     = ImVec4(0.57, 0.24, 0.73, 1.00)
        colors[clr.SeparatorActive]      = ImVec4(0.69, 0.69, 0.89, 1.00)
        colors[clr.ResizeGrip]           = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.ResizeGripHovered]    = ImVec4(1.00, 1.00, 1.00, 0.60)
        colors[clr.ResizeGripActive]     = ImVec4(1.00, 1.00, 1.00, 0.89)
        colors[clr.CloseButton]          = ImVec4(0.33, 0.14, 0.46, 0.50)
        colors[clr.CloseButtonHovered]   = ImVec4(0.69, 0.69, 0.89, 0.60)
        colors[clr.CloseButtonActive]    = ImVec4(0.69, 0.69, 0.69, 1.00)
        colors[clr.PlotLines]            = ImVec4(1.00, 0.99, 0.99, 1.00)
        colors[clr.PlotLinesHovered]     = ImVec4(0.49, 0.00, 0.89, 1.00)
        colors[clr.PlotHistogram]        = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.PlotHistogramHovered] = ImVec4(9.99, 9.99, 9.90, 1.00)
        colors[clr.TextSelectedBg]       = ImVec4(0.54, 0.00, 1.00, 0.34)
        colors[clr.ModalWindowDarkening] = ImVec4(0.20, 0.20, 0.20, 0.34)
	elseif id == 4 then -- Розовая тема
		colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]         = ImVec4(0.36, 0.42, 0.47, 1.00)
		colors[clr.WindowBg] 			 = ImVec4(0.11, 0.15, 0.17, 1.00)
		colors[clr.ChildWindowBg]        = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
		colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
		colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
		colors[clr.FrameBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.FrameBgHovered]       = ImVec4(0.19, 0.12, 0.28, 1.00)
		colors[clr.FrameBgActive]        = ImVec4(0.09, 0.12, 0.14, 1.00)
		colors[clr.TitleBg]              = ImVec4(0.04, 0.04, 0.04, 1.00)
		colors[clr.TitleBgActive]        = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.51)
		colors[clr.MenuBarBg]            = ImVec4(0.15, 0.18, 0.22, 1.00)
		colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.39)
		colors[clr.ScrollbarGrab]        = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.ScrollbarGrabHovered] = ImVec4(0.18, 0.22, 0.25, 1.00)
		colors[clr.ScrollbarGrabActive]  = ImVec4(0.20, 0.09, 0.31, 1.00)
		colors[clr.ComboBg]              = ImVec4(0.20, 0.25, 0.29, 1.00)
		colors[clr.CheckMark]            = ImVec4(0.59, 0.28, 1.00, 1.00)
		colors[clr.SliderGrab]           = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.SliderGrabActive]     = ImVec4(0.41, 0.19, 0.63, 1.00)
		colors[clr.Button]               = ImVec4(0.41, 0.19, 0.63, 0.44)
		colors[clr.ButtonHovered]        = ImVec4(0.41, 0.19, 0.63, 0.86)
		colors[clr.ButtonActive]         = ImVec4(0.64, 0.33, 0.94, 1.00)
		colors[clr.Header]               = ImVec4(0.20, 0.25, 0.29, 0.55)
		colors[clr.HeaderHovered]        = ImVec4(0.51, 0.26, 0.98, 0.80)
		colors[clr.HeaderActive]         = ImVec4(0.53, 0.26, 0.98, 1.00)
		colors[clr.Separator]            = ImVec4(0.50, 0.50, 0.50, 1.00)
		colors[clr.SeparatorHovered]     = ImVec4(0.60, 0.60, 0.70, 1.00)
		colors[clr.SeparatorActive]      = ImVec4(0.70, 0.70, 0.90, 1.00)
		colors[clr.ResizeGrip]           = ImVec4(0.59, 0.26, 0.98, 0.25)
		colors[clr.ResizeGripHovered]    = ImVec4(0.61, 0.26, 0.98, 0.67)
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
    elseif id == 5 then -- голубая тема
		colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
		colors[clr.TextDisabled]           = ImVec4(0.28, 0.30, 0.35, 1.00)
		colors[clr.WindowBg] 			   = ImVec4(0.11, 0.15, 0.17, 1.00)
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