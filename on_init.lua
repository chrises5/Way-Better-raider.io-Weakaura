-- If true write score after ilvl, otherwise after name
local afterIlvl = true
-- Separator between name/ilvl and score. Examples: " ", " - ", " / "
local rioSeparator = " | "
-- if false show exact value (1340), otherwise - short (1.3k)
local rioShort = false
-- Used with short score format. Examples: "(%.1fk)"
local rioFormat = "%.1fk"
-- Show group leader score as group name prefix when you searching for dungeons - ex: "[1360] +14 Atal" or "[UNK] +2"
local searchScore = true

-- DO NOT EDIT
BRIO = {}
BRIO.LFG_DUNGEON_CATEGORY_ID = 2 -- can check with C_LFGList.GetCategoryInfo(categoryID)
BRIO.LFG_MAX_ENTRY_NAME_LEN = 25 -- can check manually (+5 for title without voice icon)
BRIO.GetColorString = function(score)
    r, b, g = RaiderIO.GetScoreColor(score);
    rString = string.format("%x", 255*r)
    bString = string.format("%x", 255*b)
    gString = string.format("%x", 255*g)
    
    if r*255 <= 15 then
        rString = rString .. "0"
    end
    
    if b*255 <= 15 then
        bString = bString .. "0"
    end
    
    if g*255 <= 15 then
        gString = gString .. "0"
    end
    
    local color = string.format("\124cff%s%s%s", rString, bString, gString)
    return color
end

BRIO.GetPlayerRIO = function(fullname)
    local profile = RaiderIO.GetPlayerProfile(0, fullname)
    if profile == nil then return end
    profile = profile[1]
    if profile == nil then return end
    
    local score = profile.profile.mplusCurrent.score
    local mainScore = profile.profile.mplusMainCurrent.score
    
    if rioShort then 
        score = score / 1000
        mainScore = mainScore / 1000
    end
    
    scoreColor = BRIO.GetColorString(score);
    scoreString = scoreColor .. score;
    mainScoreString = BRIO.GetColorString(mainScore) .. mainScore;
    
    if mainScore ~= nil then 
        local scoreString = string.format(rioShort and rioFormat or "%s \124r | %s", scoreString, mainScoreString)
    elseif true then
        local scoreString = string.format(rioShort and rioFormat or "%s", scoreString)
    end
    
    return scoreString, scoreColor
end
aura_env.UpdateApplicant = function(button, id)
    if afterIlvl then
        button.InviteButton:SetWidth(25);
        button.InviteButton:SetText("");
        button.InviteButton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Check")
    end
end
aura_env.UpdateApplicantMember = function(member, appID, memberIdx, status, pendingStatus)
    local fullname, _ = C_LFGList.GetApplicantMemberInfo(appID, memberIdx)
    
    local scoreString = BRIO.GetPlayerRIO(fullname)
    if scoreString == nil then return end
    
    if afterIlvl then
        member.ItemLevel:SetText(member.ItemLevel:GetText() .. rioSeparator .. scoreString)
        _, relativeTo, relativePoint, xOfs, yOfs = member.ItemLevel:GetPoint(1)
        member.ItemLevel:ClearAllPoints();
        member.ItemLevel:SetPoint("CENTER", relativeTo, "RIGHT", -3, 0);
    else
        member.Name:SetText(member.Name:GetText() .. rioSeparator .. scoreString)
    end
end
aura_env.SearchEntry_Update = function(group)
    local result = C_LFGList.GetSearchResultInfo(group.resultID)
    local categoryID = select(3, C_LFGList.GetActivityInfo(result.activityID))
    -- print(result.leaderName, result.searchResultID, result.activityID, categoryID)
    if categoryID ~= BRIO.LFG_DUNGEON_CATEGORY_ID then return end
    
    local scoreString, scoreColor = BRIO.GetPlayerRIO(result.leaderName)
    if scoreString == nil then scoreString = "0"; scoreColor = BRIO.GetColorString(0) end
    
    group.Name:SetText(string.format("%s[%s] %s", scoreColor, scoreString, group.Name:GetText()))
end

hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", aura_env.UpdateApplicant)
hooksecurefunc("LFGListApplicationViewer_UpdateApplicantMember", aura_env.UpdateApplicantMember)
if searchScore == true then
    hooksecurefunc("LFGListSearchEntry_Update", aura_env.SearchEntry_Update)
end

