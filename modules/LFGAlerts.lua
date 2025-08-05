--[[
Name: LFG
Author: MadsKrist
Description: Module for Prat that alerts when messages in LFG chat window match specified filters.
Dependencies: Prat
]]

DEFAULT_CHAT_FRAME:AddMessage("DEBUG: LFGAlerts.lua file is being loaded...", 1, 1, 0)

local L = AceLibrary("AceLocale-2.2"):new("PratLFGAlerts")

L:RegisterTranslations("enUS", function() return {
    ["LFGAlerts"] = true,
    ["LFG chat monitoring and alert options."] = true,
    ["Require LFM"] = true,
    ["Only alert on messages containing 'LFM'."] = true,
    ["Raid Filters"] = true,
    ["Select which raids to monitor for."] = true,
    ["AQ40"] = true,
    ["BWL"] = true,
    ["NAXX"] = true,
    ["KARA 10"] = true,
    ["KARA 40"] = true,
    ["MC"] = true,
    ["ES"] = true,
    ["ONY"] = true,
    ["Alert Type"] = true,
    ["Choose how to be alerted when a match is found."] = true,
    ["Sound Alert"] = true,
    ["Play a sound when filter matches."] = true,
    ["Sound File"] = true,
    ["Choose which sound to play."] = true,
    ["Screen Flash"] = true,
    ["Flash the screen when filter matches."] = true,
    ["Chat Alert"] = true,
    ["Show alert message in default chat."] = true,
    ["Popup Alert"] = true,
    ["Show popup window with the matching message."] = true,
    ["Case Sensitive"] = true,
    ["Make filter matching case sensitive."] = true,
    ["Whole Words Only"] = true,
    ["Only match complete words, not partial matches."] = true,
    ["Test Message"] = true,
    ["Enter a message to test against your filters."] = true,
    ["Run Test"] = true,
    ["Test the message against current filters."] = true,
    ["Toggle"] = true,
    ["Toggle the module on and off."] = true,
    
    -- Alert messages
    ["LFG Alert: %s"] = true,
    ["Filter matched in LFG: %s"] = true,
    ["No LFG chat window found! Make sure you have a chat window named 'LFG'."] = true,
    ["Test Result: %s"] = true,
    ["MATCH"] = true,
    ["NO MATCH"] = true,
    
    -- Sound options
    ["Tell"] = true,
    ["Whisper"] = true,
    ["Guild"] = true,
    ["Auction"] = true,
    ["Level Up"] = true,
    ["Custom"] = true,
} end)

L:RegisterTranslations("ruRU", function() return {
    ["LFGAlerts"] = "LFG Оповещения",
    ["LFG chat monitoring and alert options."] = "Мониторинг LFG чата и настройки оповещений.",
    ["Filters"] = "Фильтры",
    ["Manage your LFG alert filters."] = "Управление фильтрами оповещений LFG.",
    ["Add Filter"] = "Добавить фильтр",
    ["Add a new filter keyword or phrase."] = "Добавить новое ключевое слово или фразу.",
    ["Remove Filter"] = "Удалить фильтр",
    ["Remove a filter from the list."] = "Удалить фильтр из списка.",
    ["Filter List"] = "Список фильтров",
    ["Current active filters (one per line)."] = "Текущие активные фильтры (по одному на строку).",
    ["Alert Type"] = "Тип оповещения",
    ["Choose how to be alerted when a match is found."] = "Выберите как получать оповещения при совпадении.",
    ["Sound Alert"] = "Звуковое оповещение",
    ["Play a sound when filter matches."] = "Воспроизводить звук при совпадении фильтра.",
    ["Screen Flash"] = "Мигание экрана",
    ["Flash the screen when filter matches."] = "Мигание экрана при совпадении фильтра.",
    ["Chat Alert"] = "Оповещение в чат",
    ["Show alert message in default chat."] = "Показывать сообщение в основном чате.",
    ["Case Sensitive"] = "Учитывать регистр",
    ["Make filter matching case sensitive."] = "Учитывать регистр при поиске совпадений.",
    ["Toggle"] = "Вкл/Выкл",
    ["Toggle the module on and off."] = "Вкл/Выкл модуль.",
} end)

Prat_LFGAlerts = Prat:NewModule("LFGAlerts")


function Prat_LFGAlerts:OnInitialize()
    self.db = Prat:AcquireDBNamespace("LFGAlerts")
    Prat:RegisterDefaults("LFGAlerts", "profile", {
        on = false,
        requirelfm = true,
        raids = {
            aq40 = true,
            bwl = true,
            naxx = true,
            kara10 = true,
            kara40 = true,
            mc = true,
            es = true,
            ony = true,
        },
        soundalert = true,
        soundfile = "Tell",
        screenflash = true,
        chatalert = true,
        popupalert = false,
        casesensitive = false,
        wholewords = false,
        testmessage = "LFM tank for MC",
    })
    
    -- Create popup frame for alerts
    self:CreatePopupFrame()
    
    -- Sound file mappings
    self.soundFiles = {
        ["Tell"] = "Interface\\AddOns\\Prat\\sounds\\Tell.wav",
        ["Whisper"] = "Interface\\AddOns\\Prat\\sounds\\Whisper.wav", 
        ["Guild"] = "Interface\\AddOns\\Prat\\sounds\\GuildInvite.wav",
        ["Auction"] = "Interface\\AddOns\\Prat\\sounds\\AuctionWindowOpen.wav",
        ["Level Up"] = "Interface\\AddOns\\Prat\\sounds\\LevelUp.wav",
        ["Custom"] = "Interface\\AddOns\\Prat\\sounds\\Custom.wav",
    }
    
    Prat.Options.args.lfgalerts = {
        name = L["LFGAlerts"],
        desc = L["LFG chat monitoring and alert options."],
        type = "group",
        args = {
            requirelfm = {
                name = L["Require LFM"],
                desc = L["Only alert on messages containing 'LFM'."],
                type = "toggle",
                order = 50,
                get = function() return self.db.profile.requirelfm end,
                set = function(v) self.db.profile.requirelfm = v end,
            },
            raids = {
                name = L["Raid Filters"],
                desc = L["Select which raids to monitor for."],
                type = "group",
                order = 100,
                args = {
                    aq40 = {
                        name = L["AQ40"],
                        desc = "Monitor for AQ40 (Ahn'Qiraj 40-man)",
                        type = "toggle",
                        order = 10,
                        get = function() return self.db.profile.raids.aq40 end,
                        set = function(v) self.db.profile.raids.aq40 = v end,
                    },
                    bwl = {
                        name = L["BWL"],
                        desc = "Monitor for BWL (Blackwing Lair)",
                        type = "toggle",
                        order = 20,
                        get = function() return self.db.profile.raids.bwl end,
                        set = function(v) self.db.profile.raids.bwl = v end,
                    },
                    naxx = {
                        name = L["NAXX"],
                        desc = "Monitor for NAXX (Naxxramas)",
                        type = "toggle",
                        order = 30,
                        get = function() return self.db.profile.raids.naxx end,
                        set = function(v) self.db.profile.raids.naxx = v end,
                    },
                    kara10 = {
                        name = L["KARA 10"],
                        desc = "Monitor for KARA 10 (Karazhan 10-man)",
                        type = "toggle",
                        order = 40,
                        get = function() return self.db.profile.raids.kara10 end,
                        set = function(v) self.db.profile.raids.kara10 = v end,
                    },
                    kara40 = {
                        name = L["KARA 40"],
                        desc = "Monitor for KARA 40 (Karazhan 40-man)",
                        type = "toggle",
                        order = 50,
                        get = function() return self.db.profile.raids.kara40 end,
                        set = function(v) self.db.profile.raids.kara40 = v end,
                    },
                    mc = {
                        name = L["MC"],
                        desc = "Monitor for MC (Molten Core)",
                        type = "toggle",
                        order = 60,
                        get = function() return self.db.profile.raids.mc end,
                        set = function(v) self.db.profile.raids.mc = v end,
                    },
                    es = {
                        name = L["ES"],
                        desc = "Monitor for ES (Emerald Sanctum)",
                        type = "toggle",
                        order = 70,
                        get = function() return self.db.profile.raids.es end,
                        set = function(v) self.db.profile.raids.es = v end,
                    },
                    ony = {
                        name = L["ONY"],
                        desc = "Monitor for ONY (Onyxia)",
                        type = "toggle",
                        order = 80,
                        get = function() return self.db.profile.raids.ony end,
                        set = function(v) self.db.profile.raids.ony = v end,
                    },
                },
            },
            alerts = {
                name = L["Alert Type"],
                desc = L["Choose how to be alerted when a match is found."],
                type = "group",
                order = 200,
                args = {
                    soundalert = {
                        name = L["Sound Alert"],
                        desc = L["Play a sound when filter matches."],
                        type = "toggle",
                        order = 10,
                        get = function() return self.db.profile.soundalert end,
                        set = function(v) self.db.profile.soundalert = v end,
                    },
                    soundfile = {
                        name = L["Sound File"],
                        desc = L["Choose which sound to play."],
                        type = "text",
                        order = 20,
                        disabled = function() return not self.db.profile.soundalert end,
                        get = function() return self.db.profile.soundfile end,
                        set = function(v) self.db.profile.soundfile = v end,
                        validate = {
                            ["Tell"] = L["Tell"],
                            ["Whisper"] = L["Whisper"],
                            ["Guild"] = L["Guild"],
                            ["Auction"] = L["Auction"],
                            ["Level Up"] = L["Level Up"],
                            ["Custom"] = L["Custom"],
                        },
                    },
                    screenflash = {
                        name = L["Screen Flash"],
                        desc = L["Flash the screen when filter matches."],
                        type = "toggle",
                        order = 30,
                        get = function() return self.db.profile.screenflash end,
                        set = function(v) self.db.profile.screenflash = v end,
                    },
                    chatalert = {
                        name = L["Chat Alert"],
                        desc = L["Show alert message in default chat."],
                        type = "toggle",
                        order = 40,
                        get = function() return self.db.profile.chatalert end,
                        set = function(v) self.db.profile.chatalert = v end,
                    },
                    popupalert = {
                        name = L["Popup Alert"],
                        desc = L["Show popup window with the matching message."],
                        type = "toggle",
                        order = 50,
                        get = function() return self.db.profile.popupalert end,
                        set = function(v) self.db.profile.popupalert = v end,
                    },
                },
            },
            options = {
                name = "Options",
                type = "group",
                order = 300,
                args = {
                    casesensitive = {
                        name = L["Case Sensitive"],
                        desc = L["Make filter matching case sensitive."],
                        type = "toggle",
                        order = 10,
                        get = function() return self.db.profile.casesensitive end,
                        set = function(v) self.db.profile.casesensitive = v end,
                    },
                    wholewords = {
                        name = L["Whole Words Only"],
                        desc = L["Only match complete words, not partial matches."],
                        type = "toggle",
                        order = 20,
                        get = function() return self.db.profile.wholewords end,
                        set = function(v) self.db.profile.wholewords = v end,
                    },
                },
            },
            test = {
                name = "Test",
                desc = "Test your settings with a sample message.",
                type = "group",
                order = 400,
                args = {
                    testmessage = {
                        name = L["Test Message"],
                        desc = L["Enter a message to test against your filters."],
                        type = "text",
                        width = "full",
                        order = 10,
                        get = function() return self.db.profile.testmessage end,
                        set = function(v) self.db.profile.testmessage = v end,
                    },
                    runtest = {
                        name = L["Run Test"],
                        desc = L["Test the message against current filters."],
                        type = "execute",
                        order = 20,
                        func = function() self:TestFilters() end,
                    },
                },
            },
            toggle = {
                name = L["Toggle"],
                desc = L["Toggle the module on and off."],
                type = "toggle",
                order = 500,
                get = function() return self.db.profile.on end,
                set = function() 
                    self.db.profile.on = Prat:ToggleModuleActive("lfgalerts") 
                end
            }
        }
    }
end

function Prat_LFGAlerts:OnEnable()
    -- Hook AddMessage for all chat frames to monitor LFG window
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = getglobal("ChatFrame"..i)
        if frame then
            self:Hook(frame, "AddMessage", "ChatFrame_AddMessage")
        end
    end
    
    -- Show current settings
    local enabledRaids = {}
    for raidKey, enabled in pairs(self.db.profile.raids) do
        if enabled then
            table.insert(enabledRaids, string.upper(raidKey))
        end
    end
    
    local status = "LFG Alerts enabled."
    if self.db.profile.requirelfm then
        status = status .. " Requires 'LFM'."
    end
    if table.getn(enabledRaids) > 0 then
        status = status .. " Monitoring: " .. table.concat(enabledRaids, ", ")
    else
        status = status .. " WARNING: No raids selected!"
    end
    
    Prat:Print(status)
end

function Prat_LFGAlerts:OnDisable()
    -- Unhook all chat frames
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = getglobal("ChatFrame"..i)
        if frame and self:IsHooked(frame, "AddMessage") then
            self:Unhook(frame, "AddMessage")
        end
    end
    
    if self.popupFrame then
        self.popupFrame:Hide()
    end
end

function Prat_LFGAlerts:FindLFGChatFrame()
    -- Look for a chat window named "LFG"
    for i = 1, NUM_CHAT_WINDOWS do
        local frame = getglobal("ChatFrame"..i)
        if frame and frame:IsVisible() then
            local tabText = getglobal("ChatFrame"..i.."TabText")
            if tabText and tabText:GetText() then
                local name = string.upper(tabText:GetText())
                if name == "LFG" then
                    return frame
                end
            end
        end
    end
    return nil
end

function Prat_LFGAlerts:ChatFrame_AddMessage(frame, text, ...)
    -- Call original function first
    self.hooks[frame].AddMessage(frame, text, unpack(arg))
    
    -- Check if this is the LFG chat frame
    local lfgFrame = self:FindLFGChatFrame()
    if not lfgFrame or frame ~= lfgFrame then
        return
    end
    
    -- Check if message matches any filters
    if text then
        local matched, raidKey, keyword = self:CheckFilters(text)
        if matched then
            self:TriggerAlert(text, raidKey, keyword)
        end
    end
end

function Prat_LFGAlerts:CheckFilters(message)
    if not message then
        return false
    end
    
    local searchText = message
    if not self.db.profile.casesensitive then
        searchText = string.lower(message)
    end
    
    -- First check: Must contain "LFM" if required
    if self.db.profile.requirelfm then
        local lfmText = self.db.profile.casesensitive and "LFM" or "lfm"
        if not string.find(searchText, lfmText, 1, true) then
            return false
        end
    end
    
    -- Second check: Must match at least one enabled raid
    local raidKeywords = {
        aq40 = {"AQ40", "AQ 40", "Ahn'Qiraj", "Temple of Ahn'Qiraj"},
        bwl = {"BWL", "Blackwing Lair", "Blackwing", "BL"},
        naxx = {"NAXX", "Naxxramas", "Naxx40"},
        kara10 = {"KARA 10", "KARA10", "Karazhan 10", "Kara (10)"},
        kara40 = {"KARA 40", "KARA40", "Karazhan 40", "Kara (40)"},
        mc = {"MC", "Molten Core", "Molten", "Ragnaros"},
        es = {"ES", "Emerald Sanctum", "Emerald", "Dream"},
        ony = {"ONY", "Onyxia", "Onyxia's Lair"},
    }
    
    for raidKey, keywords in pairs(raidKeywords) do
        if self.db.profile.raids[raidKey] then
            for _, keyword in ipairs(keywords) do
                local searchKeyword = keyword
                if not self.db.profile.casesensitive then
                    searchKeyword = string.lower(keyword)
                end
                
                local found = false
                if self.db.profile.wholewords then
                    -- Match whole words only
                    local pattern = "%f[%w]" .. searchKeyword .. "%f[%W]"
                    found = string.find(searchText, pattern) ~= nil
                else
                    -- Match anywhere in text
                    found = string.find(searchText, searchKeyword, 1, true) ~= nil
                end
                
                if found then
                    return true, raidKey, keyword
                end
            end
        end
    end
    
    return false
end

function Prat_LFGAlerts:TriggerAlert(message, raidKey, keyword)
    -- Sound alert
    if self.db.profile.soundalert then
        self:PlayAlertSound()
    end
    
    -- Screen flash
    if self.db.profile.screenflash then
        self:FlashScreen()
    end
    
    -- Chat alert
    if self.db.profile.chatalert then
        local raidName = string.upper(raidKey or "UNKNOWN")
        local alertMsg = string.format("LFM Alert [%s]: %s", raidName, message)
        DEFAULT_CHAT_FRAME:AddMessage(alertMsg, 1, 1, 0) -- Yellow text
    end
    
    -- Popup alert
    if self.db.profile.popupalert then
        self:ShowPopupAlert(message, raidKey)
    end
end

function Prat_LFGAlerts:PlayAlertSound()
    local soundFile = self.soundFiles[self.db.profile.soundfile]
    if soundFile then
        PlaySoundFile(soundFile)
    else
        -- Fallback to built-in sound
        PlaySound("TellMessage")
    end
end

function Prat_LFGAlerts:FlashScreen()
    if not self.flashFrame then
        self.flashFrame = CreateFrame("Frame", "PratLFGFlashFrame", UIParent)
        self.flashFrame:SetAllPoints(UIParent)
        self.flashFrame:SetFrameStrata("FULLSCREEN_DIALOG")
        
        local texture = self.flashFrame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints(self.flashFrame)
        texture:SetTexture("Interface\\FullScreenTextures\\LowHealth")
        texture:SetAlpha(0)
        self.flashFrame.texture = texture
        
        self.flashFrame:Hide()
    end
    
    -- Flash animation
    self.flashFrame:Show()
    self.flashFrame.texture:SetAlpha(0.3)
    
    -- Fade out
    local startTime = GetTime()
    local duration = 0.5
    
    self.flashFrame:SetScript("OnUpdate", function()
        local elapsed = GetTime() - startTime
        local alpha = 0.3 * (1 - elapsed / duration)
        
        if alpha <= 0 then
            self.flashFrame.texture:SetAlpha(0)
            self.flashFrame:Hide()
            self.flashFrame:SetScript("OnUpdate", nil)
        else
            self.flashFrame.texture:SetAlpha(alpha)
        end
    end)
end

function Prat_LFGAlerts:CreatePopupFrame()
    if self.popupFrame then return end
    
    local frame = CreateFrame("Frame", "PratLFGAlertPopup", UIParent)
    frame:SetWidth(400)
    frame:SetHeight(150)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    frame:SetFrameStrata("DIALOG")
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = {left = 11, right = 12, top = 12, bottom = 11}
    })
    frame:SetBackdropColor(0, 0, 0, 0.8)
    frame:SetBackdropBorderColor(1, 1, 0, 1)
    
    -- Title
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -20)
    title:SetText("LFG Alert!")
    title:SetTextColor(1, 1, 0)
    frame.title = title
    
    -- Message text
    local message = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    message:SetPoint("CENTER", frame, "CENTER", 0, 10)
    message:SetWidth(360)
    message:SetJustifyH("CENTER")
    frame.message = message
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    closeBtn:SetWidth(80)
    closeBtn:SetHeight(22)
    closeBtn:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
    closeBtn:SetText("Close")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    -- Make draggable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
    frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    
    frame:Hide()
    self.popupFrame = frame
end

function Prat_LFGAlerts:ShowPopupAlert(message, raidKey)
    if not self.popupFrame then
        self:CreatePopupFrame()
    end
    
    -- Strip color codes for cleaner display
    local cleanMessage = string.gsub(message, "|c%x%x%x%x%x%x%x%x", "")
    cleanMessage = string.gsub(cleanMessage, "|r", "")
    
    -- Update title with raid info
    local title = "LFM Alert!"
    if raidKey then
        title = title .. " [" .. string.upper(raidKey) .. "]"
    end
    self.popupFrame.title:SetText(title)
    
    self.popupFrame.message:SetText(cleanMessage)
    self.popupFrame:Show()
    
    -- Auto-hide after 10 seconds
    self.popupFrame:SetScript("OnUpdate", function()
        if not self.popupFrame.hideTime then
            self.popupFrame.hideTime = GetTime() + 10
        elseif GetTime() > self.popupFrame.hideTime then
            self.popupFrame:Hide()
            self.popupFrame.hideTime = nil
            self.popupFrame:SetScript("OnUpdate", nil)
        end
    end)
end
            self.popupFrame.hideTime = GetTime() + 10
        elseif GetTime() > self.popupFrame.hideTime then
            self.popupFrame:Hide()
            self.popupFrame.hideTime = nil
            self.popupFrame:SetScript("OnUpdate", nil)
        end
    end)
end

-- Remove the old filter management functions as they're no longer needed
-- AddFilter and RemoveFilter functions removed since we use toggles now

function Prat_LFGAlerts:TestFilters()
    local message = self.db.profile.testmessage
    if not message or string.len(string.gsub(message, "%s", "")) == 0 then
        Prat:Print("Please enter a test message.")
        return
    end
    
    local matched, raidKey, keyword = self:CheckFilters(message)
    local result = matched and L["MATCH"] or L["NO MATCH"]
    
    if matched then
        result = result .. " [" .. string.upper(raidKey) .. ": " .. keyword .. "]"
        -- Show what the alert would look like
        Prat:Print("Test successful - This message would trigger an alert!")
        if self.db.profile.chatalert then
            local alertMsg = string.format("LFM Alert [%s]: %s", string.upper(raidKey), message)
            DEFAULT_CHAT_FRAME:AddMessage("Preview: " .. alertMsg, 0.5, 0.5, 0.5)
        end
    else
        local reasons = {}
        
        -- Check LFM requirement
        if self.db.profile.requirelfm then
            local searchText = self.db.profile.casesensitive and message or string.lower(message)
            local lfmText = self.db.profile.casesensitive and "LFM" or "lfm"
            if not string.find(searchText, lfmText, 1, true) then
                table.insert(reasons, "Missing 'LFM'")
            end
        end
        
        -- Check if any raids are enabled
        local anyEnabled = false
        for _, enabled in pairs(self.db.profile.raids) do
            if enabled then anyEnabled = true break end
        end
        if not anyEnabled then
            table.insert(reasons, "No raids enabled")
        end
        
        if table.getn(reasons) > 0 then
            result = result .. " (" .. table.concat(reasons, ", ") .. ")"
        end
    end
    
    Prat:Print(string.format(L["Test Result: %s"], result))
end