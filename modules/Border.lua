--[[
Name: Border
Author: MadsKrist
Description: Module for Prat that makes chat window borders square or removes them entirely.
Dependencies: Prat
]]
DEFAULT_CHAT_FRAME:AddMessage("DEBUG: Border.lua file is being loaded...", 1, 1, 0)

local L = AceLibrary("AceLocale-2.2"):new("PratSquareBorder")

L:RegisterTranslations("enUS", function() return {
    ["SquareBorder"] = true,
    ["Square border and background options for chat windows."] = true,
    ["Border Style"] = true,
    ["Choose the border style for chat windows."] = true,
    ["Background"] = true,
    ["Toggle background visibility."] = true,
    ["Background Color"] = true,
    ["Set the background color of chat windows."] = true,
    ["Background Alpha"] = true,
    ["Set the transparency of the background."] = true,
    ["Border Color"] = true,
    ["Set the border color of chat windows."] = true,
    ["Border Alpha"] = true,
    ["Set the transparency of the border."] = true,
    ["Toggle"] = true,
    ["Toggle the module on and off."] = true,
    
    -- Border style options
    ["None"] = true,
    ["Square"] = true,
    ["Thin Square"] = true,
    ["Default"] = true,
} end)

L:RegisterTranslations("ruRU", function() return {
    ["SquareBorder"] = "Квадратная граница",
    ["Square border and background options for chat windows."] = "Настройки квадратной границы и фона для окон чата.",
    ["Border Style"] = "Стиль границы",
    ["Choose the border style for chat windows."] = "Выберите стиль границы для окон чата.",
    ["Background"] = "Фон",
    ["Toggle background visibility."] = "Переключить видимость фона.",
    ["Background Color"] = "Цвет фона",
    ["Set the background color of chat windows."] = "Установить цвет фона окон чата.",
    ["Background Alpha"] = "Прозрачность фона",
    ["Set the transparency of the background."] = "Установить прозрачность фона.",
    ["Border Color"] = "Цвет границы",
    ["Set the border color of chat windows."] = "Установить цвет границы окон чата.",
    ["Border Alpha"] = "Прозрачность границы",
    ["Set the transparency of the border."] = "Установить прозрачность границы.",
    ["Toggle"] = "Вкл/Выкл",
    ["Toggle the module on and off."] = "Вкл/Выкл модуль.",
    
    ["None"] = "Нет",
    ["Square"] = "Квадратная",
    ["Thin Square"] = "Тонкая квадратная",
    ["Default"] = "По умолчанию",
} end)

L:RegisterTranslations("zhCN", function() return {
    ["SquareBorder"] = "方形边框",
    ["Square border and background options for chat windows."] = "聊天窗口方形边框和背景选项。",
    ["Border Style"] = "边框样式",
    ["Choose the border style for chat windows."] = "选择聊天窗口边框样式。",
    ["Background"] = "背景",
    ["Toggle background visibility."] = "切换背景可见性。",
    ["Background Color"] = "背景颜色",
    ["Set the background color of chat windows."] = "设置聊天窗口背景颜色。",
    ["Background Alpha"] = "背景透明度",
    ["Set the transparency of the background."] = "设置背景透明度。",
    ["Border Color"] = "边框颜色",
    ["Set the border color of chat windows."] = "设置聊天窗口边框颜色。",
    ["Border Alpha"] = "边框透明度",
    ["Set the transparency of the border."] = "设置边框透明度。",
    ["Toggle"] = "切换",
    ["Toggle the module on and off."] = "切换模块开关。",
    
    ["None"] = "无",
    ["Square"] = "方形",
    ["Thin Square"] = "细方形",
    ["Default"] = "默认",
} end)

Prat_SquareBorder = Prat:NewModule("squareborder")

function Prat_SquareBorder:OnInitialize()
    self.db = Prat:AcquireDBNamespace("SquareBorder")
    Prat:RegisterDefaults("SquareBorder", "profile", {
        on = false,
        borderstyle = "Square",
        showbackground = true,
        bgcolor = {r = 0, g = 0, b = 0},
        bgalpha = 0.5,
        bordercolor = {r = 1, g = 1, b = 1},
        borderalpha = 1.0,
    })
    
    -- Store original backdrops for restoration
    self.originalBackdrops = {}
    
    Prat.Options.args.squareborder = {
        name = L["SquareBorder"],
        desc = L["Square border and background options for chat windows."],
        type = "group",
        args = {
            borderstyle = {
                name = L["Border Style"],
                desc = L["Choose the border style for chat windows."],
                type = "text",
                order = 100,
                get = function() return self.db.profile.borderstyle end,
                set = function(v) 
                    self.db.profile.borderstyle = v 
                    self:ApplyStyling()
                end,
                validate = {
                    ["None"] = L["None"],
                    ["Square"] = L["Square"], 
                    ["Thin Square"] = L["Thin Square"],
                    ["Default"] = L["Default"]
                },
            },
            showbackground = {
                name = L["Background"],
                desc = L["Toggle background visibility."],
                type = "toggle",
                order = 110,
                get = function() return self.db.profile.showbackground end,
                set = function(v) 
                    self.db.profile.showbackground = v 
                    self:ApplyStyling()
                end,
            },
            bgcolor = {
                name = L["Background Color"],
                desc = L["Set the background color of chat windows."],
                type = "color",
                order = 120,
                disabled = function() return not self.db.profile.showbackground end,
                get = function() 
                    local c = self.db.profile.bgcolor
                    return c.r, c.g, c.b
                end,
                set = function(r, g, b)
                    self.db.profile.bgcolor = {r = r, g = g, b = b}
                    self:ApplyStyling()
                end,
            },
            bgalpha = {
                name = L["Background Alpha"],
                desc = L["Set the transparency of the background."],
                type = "range",
                order = 130,
                disabled = function() return not self.db.profile.showbackground end,
                min = 0,
                max = 1,
                step = 0.05,
                get = function() return self.db.profile.bgalpha end,
                set = function(v) 
                    self.db.profile.bgalpha = v 
                    self:ApplyStyling()
                end,
            },
            bordercolor = {
                name = L["Border Color"],
                desc = L["Set the border color of chat windows."],
                type = "color",
                order = 140,
                disabled = function() return self.db.profile.borderstyle == "None" end,
                get = function() 
                    local c = self.db.profile.bordercolor
                    return c.r, c.g, c.b
                end,
                set = function(r, g, b)
                    self.db.profile.bordercolor = {r = r, g = g, b = b}
                    self:ApplyStyling()
                end,
            },
            borderalpha = {
                name = L["Border Alpha"],
                desc = L["Set the transparency of the border."],
                type = "range",
                order = 150,
                disabled = function() return self.db.profile.borderstyle == "None" end,
                min = 0,
                max = 1,
                step = 0.05,
                get = function() return self.db.profile.borderalpha end,
                set = function(v) 
                    self.db.profile.borderalpha = v 
                    self:ApplyStyling()
                end,
            },
            toggle = {
                name = L["Toggle"],
                desc = L["Toggle the module on and off."],
                type = "toggle",
                order = 200,
                get = function() return self.db.profile.on end,
                set = function() 
                    self.db.profile.on = Prat:ToggleModuleActive("squareborder") 
                end
            }
        }
    }
end

function Prat_SquareBorder:OnEnable()
    -- Store original backdrops before making changes
    self:StoreOriginalBackdrops()
    
    -- Apply our styling
    self:ApplyStyling()
    
    -- Hook functions to maintain styling
    self:Hook("ChatFrame_OnUpdate")
end

function Prat_SquareBorder:OnDisable()
    -- Restore original backdrops
    self:RestoreOriginalBackdrops()
end

function Prat_SquareBorder:StoreOriginalBackdrops()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = getglobal("ChatFrame"..i)
        if frame then
            self.originalBackdrops[i] = frame:GetBackdrop()
        end
    end
end

function Prat_SquareBorder:RestoreOriginalBackdrops()
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = getglobal("ChatFrame"..i)
        if frame then
            local original = self.originalBackdrops[i]
            if original then
                frame:SetBackdrop(original)
            else
                frame:SetBackdrop(nil)
            end
        end
    end
end

function Prat_SquareBorder:GetBackdropConfig()
    local style = self.db.profile.borderstyle
    
    if style == "None" then
        if self.db.profile.showbackground then
            return {
                bgFile = "Interface\\Buttons\\WHITE8X8",
                edgeFile = nil,
                tile = false,
                tileSize = 0,
                edgeSize = 0,
                insets = {left = 0, right = 0, top = 0, bottom = 0}
            }
        else
            return nil -- No backdrop at all
        end
    elseif style == "Square" then
        return {
            bgFile = self.db.profile.showbackground and "Interface\\Buttons\\WHITE8X8" or nil,
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false,
            tileSize = 0,
            edgeSize = 2,
            insets = {left = 2, right = 2, top = 2, bottom = 2}
        }
    elseif style == "Thin Square" then
        return {
            bgFile = self.db.profile.showbackground and "Interface\\Buttons\\WHITE8X8" or nil,
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = false,
            tileSize = 0,
            edgeSize = 1,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        }
    else -- Default
        return {
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileSize = 32,
            edgeSize = 32,
            insets = {left = 11, right = 12, top = 12, bottom = 11}
        }
    end
end

function Prat_SquareBorder:ApplyStyling()
    local backdrop = self:GetBackdropConfig()
    local bgcolor = self.db.profile.bgcolor
    local bordercolor = self.db.profile.bordercolor
    
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = getglobal("ChatFrame"..i)
        if frame then
            self:StyleChatFrame(frame, backdrop, bgcolor, bordercolor)
        end
    end
end

function Prat_SquareBorder:StyleChatFrame(frame, backdrop, bgcolor, bordercolor)
    -- Set the backdrop
    frame:SetBackdrop(backdrop)
    
    -- Set colors if backdrop exists
    if backdrop then
        if backdrop.bgFile and self.db.profile.showbackground then
            frame:SetBackdropColor(bgcolor.r, bgcolor.g, bgcolor.b, self.db.profile.bgalpha)
        end
        
        if backdrop.edgeFile then
            frame:SetBackdropBorderColor(bordercolor.r, bordercolor.g, bordercolor.b, self.db.profile.borderalpha)
        end
    end
end

function Prat_SquareBorder:ChatFrame_OnUpdate(elapsed)
    -- Maintain our styling in case something else tries to change it
    if self.db.profile.on then
        self:ApplyStyling()
    end
end