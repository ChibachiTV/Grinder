local addonFrame = CreateFrame("Frame")
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

local previousXP = UnitXP("player")

-- This is basic, but works as intended. 
addonFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_XP_UPDATE" then
        local currentXP = UnitXP("player")
        local maxXP = UnitXPMax("player")
        local remainingXP = maxXP - currentXP
        local xpGained = currentXP - previousXP
        previousXP = currentXP -- Update the stored XP

        if xpGained > 0 then
            local remainingKills = floor(remainingXP / xpGained) + 1
            if remainingKills > 0 then
                ShowAlert(remainingKills .. " more to level up!")
            end
        end
    end
end)