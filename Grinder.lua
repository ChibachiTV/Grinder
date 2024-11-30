--[[ 
Grinder v1.0.0
- Shows how many more XP gains it will take to level you!
- Also provides a time estimate for you to level.

Commands:
/grinder chat on    - Send the alert to the chat window as well
/grinder chat off   - (Default) Don't send the alert to the chat window
/grinder est        - Show the estimated time until level in the chat window
--]]

-- Load the global variables
displayInChat = displayInChat or false
showScreenText = showScreenText or false

-- Local variables
local previousXP = UnitXP("player")
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

-- Timer window to show on the screen
local timerFrame = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
timerFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 150)
timerFrame:SetTextColor(1, 1, 1, 1)
timerFrame:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")

local function ShowAlert(message)
    alertText:SetText(message)
    alertText:SetTextScale(1)
    alertText:SetAlpha(0)
    alertText:Show()

    animGroup:Play()
end

local function EstimateTimeUntilNextLevel()
    local xpNeededForNextLevel = UnitXPMax("player") - UnitXP("player")
    local xpGainedPerSecond = totalXPGained / GetSessionTime()

    if xpGainedPerSecond > 0 then
        local timeUntilNextLevel = xpNeededForNextLevel / xpGainedPerSecond
        return math.ceil(timeUntilNextLevel)
    else
        return -1 -- No XP gained yet, can't estimate
    end
end

-- Format time in days, hours, minutes
local function FormatTime(seconds)
    local days = math.floor(seconds / 86400)
    seconds = seconds % 86400
    local hours = math.floor(seconds / 3600)
    seconds = seconds % 3600
    local minutes = math.floor(seconds / 60)

    local dayString = (days == 1) and "day" or "days"
    local hourString = (hours == 1) and "hour" or "hours"
    local minuteString = (minutes == 1) and "minute" or "minutes"

    if days > 0 then
        return string.format("%d %s, %d %s, %d %s", days, dayString, hours, hourString, minutes, minuteString)
    elseif hours > 0 then
        return string.format("%d %s, %d %s", hours, hourString, minutes, minuteString)
    else
        return string.format("%d %s", minutes, minuteString)
    end
end

function UpdateTimerFrame()
    local seconds = EstimateTimeUntilNextLevel()
    if seconds == -1 then
        timerFrame:SetText("Not enough data")
    else
        timerFrame:SetText("Est. Time: " .. FormatTime(seconds))
    end
end

-- Events
addonFrame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == "Grinder" then
        if showScreenText then 
            timerFrame:Show()
        else 
            timerFrame:Hide()
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

        UpdateTimerFrame()

        previousXP = currentXP -- Update the stored XP
    end
end)

local displayUpdateTimer = 0

addonFrame:SetScript("OnUpdate", function(self, elapsed)
    if not timerFrame:IsVisible() then return end

    displayUpdateTimer = displayUpdateTimer + elapsed
    
    if displayUpdateTimer >= 10 then
        UpdateTimerFrame()
        displayUpdateTimer = 0
    end
end)

UpdateTimerFrame()

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
    elseif msg == "est" then
        local timeUntilNextLevel = EstimateTimeUntilNextLevel()
        if timeUntilNextLevel > 0 then
            print("Estimated level up in: " .. FormatTime(timeUntilNextLevel) .. "!")
        else
            print("Not enough data to estimate.")
        end
    elseif msg == "show" then
        showScreenText = true
        timerFrame:Show()
    elseif msg == "hide" then
        showScreenText = false
        timerFrame:Hide()
    end
end