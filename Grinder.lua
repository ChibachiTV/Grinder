--[[ 
Grinder v1.0.0
- Shows how many more XP gains it will take to level you!
--]]

-- Settings menu
Grinder_SavedVars = {}

local category = Settings.RegisterVerticalLayoutCategory("Grinder")

local function OnSettingChanged(setting, value)
	-- This callback will be invoked whenever a setting is modified.
	--print("Setting changed:", setting:GetVariable(), value)
end

local function InitilizeSettingsUI()
    do 
        -- RegisterAddOnSetting example. This will read/write the setting directly
        -- to `Grinder_SavedVars.toggle`.
    
        local name = "Show in Chat"
        local variable = "Grinder_Chat_Toggle"
        local variableKey = "showInChatToggle" -- this becomes the variable name: Grinder_SavedVars.showInChatToggle
        local variableTbl = Grinder_SavedVars
        local defaultValue = false
    
        local setting = Settings.RegisterAddOnSetting(category, variable, variableKey, variableTbl, type(defaultValue), name, defaultValue)
        setting:SetValueChangedCallback(OnSettingChanged)
    
        local tooltip = "Show how many more XP gains needed in the chat?"
        Settings.CreateCheckbox(category, setting, tooltip)
    end
    
    Settings.RegisterAddOnCategory(category)
end

-- Local variables
local previousXP = 0
local totalXPGained = 0

local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:RegisterEvent("PLAYER_XP_UPDATE")

local alertText = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
alertText:SetPoint("TOP", UIParent, "TOP", 0, -250)
alertText:SetTextColor(1, 1, 1, 0)
alertText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
alertText:Hide()

local animGroup = alertText:CreateAnimationGroup()
    
local fadeIn = animGroup:CreateAnimation("Alpha")
fadeIn:SetOrder(1)
fadeIn:SetFromAlpha(0)
fadeIn:SetToAlpha(1)
fadeIn:SetDuration(0.5)
fadeIn:SetSmoothing("IN")

local stay = animGroup:CreateAnimation("Alpha")
stay:SetOrder(2)
stay:SetFromAlpha(1)
stay:SetToAlpha(1)
stay:SetDuration(5)
stay:SetSmoothing("NONE")

local fadeOut = animGroup:CreateAnimation("Alpha")
fadeOut:SetOrder(3)
fadeOut:SetFromAlpha(1)
fadeOut:SetToAlpha(0)
fadeOut:SetDuration(0.5)
fadeOut:SetSmoothing("OUT")

animGroup:SetScript("OnFinished", function()
    alertText:Hide()
end)

local function ShowAlert(message)
    alertText:SetText(message)
    alertText:SetTextScale(1)
    alertText:SetAlpha(0)
    alertText:Show()

    animGroup:Play()
end

-- Events
addonFrame:SetScript("OnEvent", function(self, event, arg1, ...)
    if event == "ADDON_LOADED" then
        if arg1 == "Grinder" then
            previousXP = UnitXP("player") -- Maybe calling this here fixes the initial 1 mob to lvl issue

            InitilizeSettingsUI()
        end
    
    elseif event == "PLAYER_XP_UPDATE" then
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")

        if currentXP <= previousXP then
            previousXP = currentXP
            return
        end

        local remainingXP = maxXP - currentXP
        local xpGained = currentXP - previousXP
        local remainingGains = floor(remainingXP / xpGained) + 1

        totalXPGained = totalXPGained + xpGained

        if remainingGains > 0 then
            local message = remainingGains .. " more to level up!"
            ShowAlert(message)

            if Grinder_SavedVars.showInChatToggle then
                print(message)
            end
        end

        previousXP = currentXP -- Update the stored XP
    end
end)