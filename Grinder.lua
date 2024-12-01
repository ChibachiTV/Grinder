--[[ 
Grinder v1.0.0
- Shows how many more XP gains it will take to level you!

Commands:
/grinder chat on    - Send the alert to the chat window as well
/grinder chat off   - (Default) Don't send the alert to the chat window
--]]

-- Load the global variables
displayInChat = displayInChat or false

-- Local variables
local previousXP = 0
local totalXPGained = 0

local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:RegisterEvent("PLAYER_XP_UPDATE")
addonFrame:RegisterEvent("TIME_PLAYED_MSG")

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

            if displayInChat then
                print(message)
            end
        end

        previousXP = currentXP -- Update the stored XP
    end
end)

-- Slash commands
SLASH_GRINDER1 = "/grinder"
SlashCmdList["GRINDER"] = function(msg)
    msg = msg:lower()
    if msg == "chat on" then
        displayInChat = true
        print("Grinder will now print to the chat as well.")
    elseif msg == "chat off" then
        displayInChat = false
        print("Grinder will not print to the chat now.")
    end
end