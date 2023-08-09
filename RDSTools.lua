require 'lib.moonloader'
require 'lib.sampfuncs'
script_name('RDS Tools')
local imgui = require 'imgui' 
local imadd = require 'imgui_addons'
local sampev = require 'lib.samp.events'
local encoding = require 'encoding' 
local inicfg = require 'inicfg'
local directIni = 'RDSTools.ini'
encoding.default = 'CP1251' 
u8 = encoding.UTF8 
local key = require 'vkeys'
local rkeys = require "rkeys"
local fa = require 'faIcons'



require('samp.events').onShowDialog = function(dialogId, style, title, button1, button2, text)
    text = ('ID: %d | %s'):format(dialogId, text)
    return {dialogId, style, title, button1, button2, text}
end


local cfg = inicfg.load({
	settings = {
		automute = false,
		check_weapon_hack = false,
		helloadmin = false,
		autoskip = false,
		autoopra = false,
		chatlog = false,
		FLD = false,
		autoalogin = false,
		autooskrod = false,
		autoaz = false,
		prfrandom = false,
		form = true,
		autoalogin = false,
		autoal = false,
		autoonline = false,
		clickwarp = false,
		parolalogin = nil,
		inputhelper = false,
		spisok = 1
	},
	script = {
		version = 0.2
	}
}, directIni)
inicfg.save(cfg,directIni)

local version = 0.2-- ВЕРСИЯ СКРИПТА


local checked_test = imgui.ImBool(cfg.settings.check_weapon_hack)
local checked_test2 = imgui.ImBool(false)
local checked_test3 = imgui.ImBool(false)
local checked_test4 = imgui.ImBool(false)
local checked_test5 = imgui.ImBool(false)
local checked_test6 = imgui.ImBool(false)
local checked_test7 = imgui.ImBool(false)
local checked_test8 = imgui.ImBool(false)
local checked_test9 = imgui.ImBool(false)
local checked_test10 = imgui.ImBool(cfg.settings.autoalogin)
local checked_test11 = imgui.ImBool(false)
local checked_test12 = imgui.ImBool(cfg.settings.form)
local checked_test13 = imgui.ImBool(false)
local checked_test14 = imgui.ImBool(false)
local combo_select = imgui.ImInt(cfg.settings.spisok)
local sw, sh = getScreenResolution()
local text_buffer = imgui.ImBuffer(256)
local main_window_state = imgui.ImBool(false)
local secondary_window_state = imgui.ImBool(false)

local text_buffer_age = imgui.ImBuffer(256)
local text_buffer_name = imgui.ImBuffer(256)




local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
imgui.GetIO().Fonts:Clear() 
imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\FRAMDIT.ttf', 17, nil, glyph_ranges)
main_color_text = 0xFFFFFF

function main()
	while not isSampAvailable() do wait(0) end

	update_state = false
	local dlstatus = require('moonloader').download_status

	local update_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.ini" -- Ссылка на конфиг
	local update_path = getWorkingDirectory() .. "/RDSTools.ini" -- и тут свою ссылку

	local script_url = "https://raw.githubusercontent.com/iXtreem/RDS-Tools/main/RDSTools.lua" -- Ссылка на сам файл
	local script_path = thisScript().path

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            RDSTools = inicfg.load(nil, update_path)
            if tonumber(RDSTools.script.version) > version then
                update_state = true
			else
				sampAddChatMessage('Скрипт {FF0000}RDS Tools ' .. '{C0C0C0}[' .. version .. ']' ..  ' {FFFFFF}загружен, активация: {808080}F3', -1)
			end
            os.remove(update_path)
        end
    end)
	while true do
        wait(0)
        if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampShowDialog(1000, "xX RDS Tools Xx", '{FFFFFF}Была найдена новая версия - ' .. RDSTools.script.version .. '\n{FFFFFF}Скрипт был успешно обновлен.', "Спасибо", "", 0)
                    thisScript():reload()
                end
            end)
            break
        end
		if isKeyJustPressed(VK_F3) and not sampIsDialogActive() then 
			main_window_state.v = not main_window_state.v
			imgui.Process = main_window_state.v
		end
		if isKeyJustPressed(VK_F2) then 
			secondary_window_state.v = not secondary_window_state.v
			imgui.Process = secondary_window_state.v
		end
	end
	imgui.Process = false
end






--------- Неактив кнопка

function imgui.ButtonClickable(clickable, ...)
    if clickable then
        return imgui.Button(...)
    else
        local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
        imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
        imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
        imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
        imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
            imgui.Button(...)
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
        imgui.PopStyleColor()
    end
end
--------- Неактив кнопка




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



function imgui.OnDrawFrame()
	if not main_window_state.v and not secondary_window_state.v then
		imgui.Process = false
	end
	if main_window_state.v then -- КНОПКИ ИНТЕРФЕЙСА F3
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin('xX   ' .. " RDS Tools " .. '  Xx', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.ShowBorders)
		imgui.NewInputText('##SearchBar', text_buffer_name, 255, u8'Введите сюда ваш пароль от админки', 2)
		imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
		imgui.SameLine()
	-- END В КОНЦЕЕЕЕЕ
	if imgui.Button(u8'Сохранить ') then
		sampAddChatMessage(u8'Успешно сохранено.', main_color_text)
		parolalogin = text_buffer_name
	end
		imgui.Separator()
	if imgui.Checkbox(u8"Weapon Hack +", checked_test) then
		cfg.settings.check_weapon_hack = not cfg.settings.check_weapon_hack
		inicfg.save(cfg,directIni)
	end
		imgui.SameLine()
		imgui.SetCursorPosX(225)
	if imgui.ButtonClickable(nick == 'N.E.O.N', u8"Приветствие администраторов") then
		cfg.settings.helloadmin = not cfg.settings.helloadmin
		inicfg.save(cfg,directIni)
	end
	if imgui.Checkbox(u8"AutoMute", checked_test4) then
		automute = not automute
	end
		imgui.SameLine()
		imgui.SetCursorPosX(225)
	if imgui.Checkbox(u8"Автоматический скип диалогов", checked_test3) then
		autoskip = not autoskip
	end
	if imgui.Checkbox(u8"Автоматическая опра", checked_test5) then
		autoopra = not autoopra
	end
		imgui.SameLine()
		imgui.SetCursorPosX(225)
	if imgui.Checkbox(u8"chatlog", checked_test6) then
		chatlog = not chatlog
	end
	if imgui.Checkbox(u8"Flood Detector", checked_test7) then
		FLD = not FLD
	end
	imgui.SameLine()
	imgui.SetCursorPosX(225)
	if imgui.Checkbox(u8"Autoal", checked_test8) then
		wait(0)
	end
	if imgui.Checkbox(u8"Автомут оск род", checked_test9) then
		autooskrod = not autooskrod
	end
	imgui.SameLine()
	imgui.SetCursorPosX(225)
	if imgui.Checkbox(u8"Просьба войти в /alogin +", checked_test10) then
		cfg.settings.autoalogin = not cfg.settings.autoalogin
		inicfg.save(cfg,directIni)
	end
	if imgui.Checkbox(u8"Cпавн в /az", checked_test11) then
		autoaz = not autoaz
	end
	imgui.SameLine()
	imgui.SetCursorPosX(225)
	if imgui.Checkbox(u8"Слежка за формами", checked_test12) then
		cfg.settings.form = not cfg.settings.form
		inicfg.save(cfg,directIni)
	end
	if imgui.Checkbox(u8"input helper", checked_test13) then
		cfg.settings.inputhelper = not cfg.settings.inputhelper
		inicfg.save(cfg,directIni)
	end
	imgui.SameLine()
	imgui.SetCursorPosX(225)
	if imgui.Checkbox(u8"Авто-выдача за онлайн", checked_test14) then
		autoonline = not autoonline
	end
	imgui.Separator()
	if imgui.Combo(u8" ", combo_select, u8"Серая тема\0Фиолетовая тема\0Синий\0Dark-Red\0Dark-Blue\0Ультра-темное\0") then
		if combo_select.v == 0 then -- Серая тема
			cfg.settings.spisok = combo_select.v
        	inicfg.save(cfg, directIni)
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
		end
		if combo_select.v == 1 then -- Фиолетовая тема
			cfg.settings.spisok = combo_select.v
        	inicfg.save(cfg, directIni)
				function apply_custom_style()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					style.WindowRounding = 2
					style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
					style.ChildWindowRounding = 2.0
					style.FrameRounding = 3
					style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
					style.ScrollbarSize = 13.0
					style.ScrollbarRounding = 0
					style.GrabMinSize = 8.0
					style.GrabRounding = 1.0
					style.WindowPadding = imgui.ImVec2(4.0, 4.0)
					style.FramePadding = imgui.ImVec2(3.5, 3.5)
					style.ButtonTextAlign = imgui.ImVec2(0.0, 0.5)
					colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
					colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
					colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
					colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
					colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
					colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
					colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
					colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
					colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
					colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
					colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
					colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
					colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
					colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
					colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
					colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
					colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
					colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
					colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
					colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
					colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
					colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
					colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
					colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
					colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
					colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
					colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
					colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
					colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
					colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
					colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
					colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
			end
			apply_custom_style()
		end
		if combo_select.v == 2 then -- Синий
			cfg.settings.spisok = combo_select.v
      		inicfg.save(cfg, directIni)
				function apply_custom_style()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
					colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00);
					colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00);
					colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94);
					colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
					colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50);
					colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00);
					colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54);
					colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40);
					colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67);
					colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
					colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53);
					colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00);
					colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00);
					colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00);
					colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00);
					colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00);
					colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00);
					colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40);
					colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00);
					colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00);
					colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31);
					colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80);
					colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00);
					colors[clr.Separator]              = colors[clr.Border];
					colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.40, 0.75, 0.78);
					colors[clr.SeparatorActive]        = ImVec4(0.10, 0.40, 0.75, 1.00);
					colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25);
					colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67);
					colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95);
					colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
					colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
					colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
					colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
					colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35);
			
					imgui.SetColorEditOptions(imgui.ColorEditFlags.HEX)
			
					style.FrameRounding = 0.0
					style.WindowRounding = 0.0
					style.ChildWindowRounding = 0.0
			
					colors[clr.TitleBgActive] = ImVec4(0.000, 0.009, 0.120, 0.940);
					colors[clr.TitleBg] = ImVec4(0.20, 0.25, 0.30, 1.0);
					colors[clr.Button] = ImVec4(0.260, 0.590, 0.980, 0.670);
					colors[clr.Header] = ImVec4(0.260, 0.590, 0.980, 0.670);
					colors[clr.HeaderHovered] = ImVec4(0.260, 0.590, 0.980, 1.000);
					colors[clr.ButtonHovered] = ImVec4(0.000, 0.545, 1.000, 1.000);
					colors[clr.ButtonActive] = ImVec4(0.060, 0.416, 0.980, 1.000);
					colors[clr.FrameBg] = ImVec4(0.20, 0.25, 0.30, 1.0);
					colors[clr.WindowBg] = ImVec4(0.000, 0.009, 0.120, 0.940);
					colors[clr.PopupBg] = ImVec4(0.076, 0.143, 0.209, 1.000);
			end
			apply_custom_style()
		end
		if combo_select.v == 3 then -- Dark-Red
			cfg.settings.spisok = combo_select.v
       		inicfg.save(cfg, directIni)
				function theme()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
				
					style.WindowPadding = imgui.ImVec2(8, 8)
					style.WindowRounding = 6
					style.ChildWindowRounding = 5
					style.FramePadding = imgui.ImVec2(5, 3)
					style.FrameRounding = 3.0
					style.ItemSpacing = imgui.ImVec2(5, 4)
					style.ItemInnerSpacing = imgui.ImVec2(4, 4)
					style.IndentSpacing = 21
					style.ScrollbarSize = 10.0
					style.ScrollbarRounding = 13
					style.GrabMinSize = 8
					style.GrabRounding = 1
					style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
					style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
				
					colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
					colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
					colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
					colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
					colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
					colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
					colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
					colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
					colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
					colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
					colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
					colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
					colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
					colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
					colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
					colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
					colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
					colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
					colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
					colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
					colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
					colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
					colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
					colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
					colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
					colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
					colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
					colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
					colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
					colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
					colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
					colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
					colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
			end
			theme()
		end
		if combo_select.v == 4 then -- Dark-Blue
			cfg.settings.spisok = combo_select.v
       		inicfg.save(cfg, directIni)
				function style() -- стиль имгуи
					imgui.SwitchContext()
					local style  = imgui.GetStyle()
					local colors = style.Colors
					local clr    = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
				
					style.WindowPadding       = ImVec2(10, 10)
					style.WindowRounding      = 10
					style.ChildWindowRounding = 2
					style.FramePadding        = ImVec2(5, 4)
					style.FrameRounding       = 11
					style.ItemSpacing         = ImVec2(4, 4)
					style.TouchExtraPadding   = ImVec2(0, 0)
					style.IndentSpacing       = 21
					style.ScrollbarSize       = 16
					style.ScrollbarRounding   = 16
					style.GrabMinSize         = 11
					style.GrabRounding        = 16
					style.WindowTitleAlign    = ImVec2(0.5, 0.5)
					style.ButtonTextAlign     = ImVec2(0.5, 0.5)
				
					colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
					colors[clr.TextDisabled]         = ImVec4(0.73, 0.75, 0.74, 1.00)
					colors[clr.WindowBg]             = ImVec4(0.09, 0.09, 0.09, 0.94)
					colors[clr.ChildWindowBg]        = ImVec4(10.00, 10.00, 10.00, 0.01)
					colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
					colors[clr.Border]               = ImVec4(0.20, 0.20, 0.20, 0.50)
					colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
					colors[clr.FrameBg]              = ImVec4(0.00, 0.39, 1.00, 0.65)
					colors[clr.FrameBgHovered]       = ImVec4(0.11, 0.40, 0.69, 1.00)
					colors[clr.FrameBgActive]        = ImVec4(0.11, 0.40, 0.69, 1.00)
					colors[clr.TitleBg]              = ImVec4(0.00, 0.00, 0.00, 1.00)
					colors[clr.TitleBgActive]        = ImVec4(0.00, 0.24, 0.54, 1.00)
					colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.22, 1.00, 0.67)
					colors[clr.MenuBarBg]            = ImVec4(0.08, 0.44, 1.00, 1.00)
					colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
					colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
					colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
					colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
					colors[clr.ComboBg]              = ImVec4(0.20, 0.20, 0.20, 0.99)
					colors[clr.CheckMark]            = ImVec4(1.00, 1.00, 1.00, 1.00)
					colors[clr.SliderGrab]           = ImVec4(0.34, 0.67, 1.00, 1.00)
					colors[clr.SliderGrabActive]     = ImVec4(0.84, 0.66, 0.66, 1.00)
					colors[clr.Button]               = ImVec4(0.00, 0.39, 1.00, 0.65)
					colors[clr.ButtonHovered]        = ImVec4(0.00, 0.64, 1.00, 0.65)
					colors[clr.ButtonActive]         = ImVec4(0.00, 0.53, 1.00, 0.50)
					colors[clr.Header]               = ImVec4(0.00, 0.62, 1.00, 0.54)
					colors[clr.HeaderHovered]        = ImVec4(0.00, 0.36, 1.00, 0.65)
					colors[clr.HeaderActive]         = ImVec4(0.00, 0.53, 1.00, 0.00)
					colors[clr.Separator]            = ImVec4(0.43, 0.43, 0.50, 0.50)
					colors[clr.SeparatorHovered]     = ImVec4(0.71, 0.39, 0.39, 0.54)
					colors[clr.SeparatorActive]      = ImVec4(0.71, 0.39, 0.39, 0.54)
					colors[clr.ResizeGrip]           = ImVec4(0.71, 0.39, 0.39, 0.54)
					colors[clr.ResizeGripHovered]    = ImVec4(0.84, 0.66, 0.66, 0.66)
					colors[clr.ResizeGripActive]     = ImVec4(0.84, 0.66, 0.66, 0.66)
					colors[clr.CloseButton]          = ImVec4(0.41, 0.41, 0.41, 1.00)
					colors[clr.CloseButtonHovered]   = ImVec4(0.98, 0.39, 0.36, 1.00)
					colors[clr.CloseButtonActive]    = ImVec4(0.98, 0.39, 0.36, 1.00)
					colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
					colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
					colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
					colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
					colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
					colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35)
			end
			style()
		end
		if combo_select.v == 5 then -- Ультра-темное
			cfg.settings.spisok = combo_select.v
       		inicfg.save(cfg, directIni)
				function theme()
					imgui.SwitchContext()
					local style = imgui.GetStyle()
					local colors = style.Colors
					local clr = imgui.Col
					local ImVec4 = imgui.ImVec4
					local ImVec2 = imgui.ImVec2
					
					style.WindowRounding = 3
					style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
					style.ChildWindowRounding = 3
					style.FrameRounding = 3
					style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
					style.ScrollbarSize = 13.0
					style.ScrollbarRounding = 1
					style.GrabMinSize = 8.0
					style.GrabRounding = 3
					style.WindowPadding = imgui.ImVec2(4.0, 4.0)
					style.FramePadding = imgui.ImVec2(2.5, 3.5)
					style.ButtonTextAlign = imgui.ImVec2(0.02, 0.4)   
				
					colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
					colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
					colors[clr.WindowBg]               = imgui.ImColor(0, 0, 0, 255):GetVec4()
					colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
					colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
					colors[clr.ComboBg]                = colors[clr.PopupBg]
					colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
					colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
					colors[clr.FrameBg]                = ImVec4(0.12, 0.12, 0.12, 0.94)
					colors[clr.FrameBgHovered]         = ImVec4(0.45, 0.45, 0.45, 0.85)
					colors[clr.FrameBgActive]          = ImVec4(0.63, 0.63, 0.63, 0.63)
					colors[clr.TitleBg]                = ImVec4(0.13, 0.13, 0.13, 0.99)
					colors[clr.TitleBgActive]          = ImVec4(0.13, 0.13, 0.13, 0.99)
					colors[clr.TitleBgCollapsed]       = ImVec4(0.05, 0.05, 0.05, 0.79)
					colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
					colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
					colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
					colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
					colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
					colors[clr.CheckMark]              = ImVec4(1.00, 1.00, 1.00, 1.00)
					colors[clr.SliderGrab]             = ImVec4(0.28, 0.28, 0.28, 1.00)
					colors[clr.SliderGrabActive]       = ImVec4(0.35, 0.35, 0.35, 1.00)
					colors[clr.Button]                 = ImVec4(0.12, 0.12, 0.12, 0.94)
					colors[clr.ButtonHovered]          = ImVec4(0.34, 0.34, 0.35, 0.89)
					colors[clr.ButtonActive]           = ImVec4(0.21, 0.21, 0.21, 0.81)
					colors[clr.Header]                 = ImVec4(0.12, 0.12, 0.12, 0.94)
					colors[clr.HeaderHovered]          = ImVec4(0.34, 0.34, 0.35, 0.89)
					colors[clr.HeaderActive]           = ImVec4(0.12, 0.12, 0.12, 0.94)
					colors[clr.Separator]              = colors[clr.Border]
					colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
					colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
					colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
					colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
					colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
					colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
					colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
					colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
					colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
					colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
					colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
					colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
					colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
					colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
			end
			theme()
		end
	end
	imgui.SameLine()
	if imgui.Button(u8'Выгрузить скрипт') then
		sampAddChatMessage('Выгружаю...', 0xFFFFFF)
		thisScript():unload()
	end
	imgui.End()
	end
	if secondary_window_state.v then -- второе окно на F2
		imgui.SetNextWindowSize(imgui.ImVec2(30, 500), imgui.Cond.FirstUseEver)
		imgui.Begin(u8"Вашего аккаунта нет в базе данных скрипта.", secondary_window_state)
		imgui.Text(u8"Удалиь скрипт можно в директории игры moonloader//RDS-Tools.lua")
		imgui.End()
	end
end
